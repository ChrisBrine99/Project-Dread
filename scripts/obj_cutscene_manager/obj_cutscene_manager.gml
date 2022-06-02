/// @description Insert summary of this file here.

#region Initializing any macros that are useful/related to obj_cutscene_manager

// Macros that allows the cutscene functions to be referenced by objects that store the scene instructions
// for their specific cutscenes. (Ex. triggers will store cutscenes on themselves until a collision with 
// the player causes them to transfer the instructions onto the cutscene manager)
#macro	CUTSCENE_WAIT					CUTSCENE_MANAGER.cutscene_wait
#macro	CUTSCENE_JUMP_INDEX				CUTSCENE_MANAGER.cutscene_jump_to_index
#macro	CUTSCENE_PLAY_SOUND				CUTSCENE_MANAGER.cutscene_play_sound
#macro	CUTSCENE_PLAY_SOUND_AT			CUTSCENE_MANAGER.cutscene_play_sound_at
#macro	CUTSCENE_ADD_TEXTBOX_TEXT		CUTSCENE_MANAGER.cutscene_add_textbox_text
#macro	CUTSCENE_ADD_TEXTBOX_DECISION	CUTSCENE_MANAGER.cutscene_add_textbox_decision
#macro	CUTSCENE_SET_TEXTBOX_TO_CLOSE	CUTSCENE_MANAGER.cutscene_set_textbox_to_close
#macro	CUTSCENE_SHOW_TEXTBOX			CUTSCENE_MANAGER.cutscene_show_textbox
#macro	CUTSCENE_ASSIGN_ENTITY_STATE	CUTSCENE_MANAGER.cutscene_assign_entity_state
#macro	CUTSCENE_MOVE_ENTITY_POSITION	CUTSCENE_MANAGER.cutscene_move_entity_to_position
#macro	CUTSCENE_SET_ENTITY_POSITION	CUTSCENE_MANAGER.cutscene_set_entity_position

#endregion

#region Initializing any globals that are useful/related to obj_cutscene_manager
#endregion

#region	The main object code for obj_cutscene_manager

function obj_cutscene_manager() constructor{
	// Much like Game Maker's own object_index variable, this will store the unique ID value provided to this
	// object by Game Maker during runtime; in order to easily use it within a singleton system.
	object_index = obj_cutscene_manager;
	
	// 
	isCutsceneActive = false;
	
	// 
	sceneInstructions = noone;
	instructionFunction = noone;
	currentSceneIndex = 0;
	
	// 
	firstExecution = false;
	
	// 
	entityStates = ds_map_create();
	
	// 
	waitTimer = 0;
	
	// 
	soundID = NO_SOUND;
	
	/// @description Code that should be placed into the "Step" event of whatever object is controlling
	/// obj_cutscene_manager. In short, it will execute the current scene instruction's function until that
	/// instruction meets the requirements to move onto the next instruction; until the cutscene itself
	/// has completed its execution.
	step = function(){
		if (isCutsceneActive) {script_execute_ext(instructionFunction, sceneInstructions[| currentSceneIndex], 1);}
	}
	
	/// @description
	cleanup = function(){
		ds_map_destroy(entityStates);
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
			GAME_SET_STATE(GAME_STATE_PREVIOUS);
			isCutsceneActive = false;
			
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
	
	/// @description An extremely simple instruction that will instantly jump the cutscene to a given index
	/// that is found within the list. To prevent errors, it will clamp the value to be between 0 and the
	/// size of the instruction list. After that, the cutscene's end instruction is called which will set
	/// the index properly while also moving onto executing that instruction.
	/// @param index
	cutscene_jump_to_index = function(_index){
		_index = clamp(_index, 0, ds_list_size(sceneInstructions) - 1);
		cutscene_end_instruction(true, _index);
	}
	
	/// @description Another very simple but incredibly versatile function that will pause the cutscene's
	/// execution of further instructions until AFTER the variable "waitTimer" contains a value that is
	/// greater than the amount of units to wait. (A "unit" is equal to 1/60th of a real-world second)
	/// @param units
	cutscene_wait = function(_units){
		waitTimer += global.deltaTime; // Increment based on delta time for frame-independent timing.
		if (waitTimer >= _units) {cutscene_end_instruction(false);}
	}
	
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
	
	/// @description Adds a new text data struct to the textbox's ds_list that it will work through when
	/// it is set to begin executing on said data. It will simply call the "textbox_add_text_data" function
	/// since that will already handle everything on the textbox side; moving onto the next instruction
	/// instantly after the data has been added.
	/// @param text
	/// @param actor
	/// @param portraitIndex
	/// @param textXScale
	/// @param textYScale
	cutscene_add_textbox_text = function(_text, _actor = Actor.NoActor, _portraitIndex = -1, _textXScale = 1, _textYScale = 1){
		textbox_add_text_data(_text, _actor, _portraitIndex, _textXScale, _textYScale);
		cutscene_end_instruction(true);
	}
	
	/// @description A cutscene instruction that will add a new decision option to the newest available
	/// index of text data found within the currently loaded list of text data for the textbox. It will
	/// instantly begin the next available instruction in the list after performing the decision data
	/// addition to the textbox's data.
	/// @param optionText
	/// @param outcomeIndex
	cutscene_add_textbox_decision = function(_optionText, _outcomeIndex){
		textbox_add_decision_data(_optionText, _outcomeIndex);
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
	
	/// @description 
	/// @param entityID
	/// @param stateFunction
	cutscene_assign_entity_state = function(_entityID, _stateFunction){
		with(_entityID) {object_set_next_state(_stateFunction);}
		cutscene_end_instruction(true);
	}
	
	/// @description 
	/// @param entityID
	/// @param x
	/// @param y
	/// @param waitForEntity
	cutscene_move_entity_to_position = function(_entityID, _x, _y, _waitForEntity = true){
		// 
		if (firstExecution){
			with(_entityID) {object_set_next_state(state_cutscene_move);}
			firstExecution = false;
		}
		
		// 
		var _positionReached = false;
		with(_entityID) {_positionReached = (x == _x && y == _y);}
		if (_waitForEntity || _positionReached) {cutscene_end_instruction(!_waitForEntity);}
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
}

#endregion

#region Global functions related to obj_cutscene_manager

/// @description A global function that tells the cutscene manager to begin its execution process; using
/// the list of instructions AND the starting index provided to the argument by whatever called this
/// functions. (Ex. The player colliding with a cutscene trigger, interacting with certain objects, etc.)
/// @param sceneInstructions
/// @param startingIndex
function cutscene_begin_execution(_sceneInstructions, _startingIndex){
	with(CUTSCENE_MANAGER){
		// Prevent another cutscene from being activated while another is currently executing.
		if (isCutsceneActive) {return;}
		
		// Since this is a cutscene being executed, setting the game state to "Cutscene" will allow other
		// objects to easily know that a cutscene is in fact occurred, and to disable/enable certain parts
		// of their code accordingly.
		GAME_SET_STATE(GameState.Cutscene);
		
		// Loop through every currently existing entity and add their three state variables to an
		// array that is then stored within the cutscene manager's entity state storage map.
		var _entityStates = entityStates;
		with(par_dynamic_entity){
			ds_map_add(_entityStates, id, [curState, nextState, lastState]);
			// After adding the state values to the storage map, set all the state variables to NO_STATE to
			// halt any execution of current states for the duration of the cutscene's execution.
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
		
		// 
		instructionFunction = method_get_index(sceneInstructions[| currentSceneIndex][0]);
	}
}

#endregion