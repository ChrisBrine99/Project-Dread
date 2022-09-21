/// @description Insert summary of this file here.

#region Initializing any macros that are useful/related to obj_cutscene_manager

// Macros that allows the cutscene functions to be referenced by objects that store the scene instructions
// for their specific cutscenes. (Ex. triggers will store cutscenes on themselves until a collision with 
// the player causes them to transfer the instructions onto the cutscene manager)
#macro	CUTSCENE_JUMP_INDEX					CUTSCENE_MANAGER.cutscene_jump_to_index
#macro	CUTSCENE_SET_EVENT_FLAG				CUTSCENE_MANAGER.cutscene_set_event_flag
#macro	CUTSCENE_WAIT						CUTSCENE_MANAGER.cutscene_wait
#macro	CUTSCENE_SET_CAMERA_STATE			CUTSCENE_MANAGER.cutscene_set_camera_state
#macro	CUTSCENE_WAIT_FOR_CAMERA_POSITION	CUTSCENE_MANAGER.cutscene_wait_for_camera_position
#macro	CUTSCENE_SET_CAMERA_SHAKE			CUTSCENE_MANAGER.cutscene_set_camera_shake
#macro	CUTSCENE_PLAY_SOUND					CUTSCENE_MANAGER.cutscene_play_sound
#macro	CUTSCENE_PLAY_SOUND_AT				CUTSCENE_MANAGER.cutscene_play_sound_at
#macro	CUTSCENE_ADD_TEXTBOX_TEXT			CUTSCENE_MANAGER.cutscene_add_textbox_text
#macro	CUTSCENE_ADD_TEXTBOX_DECISION		CUTSCENE_MANAGER.cutscene_add_textbox_decision
#macro	CUTSCENE_SET_TEXTBOX_TO_CLOSE		CUTSCENE_MANAGER.cutscene_set_textbox_to_close
#macro	CUTSCENE_SHOW_TEXTBOX				CUTSCENE_MANAGER.cutscene_show_textbox
#macro	CUTSCENE_ASSIGN_ENTITY_STATE		CUTSCENE_MANAGER.cutscene_assign_entity_state
#macro	CUTSCENE_MOVE_ENTITY_POSITION		CUTSCENE_MANAGER.cutscene_move_entity_to_position
#macro	CUTSCENE_SET_ENTITY_POSITION		CUTSCENE_MANAGER.cutscene_set_entity_position
#macro	CUTSCENE_MARK_ENTITY_PERSISTENT		CUTSCENE_MANAGER.cutscene_mark_entity_persistent
#macro	CUTSCENE_SET_ENTITY_SPRITE			CUTSCENE_MANAGER.cutscene_set_entity_sprite
#macro	CUTSCENE_INVOKE_SCREEN_FADE			CUTSCENE_MANAGER.cutscene_invoke_screen_fade
#macro	CUTSCENE_END_SCREEN_FADE			CUTSCENE_MANAGER.cutscene_end_screen_fade

#endregion

#region Initializing any globals that are useful/related to obj_cutscene_manager
#endregion

#region	The main object code for obj_cutscene_manager

function obj_cutscene_manager() constructor{
	// Much like Game Maker's own object_index variable, this will store the unique ID value provided to this
	// object by Game Maker during runtime; in order to easily use it within a singleton system.
	object_index = obj_cutscene_manager;
	
	// A simple flag that determines if the cutscene manager is currently executing a cutscene or not. The
	// second variable stores the unique instance ID for the trigger that activated a given cutscene to 
	// being playing out its list of instructions.
	isCutsceneActive = false;
	triggerID = noone;
	
	// Variables that store the current cutscene's instruction data and also track the scene's current
	// position within that list of instructions. The "instructionFunction" variable will store the script
	// index value that is generated by GML for each cutscene instruction function so that it can be called
	// with "script_execute_ext".
	sceneInstructions = -1;
	instructionFunction = -1;
	currentSceneIndex = 0;
	
	// A flag that allows a different chunk of code to be executed on the first call of a given scene's
	// instruction function. After the first call, the "firstExecution" chunk will no longer be processed.
	firstExecution = false;
	
	// Variables that store the camera's state and the arguments that are required for said state to 
	// function whenever the camera gets maniupulated by a given cutscene. The "cameraManipulated" flag is
	// what tells the cutscene manager if the camera had its state altered at all, which then make the
	// manager store the state data within these variables.
	prevCameraState = NO_STATE;
	prevCameraStateArgs = array_create(0, 0);
	cameraManipulated = false;
	
	// Initialize some data structures (Two maps, and a list) that will be integral to how the cutscene
	// manager functions. One of the maps is responsible for storing the previous state of the three "state"
	// variables contained within ALL dynamic entity objects; replacing them all with "NO_STATE" values for
	// the duration of a given cutscene. The next map stores all instance IDs for objects that were created
	// during a cutscene; marking them for deletion after the cutscene or not depending on what the object
	// is set to do. Finally, the list stores all entity objects that are temporarily set to persistent if
	// a cutscene happens to move between rooms and certain cutscene objects need to be carried over, too.
	entityStates = ds_map_create();
	entityTempPersistence = ds_list_create();
	createdObjects = ds_map_create();
	
	// A timer that is utilized by the "cutscene_wait" instruction, which simply tracks how long the scene
	// has been active for until it surpasses the given amount of "frames" (1/60th of a second) to wait.
	waitTimer = 0;
	
	// Stores the sound that was played by either of the "cutscene_play_sound_*" instructions; allowing the
	// cutscene manager to wait for that single sound instance to play in its entirety if the instruction
	// requires that.
	soundID = NO_SOUND;
	
	/// @description Code that should be placed into the "Step" event of whatever object is controlling
	/// obj_cutscene_manager. In short, it will execute the current scene instruction's function until that
	/// instruction meets the requirements to move onto the next instruction; until the cutscene itself
	/// has completed its execution.
	step = function(){
		if (isCutsceneActive) {script_execute_ext(instructionFunction, sceneInstructions[| currentSceneIndex], 1);}
	}
	
	/// @description Code that should be placed into the "Cleanup" event of whatever object is controlling
	/// obj_cutscene_manager. In short, it will clear any allocated memory that isn't automatically cleaned
	/// up by Game Maker during runtime. (Ex. data structures, surfaces, structs, etc.)
	cleanup = function(){
		ds_map_destroy(entityStates);
		ds_list_destroy(entityTempPersistence);
		ds_map_destroy(createdObjects);
	}
	
	/// @description Code that should be placed into the "Room End" event of whatever object is controlling
	/// obj_cutscene_manager. In short, it will clean out any unnecessary data for non-persistent entities
	/// from the map that stores all currently existing entity state data. (Current, next, and last states,
	/// respectively) All persistent entities will have their data carried over to the next room.
	room_end = function(){
		// If no cutscene is currently active, no cleaning up of unnecessary entity data being stored for
		// non-persistent objects while moving into another room needs to be processed, so the event is
		// completely skipped over.
		if (!isCutsceneActive) {return;}
		
		// Loop through the map of entity state data and compare the ID values (which are the keys for each
		// index of the map) to the ID values stored within the temporary entity persistence list. Any
		// matching indexes will have their data preserved in the state storage map, whereas other entities
		// will have their data cleared from the map.
		var _curKey, _nextKey;
		_curKey = ds_map_find_first(entityStates);
		while(!is_undefined(_curKey)){
			// In order to delete the map value from within the same loop that goes through every index of
			// the map to compare for persistent entities, a temporary variable "_nextKey" is used to store
			// the key for the NEXT index in the map; after which the current index is deleted and the
			// current key (That is now an undefined key value) is overwritten with this temporary variable's
			// stored value.
			if (ds_list_find_index(entityTempPersistence, _curKey) != -1){
				_nextKey = ds_map_find_next(entityStates, _curKey);
				ds_map_delete(entityStates, _curKey);
				_curKey = _nextKey;
				continue;
			}
			
			// If the entity is persistent, all that wil be done is the next key for the map is acquired
			// and the loop will move on as normal.
			_curKey = ds_map_find_next(entityStates, _curKey);
		}
	}
	
	/// @description The function that should always be called during the completion of a given instruction
	/// during the cutscene. It will increment the scene counter to the next value (or assign it to the
	/// index that was provided in the optional second argument space
	/// @param executeNextInstructionInstantly
	/// @param destinationIndex
	cutscene_end_instruction = function(_executeNextInstructionInstantly, _destinationIndex = -1){
		// First, the destination index is checked to see if a valid index was provided. If there was one
		// the next scene instruction will be set to that provided index value. Otherwise, the instruction
		// index will simply be incremented by one.
		if (_destinationIndex != -1)	{currentSceneIndex = _destinationIndex;}
		else							{currentSceneIndex++;}
		
		// Next, check if that scene index exceeds the total number of instructions for this cutscene. If
		// the scene instruction index value is higher than that list's size, the cutscene will be considered
		// complete by default and the cutscene manager will be deactivated; returning all entities back
		// to what their states were prior to the cutscene beginning.
		if (currentSceneIndex >= ds_list_size(sceneInstructions)){
			GAME_SET_STATE(GAME_STATE_PREVIOUS, true);
			isCutsceneActive = false;
			
			// Check if the required flag for the trigger has been set to the required state. If it has,
			// the trigger will need to be deleted in order prevent the cutscene from playing out again
			// despite the fact that the player has already seen it. (Reoccurring cutscenes don't have
			// these conditions apply to them, and their triggers will remain in the game world)
			with(triggerID){
				if (EVENT_GET_FLAG(eventFlagID) == eventTargetState) {instance_destroy(self);}
			}
			
			// Reapplies the state and state arguments back into the camera if they had been manipulated
			// at all during the cutscene's instruction execution. The flag is then set to false to prevent
			// an accidental overwrite curing a cutscene that never messed with the camera.
			if (cameraManipulated){
				CAMERA.camState = prevCameraState;
				CAMERA.camStateArgs = prevCameraStateArgs;
				cameraManipulated = false;
			}
			
			// Return all entity's back to the states they had before the cutscene began its execution by
			// looping through each index in the map (Those maps are the IDs for each entity to allow for
			// less overall data being stored in each key's array) and applying the three state values back
			// to the same variables they were taken from when the cutscene started.
			var _key, _states;
			_key = ds_map_find_first(entityStates);
			while(!is_undefined(_key)){
				_states = entityStates[? _key];
				with(_key){ // Jumps into the entity instance to restore its state variables.
					curState =		_states[0];
					nextState =		_states[1];
					lastState =		_states[2];
				}
				_key = ds_map_find_next(entityStates, _key);
			}
			ds_map_clear(entityStates);
			
			// Also, clean up the temporary persistence data; returning all objects that exist within the
			// list back to non-persistence if they still happen to exist after the cutscene has completed.
			var _length = ds_list_size(entityTempPersistence);
			for (var i = 0; i < _length; i++){
				with(entityTempPersistence[| i]) {persistent = false;}
			}
			ds_list_clear(entityTempPersistence);
			
			return; // Exit since no more data needs to be processed by the cutscene manager.
		}
		
		// If the cutscene is still executing, the next instruction's function is stored within a seperate
		// variable from the array within the instruction list, but as its index value set by GML instead
		// of the function pointer value that it would be otherwise. Doing this allows the function to be
		// called with "script_execute_ext" which is important for allowing the each instruction function
		// to have unique amounts of arguments.
		instructionFunction = method_get_index(sceneInstructions[| currentSceneIndex][0]);
		firstExecution = true;
		
		// Finally, if the cutscene instruction was set to execute the next desired instruction instantly,
		// it will be called here instead of waiting until the next frame to do so. This allows for things
		// like setting up a textbox or other one-frame scene instructions to not actually take a full
		// frame and instead occur before any instructions that do happen over the course of multiple
		// frames.
		if (_executeNextInstructionInstantly) {script_execute_ext(instructionFunction, sceneInstructions[| currentSceneIndex], 1);}
	}
	
	/// -- General Purpose Functions for Cutscenes -- /////////////////////////////////////////////////////////////////
	
	/// @description An extremely simple instruction that will instantly jump the cutscene to a given index
	/// that is found within the list. To prevent errors, it will clamp the value to be between 0 and the
	/// size of the instruction list. After that, the cutscene's end instruction is called which will set
	/// the index properly while also moving onto executing that instruction.
	/// @param index
	cutscene_jump_to_index = function(_index){
		_index = clamp(_index, 0, ds_list_size(sceneInstructions) - 1);
		cutscene_end_instruction(true, _index);
	}
	
	/// @description A very simple function that will set a given flag's value to the state specified within
	/// the cutscene's instruction data. Useful for enabling/disabling certain events or cutscenes depending
	/// on choices made by the player during certain cutscenes or gameplay.
	/// @param flagID
	/// @param flagState
	cutscene_set_event_flag = function(_flagID, _flagState){
		EVENT_SET_FLAG(_flagID, _flagState);
		cutscene_end_instruction(true);
	}
	
	/// @description Another very simple but incredibly versatile function that will pause the cutscene's
	/// execution of further instructions until AFTER the variable "waitTimer" contains a value that is
	/// greater than the amount of units to wait. (A "unit" is equal to 1/60th of a real-world second)
	/// @param units
	cutscene_wait = function(_units){
		waitTimer += DELTA_TIME; // Increment based on delta time for frame-independent timing.
		if (waitTimer >= _units) {cutscene_end_instruction(false);}
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	/// -- Cutscene Functions for Manipulating the Camera -- //////////////////////////////////////////////////////////
	
	/// @description Applies a state to the camera; allowing it to be move freely around the current room
	/// without having to worry about whatever object the camera was following prior to this instruction
	/// being processed by the cutscene manager. If the camera's state hadn't been altered yet in the scene,
	/// the previous state data will be stored in the cutscene's camera state storage variables so that
	/// they are restored after the scene is finished.
	/// @param state
	/// @param arguments[]
	cutscene_set_camera_state = function(_state, _arguments){
		if (!cameraManipulated){
			prevCameraState =		CAMERA.camState;
			prevCameraStateArgs =	CAMERA.camStateArgs;
			cameraManipulated =		true;
		}
		camera_set_state(_state, _arguments);
		cutscene_end_instruction(true);
	}
	
	/// @description Tells the cutscene manager to wait until the camera has reached the position it needs
	/// to be at given the current movement state that is active for the camera. However, if the current
	/// state wasn't set to one of those positional movement states, or if there isn't any state applied
	/// to the camera for movement, the cutscene will simply skip over the instruction to prevent any
	/// softlocking for an improperly setup cutscene instruction list.
	cutscene_wait_for_camera_position = function(){
		var _positionReached = false;
		with(CAMERA){
			_positionReached = !((camState == STATE_TO_POSITION || camState == STATE_TO_POSITION_SMOOTH) && array_length(camStateArgs) > 0);
			if (!_positionReached) {_positionReached = (x == camStateArgs[X] && y == camStateArgs[Y]);}
		}
		if (_positionReached) {cutscene_end_instruction(false);}
	}
	
	/// @description Applies a shake effect of a given strength and duration of time for the camera to 
	/// apply to its current position. Optionally, this instruction can wait for that shake effect to 
	/// complete its execution before moving onto the next instruction in the scene list.
	/// @param shakeStrength
	/// @param duration
	/// @param waitForShake
	cutscene_set_camera_shake = function(_shakeStrength, _duration, _waitForShake = false){
		// The first execution is where the shake is applied to the camera itself. Otherwise, the shake
		// would be constantly reset to its strongest amount infinitely. Only allowing one execution of
		// this code prevents this issue.
		if (firstExecution){
			camera_set_shake(_shakeStrength, _duration);
			firstExecution = false;
		}
		
		// If the instruction is set to wait out the shake's duration, a check will be constantly performed
		// and every call of this function until the strength of the shake goes below the threshold of 0.1.
		// After that, the cutscene will move onto the next instruction.
		var _shakeFinished = false;
		with(CAMERA) {_shakeFinished = (shakeCurStrength < 0.1);}
		
		// Finally, check if the cutscene should move onto the next instruction in the scene IF it was
		// set to not wait for the shake to complete or if the shake has finished its execution on the
		// camera's side of things.
		if (!_waitForShake || (_waitForShake && _shakeFinished)) {cutscene_end_instruction(!_waitForShake);}
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	/// -- Cutscene Functions for Playing Sound Effects -- ////////////////////////////////////////////////////////////
	
	/// @description An instruction that will begin playing the sound that was supplied within the first
	/// argument field. Optionally, the volume and pitch of this sound can be altered. On top of that, the
	/// instruction execution can be temporarily paused until the sound has finished playing if the scene
	/// requires that. (This flag is set to "true" by default) Otherwise, the next instruction will be
	/// called instantly after the sound begins playing.
	/// @param sound
	/// @param volume
	/// @param pitch
	/// @param stopPrevious
	/// @param waitForSound
	cutscene_play_sound = function(_sound, _volume = SOUND_VOLUME, _pitch = 1, _stopPrevious = false, _waitForSound = true){
		// The sound will be set to play on the first execution of this instruction function. From here,
		// it will store the ID of the sound in the "soundID" variable for later reference if the function
		// has been told to wait for the sound to stop playing before moving onto the next instruction.
		if (firstExecution){
			soundID = audio_play_sound_ext(_sound, 0, _volume, _pitch, _stopPrevious);
			firstExecution = false;
		}
		
		// After beginning the sound's playing, check if the function is meant to pause for the full 
		// duration of the sound OR if it should just intsantly move onto the next instruction based on 
		// the value stored in the "_waitForSound" flag.
		if (!_waitForSound || !audio_is_playing(soundID)){
			soundID = NO_SOUND; // Clear out the ID for the sound since it's no longer being played.
			cutscene_end_instruction(!_waitForSound);
		}
	}
	
	/// @description A variation on the "cutscene_play_sound" function above that will play a spacial-based
	/// sound, with the volume of said sound lowering the further away it is from the listener (usually
	/// the player under most circumstances) with stereo audio capabilities for said sound. It can either
	/// pause instruction execution until the sound finishes playing, or it can instantly move on just
	/// like the above function.
	/// @param x
	/// @param y
	/// @param sound
	/// @param refDistance
	/// @param maxDistance
	/// @param volume
	/// @param pitch
	/// @param stopPrevious
	/// @param waitForSound
	cutscene_play_sound_at = function(_x, _y, _sound, _refDistance, _maxDistance, _volume = SOUND_VOLUME, _pitch = 1, _stopPrevious = false, _waitForSound = true){
		// Much like the standard "cutscene_play_sound" function, the sound will be set to play only on the
		// first execution of this instruction's function; storing the ID for that sound in a variable for
		// later reference.
		if (firstExecution){
			soundID = audio_play_sound_at_ext(_x, _y, _sound, 0, _volume, _pitch, _refDistance, _maxDistance, 1, _stopPrevious);
			firstExecution = false;
		}
		
		// Much like "cutscene_play_sound" again, this function will either instantly move onto the next
		// instruction within the list or it will pause instruction execution until the audio has finished
		// playing; useful depending on the context.
		if (!_waitForSound || !audio_is_playing(soundID)){
			soundID = NO_SOUND; // Much like the above function, the sound ID should be cleared after this instruction finishes.
			cutscene_end_instruction(!_waitForSound);
		}
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	/// -- Cutscene Functions for Manipulating the Textbox Handler -- /////////////////////////////////////////////////
	
	/// @description Adds a new text data struct to the textbox's ds_list that it will work through when
	/// it is set to begin executing on said data. It will simply call the "textbox_add_text_data" function
	/// since that will already handle everything on the textbox side; moving onto the next instruction
	/// instantly after the data has been added.
	/// @param text
	/// @param actor
	/// @param portraitIndex
	/// @param textXScale
	/// @param textYScale
	cutscene_add_textbox_text = function(_text, _actor = Actor.None, _portraitIndex = -1, _textXScale = 1, _textYScale = 1){
		//textbox_add_text_data(_text, _actor, _portraitIndex, _textXScale, _textYScale);
		cutscene_end_instruction(true);
	}
	
	/// @description A cutscene instruction that will add a new decision option to the newest available
	/// index of text data found within the currently loaded list of text data for the textbox. It will
	/// instantly begin the next available instruction in the list after performing the decision data
	/// addition to the textbox's data.
	/// @param optionText
	/// @param outcomeIndex
	/// @param cutsceneOutcomeIndex
	cutscene_add_textbox_decision = function(_optionText, _outcomeIndex, _cutsceneOutcomeIndex = -1){
		textbox_add_decision_data(_optionText, _outcomeIndex, _cutsceneOutcomeIndex);
		cutscene_end_instruction(true);
	}
	
	/// @description Another cutscene instruction for the textbox; adding a shaking effect to the most
	/// recently created textbox struct at a given strength; depleting as the duration reaches its end.
	/// Like the other instructions involving setting up the textbox, this function will instantly move
	/// onto the next scene instruction.
	/// @param shakeStrength
	/// @param shakeDuration
	cutscene_add_textbox_shake_effect = function(_shakeStrength, _shakeDuration){
		textbox_add_shake_effect(_shakeStrength, _shakeDuration);
		cutscene_end_instruction(true);
	}
	
	/// @description A cutscene instruction that adds a sound effect to the newest available textbox found
	/// within the data structure storing all textbox structs within that respective handler object. This
	/// cutscene is stored within the textbox struct itself in order to play it once the textbox is shown
	/// to the player.
	/// @param sound
	/// @param volume
	/// @param pitch
	cutscene_add_textbox_sound_effect = function(_sound, _volume = SOUND_VOLUME, _pitch = 1){
		textbox_add_sound_effect(_sound, _volume, _pitch);
		cutscene_end_instruction(true);
	}
	
	/// @description A cutscene instruction that will simply assign the newest index of text data for the
	/// textbox to trigger an early closing for the textbox. This is useful for branching decisions in the
	/// dialogue actually leading to different outcomes. After this instruction finishes it will instantly
	/// begin processing the next available instruction.
	cutscene_set_textbox_to_close = function(){
		textbox_set_to_close();
		cutscene_end_instruction(true);
	}
	
	/// @description A special instruction that will begin the execution of the textbox, which will handle
	/// all of the instruction data the cutscene loaded into the textbox handler struct. This instruction
	/// has the option to pause further instructions from being processed by the cutscene object until the
	/// textbox has finished its execution OR it can simply start the textbox before moving onto those
	/// future instructions.
	/// @param pauseForTextbox
	cutscene_show_textbox = function(_pauseForTextbox = true){
		// Initial execution of the function will initialize the textbox for all the text loaded in by 
		// the cutscene's previous instructions that SHOULD have contained a cutscene_add_textbox_text
		// function at one point or another.
		if (firstExecution && !TEXTBOX_HANDLER.isTextboxActive){
			textbox_begin_execution();
			firstExecution = false;
		}
		
		// If the cutscene manager is set to pause scene instruction execution for the entire active state
		// of the textbox, it will be checking that state on every call of this instruction by the manager
		// struct. The target index for the next scene instruction in the cutscene will also be checked
		// in the event that a decision chosen during the textbox changes how the cutscene will play out.
		var _textboxClosed, _targetIndex;
		_textboxClosed = false;
		_targetIndex = -1;
		with(TEXTBOX_HANDLER){
			_textboxClosed = (isTextboxActive == false);
			_targetIndex = cutsceneTargetIndex;
		}
		
		// Move onto the next instruction if the cutscene instructions weren't set to pause their execution
		// for the duration of the textbox's active state. Otherwise, the textbox will have closed and the
		// outcome index (-1 if there is no change in instruction execution) will be set to move to the
		// desired scene--whether that is the next in the list or a jump to somewhere else in the list.
		if (!_pauseForTextbox || _textboxClosed) {cutscene_end_instruction(!_pauseForTextbox, _targetIndex);}
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	/// -- Cutscene Functions for Manipulating Entities -- ////////////////////////////////////////////////////////////
	
	/// @description Assigns a new state to a given entity object; after which it will instantly move onto
	/// the next instruction for the cutscene. It's extremely simple since the cutscene doesn't wait for
	/// the entity's state to complete, since a completion might not be possible for certain states.
	/// @param entityID
	/// @param stateFunction
	cutscene_assign_entity_state = function(_entityID, _stateFunction){
		with(_entityID) {object_set_next_state(_stateFunction);}
		cutscene_end_instruction(true);
	}
	
	/// @description A unique state setting instruction for a gicen entity that will move them towards
	/// a specific position at a specific movement speed modifier. (Supplied by the cutscene instruction's
	/// data) Trying to set this movement state in the default "cutscene_assign_entity_state" function
	/// will cause issues due to the target position and move speed variables not being properly assigned.
	/// Optionally, the cutscene manager can be set to wait until the given entity completes moving to
	/// the required coordinates in the room.
	/// @param entityID
	/// @param x
	/// @param y
	/// @param moveSpeed
	/// @param waitForEntity
	cutscene_move_entity_to_position = function(_entityID, _x, _y, _moveSpeed, _waitForEntity = true){
		// During the first execution of this instruction, the state will be applied to the given entity
		// based on the supplied ID; setting the target x, y, movement speed, and direction in their 
		// respective variables found within all dynamic entities, which allows the function to actually 
		// work.
		if (firstExecution){
			with(_entityID){
				object_set_next_state(state_cutscene_move);
				targetX =	_x;
				targetY =	_y;
				moveSpeed = _moveSpeed;
				direction = point_direction(x, y, _x, _y);
			}
			firstExecution = false;
		}
		
		// For each call to this instruction, a check will be performed to see if the entity has reached
		// the required position or not, but this only applies if the instruction is set to wait for the
		// entity to actually reach their target position. Otherwise, the cutscene will simply move onto
		// the next available instruction in the list.
		var _positionReached = false;
		with(_entityID) {_positionReached = (x == _x && y == _y);}
		if (!_waitForEntity || _positionReached) {cutscene_end_instruction(!_waitForEntity);}
	}
	
	/// @description A variation on the position manipulation of a given entity; only this time it does
	/// so instantaneously instead of using the entity's built-in automatic movement state to do so. After
	/// moving the desired entity, the cutscene will instantly move onto its next available instruction.
	/// @param entityID
	/// @param x
	/// @param y
	cutscene_set_entity_position = function(_entityID, _x, _y){
		with(_entityID){
			x = _x;
			y = _y;
		}
		cutscene_end_instruction(true);
	}
	
	/// @description A function that allows a given entity to be granted temporary persistent during a
	/// cutscene's execution. This allows the cutscene to transition to different rooms while also carrying
	/// over objects that are still required for the scene to play out properly. After this function, the
	/// cutscene will instantly move onto the next scene instruction during the same frame.
	/// @param id
	cutscene_mark_entity_persistent = function(_id){
		// Don't allow the player object to be marked for persistence since they're already a persistent
		// object by default. Otherwise, their persistence will be accidentally cleared by the cutscene
		// manager once a given cutscene ends.
		if (_id == PLAYER) {return;}
		
		// If the ID provided isn't the player's instance ID, the temporary persistence of the object will
		// be applied and they will be added to the list that tracks entities that have been set to
		// temporarily persistent by the cutscene manager.
		if (ds_list_find_index(entityTempPersistence, _id) == -1){
			ds_list_add(entityTempPersistence, _id);
			with(_id) {persistent = true;}
		}
		cutscene_end_instruction(true);
	}
	
	/// @description Assigns a sprite to an entity; with a unique animation speed that can be supplied,
	/// but it has a default multiplier value of one. After assigning the sprite to the entity, the
	/// next instruction will begin being processed if one exists.
	/// @param id
	/// @param spriteIndex
	/// @param animSpeed
	cutscene_set_entity_sprite = function(_id, _spriteIndex, _animSpeed = 1){
		with(_id) {set_sprite(_spriteIndex, _animSpeed);}
		cutscene_end_instruction(true);
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	/// -- Cutscene Functions for Creating Objects -- /////////////////////////////////////////////////////////////////
	
	/// @description 
	/// @param itemName
	/// @param itemQuantity
	/// @param itemDurability
	cutscene_create_item = function(_itemName, _itemQuantity, _itemDurability){
		
	}
	
	/// @description 
	/// @param 
	cutscene_create_note = function(){
		
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	/// -- Cutscene Functions for Manipulating the Screen Fade -- /////////////////////////////////////////////////////
	
	/// @description Creates an instance of the screen fade object. It can be set to whatever color, speed,
	/// and duration is desired for the current cutscene, while also having a flag set that can wait until
	/// the fade in has completed before moving onto the next seen or if it should just move onto the next
	/// scene instantly.
	/// @param fadeColor
	/// @param fadeSpeed
	/// @param fadeDuration
	/// @param waitForFadeIn
	cutscene_invoke_screen_fade = function(_fadeColor, _fadeSpeed, _fadeDuration, _waitForFadeIn){
		// On the first execution of the instruction, the screen fade is created with the settings that
		// were provided by the scene function's arguments; color, speed of the fade in and fade out, and
		// the duration in frames. (1/60th of a real-world second)
		if (firstExecution){
			effect_create_screen_fade(_fadeColor, _fadeSpeed, _fadeDuration);
			firstExecution = false;
		}
		
		// After the screen fade object has been created, the instruction will then begin checking to see
		// if the fade has to wait until its fully opaque or if the cutscene should just move on without
		// any time spent waiting.
		var _fadeComplete = false;
		with(SCREEN_FADE){
			_fadeComplete = (alpha == alphaTarget && alphaTarget == 1);
			show_debug_message(alpha);
		}
		if (!_waitForFadeIn || _fadeComplete) {cutscene_end_instruction(!_waitForFadeIn);}
	}
	
	/// @description Another cutscene instruction that interacts with the screen fading graphical effect.
	/// This instruction will call for the object to fade itself out; regardless of if the duration wasn't
	/// reached yet OR if the screen fade was set to remain opaque for an indefinite amount of time.
	/// @param waitForFadeOut
	cutscene_end_screen_fade = function(_waitForFadeOut){
		if (firstExecution){
			with(SCREEN_FADE) {fadeDuration = 0;}
			firstExecution = false;
		}
		if (!_waitForFadeOut || SCREEN_FADE == noone) {cutscene_end_instruction(!_waitForFadeOut);}
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}

#endregion

#region Global functions related to obj_cutscene_manager

/// @description A global function that tells the cutscene manager to begin its execution process; using
/// the list of instructions AND the starting index provided to the argument by whatever called this
/// functions. (Ex. The player colliding with a cutscene trigger, interacting with certain objects, etc.)
/// @param triggerID
/// @param sceneInstructions
/// @param startingIndex
function cutscene_activate(_triggerID, _sceneInstructions, _startingIndex){
	with(CUTSCENE_MANAGER){
		// Prevent another cutscene from being activated while another is currently executing. Otherwise,
		// store the instance ID for the trigger and begin setting up the manager for playing out the scene.
		if (isCutsceneActive) {return;}
		triggerID = _triggerID;
		
		// Since this is a cutscene being executed, setting the game state to "Cutscene" will allow other
		// objects to easily know that a cutscene is in fact occurred, and to disable/enable certain parts
		// of their code accordingly.
		GAME_SET_STATE(GameState.Cutscene);
		
		// Loop through every currently existing entity and add their three state variables to an
		// array that is then stored within the cutscene manager's entity state storage map.
		var _entityStates = entityStates;
		with(par_dynamic_entity){
			ds_map_add(_entityStates, id, [curState, nextState, lastState]);
			curState = NO_STATE;
			nextState = NO_STATE;
			lastState = NO_STATE;
		}
		
		// Pass over the index value for the ds_list of instructions, which is stored on the trigger object
		// that the player collided with the activate said cutscene. Then, set the proper starting index
		// to what is needed and set the flags for the cutscene's activity state AND the instruction
		// function's initial execution to "true".
		sceneInstructions = _sceneInstructions;
		currentSceneIndex = _startingIndex;
		isCutsceneActive = true;
		firstExecution = true;
		
		// Grabs the index that points to the first function to call in the cutscene's instruction list
		// so that execution of the scenes can actually begin. Otherwise, the game would softlock waiting
		// for a function index that was never actually set in the required variable.
		instructionFunction = method_get_index(sceneInstructions[| currentSceneIndex][0]);
	}
}

#endregion