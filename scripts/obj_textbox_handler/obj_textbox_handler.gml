/// @description A script file containing all the code and logic for the game's textbox.

#region Initializing any macros that are useful/related to obj_textbox_handler

// Macros that store the "dimensions" of the textbox, which is actually just the width and height
// for the surface that all text is rendered onto. The actual background is determined by these
// values along with adjustments to provide some empty space between the edges and the text.
#macro	TEXTBOX_WIDTH				280
#macro	TEXTBOX_HEIGHT				36

// The first macro determines how many pixels there are on the left and right edges of the surface
// that the characters are rendered onto. The second one determines how long a single line of text
// can be on said surface in pixels. These values don't factor in the outlining of the text.
#macro	TEXT_X_BORDER				2
#macro	LINE_MAX_WIDTH				274

// Macros that contain the characters that are used to determine when line width checks need to occur
// and when additional data like colors need to be parsed out of the text and applied to the characters
// after said color data.
#macro	CHAR_PARSE_COLOR			"*"
#macro	CHAR_RESET_COLOR			"#"
#macro	CHAR_SPACE					" "
#macro	CHAR_HYPHEN					"-"

// Macros that store the names used for each given inner and outer color pairing that can be used to
// display a given region of text in a color different from the default white and gray.
#macro	BLUE						"blue"
#macro	GREEN						"green"
#macro	RED							"red"
#macro	YELLOW						"yellow"
#macro	GRAY						"gray"

// The limit of stored buffers for text that had been displayed previously on the textbox. Once this limit
// is reached, the oldest text buffer log is removed from memory to make room for each subsequently added 
// text log buffer.
#macro	TEXT_LOG_LIMIT				50

// The playback speed of the textbox's scrolling effect sound. Since once per second is a value of 60 in
// this game engine, the interval is set to 10 times every second, and then the speed of text set by the
// user is applied to that base value to determine the final interval speed.
#macro	SCROLL_SOUND_INTERVAL		6 * TEXT_SPEED

// Stores the anchor names as macros to avoid typos when referencing the control information stored in
// those anchors.
#macro	TEXTBOX_MAIN_INFO			"main"
#macro	TEXTBOX_EXTRA_INFO			"extras"

#endregion

#region	Initializing any enumerators that are useful/related to obj_textbox_handler

/// @description Stores the ID values for each unique actor in the game, which will then point to a
/// struct containing the name, color, and portrait data for said actor whenever the values are used
/// in tandem with the function "actor_get_data".
enum Actor{
	None,		// Provides the look for the default textbox.
	Claire,
}

#endregion

#region Initializing any globals that are useful/related to obj_textbox_handler
#endregion

#region	The main object code for obj_textbox_handler

function obj_textbox_handler() constructor{
	// Much like Game Maker's own x and y variables, these store the current position of the camera within 
	// the current room. By default they are always set to a value of zero.
	x = 0;
	y = 0;
	
	// Much like Game Maker's own id variable for objects, this will store the unique ID value given to this
	// singleton, which is a value that is found in the "obj_controller_data" script with all the other
	// macros and functions for handling singleton objects.
	id = TEXTBOX_HANDLER_ID;
	
	// 
	initialY = 0;
	targetY = 0;
	
	// Borrows the same three variables that the dynamic entities use for their state machines to
	// mimic that state machine system, but for the textbox instead of an object in the world. The
	// "curState" is updated at the end of the frame to whatever the value of the "nextState" variable
	// is set to during that frame.
	curState = NO_STATE;
	lastState = NO_STATE;
	nextState = NO_STATE;
	
	// A flag that can easily be used to determine if the textbox is actively processing data or
	// not. The second variable simply determines the overall opacity of the textbox relative to
	// their own alpha values (If they have unique alpha values).
	isTextboxActive = false;
	alpha = 0;
	
	// 
	decisionWindowAlpha = 0;
	curOption = -1;
	
	// Handles the auto scrolling of the various menu-like elements of the textbox: the log and
	// the player decision window. Holding down one of the cursor movement keys will cause the
	// position of said cursor to update at regular intervals based on the "cursorTimer" variable.
	isAutoScrolling = false;
	cursorTimer = 0;
	
	// 
	prevPlayerState = array_create(3, NO_STATE);
	
	// Important variables for processing and managing the textbox data that will end up displaying
	// so the user can read what each textbox contains. The first variable stores a list that holds
	// all the textboxes that are currently queued up; their text and actor data--along with any
	// optional effects that are active for it. The second variable is a struct that contains the
	// data for the currently active textbox; allowing for quicker access to the data for rendering.
	// The third variable is the current index into the textbox list that is being processed, and
	// the remaining variable stores what index to jump to for the next textbox.
	textboxData = ds_list_create();
	textbox = {
		fullText :			"",
		textSpeed :			1,
		textScale :			1,
		actorID :			Actor.None,
		portraitIndex :		0,
		
		soundData :			noone,
		shakeData :			noone,
		
		playerChoices :	   -1,
		closeTextbox :		false,
	};
	index = 0;
	targetIndex = 0;
	
	// Much like above, these variables all have the role of processing and managing a specific
	// group of data for the textbox; just for the actor data instead of the textbox data like
	// said above variables. There is a struct that stores information for the current actor
	// in use by the textbox handler, and a list storing all the required data. There is also
	// a boolean that will cause the textbox to perform its opening animation again to mask
	// the actor data being swapped.
	actorData = ds_map_create();
	actor = {
		nameString :		"",
		nameWidth :			0,
		portrait :			NO_SPRITE,
		backgroundColor :	HEX_WHITE,
	};
	actorSwap = false;
	
	// Struct that handles the processing and rendering of the textbox's logging system. It will
	// store the surfaces that held the old text for each textbox in its own ds_list, so it can be
	// retrieved again for the player to view if they desire.
	logger = {
		// The variables that handle the displaying and storing of all currently logged text. The
		// first list will store the buffers containing that old text data, the second will hold
		// pointers to the required actor data assocaiated with those text logs, and the final
		// variable stores the 3 surfaces that are used to render the currently viewable logged
		// text.
		savedText : ds_list_create(),
		actorData : ds_list_create(),
		surfTextLogs : array_create(3, -1),
		
		// The view offset referes to what three pieces of logged text are currently on-screen for the
		// player to view. They can change this viewable region by using the "menu up" and "menu down"
		// inputs. The alpha is the current opacity for the text log itself.
		viewOffset : 0,
		alpha : 0,
		
		/// @description Code that is called from the "draw_gui" function of obj_textbox_handler. 
		/// It is responsible for displaying the currently viewable region of the textbox log; along
		/// with any background elements for the log area.
		/// @param {Real}	cameraWidth
		/// @param {Real}	cameraHeight
		draw_gui : function(_cameraWidth, _cameraHeight){
			if (alpha == 0) {return;}
			
			// If there is no logged text currently, text will be displayed telling the player that
			// and no other elements will be shown due to the "return" statement at the branch.
			if (ds_list_size(savedText) == 0){
				draw_sprite_ext(spr_rectangle, 0, 0, 0, _cameraWidth, _cameraHeight, 0, c_black, alpha * 0.75);
				
				shader_set_outline(font_gui_medium, RGB_DARK_GRAY);
				draw_set_text_align(fa_center, fa_middle);
				draw_text_outline(_cameraWidth / 2, _cameraHeight / 2, "No Logged Text", HEX_GRAY, RGB_DARK_GRAY, alpha);
				draw_reset_text_align();
				shader_reset();
				return;
			}
			
			// The rendering functions for the background, surfaces, and actor data all use these
			// pieces of data, so they'll be stored in local variables to allow easy adjustment of
			// the values.
			var _numberDrawn = min(3, ds_list_size(savedText));
			var _spacing = (TEXTBOX_HEIGHT + 18);
			
			// Call the functions that are responsible for rendering the background, logged text
			// surfaces, and actor names, respectively.
			draw_log_background(_numberDrawn, _cameraHeight - 15, _spacing, _cameraWidth, _cameraHeight);
			draw_logged_surfaces(_numberDrawn, _cameraHeight - 55, _spacing);
			draw_logged_actor_names(_numberDrawn, _cameraHeight - 55, _spacing);
		},
		
		/// @description Code that is called from the "cleanup" function of obj_textbox_handler. 
		/// If is responsible for displaying the currently viewable region of the textbox log; along
		/// with any background elements for the log area.
		cleanup : function(){
			// Delete all the existing log text buffers from memory before destroy the list that stored
			// the pointers to those buffers. Otherwise, the memory will remain allocated until the game
			// is closed or crashed from the leak. The actor data doesn't need its pointers handled since
			// the textbox itself manages those.
			var _length = ds_list_size(savedText);
			for (var i = 0; i < _length; i++) {buffer_delete(savedText[| i]);}
			ds_list_destroy(savedText);
			ds_list_destroy(actorData);
			
			// Free the surfaces if they still exist within VRAM. If they happened to have already been
			// flushed from memory before this code is executed, the non-existent surface(s) are skipped.
			for (var j = 0; j < 3; j++){
				if (surface_exists(surfTextLogs[j])) {surface_free(surfTextLogs[j]);}
			}
		},
		
		/// @description Handles drawing the background elements for the text log's background. It handles
		/// the black translucent backing, the feathered lines seperating the text logs, and the original
		/// background colors for the viewable textbox logs that is feathered as well.
		/// @param {Real}	numberDrawn
		/// @param {Real}	startY
		/// @param {Real}	spacing
		draw_log_background : function(_numberDrawn, _startY, _spacing, _cameraWidth, _cameraHeight){
			draw_sprite_ext(spr_rectangle, 0, 0, 0, _cameraWidth, _cameraHeight, 0, c_black, alpha * 0.75);
			
			// Displaying the white dividing lines between the viewable textbox logs. There will always be
			// one more line than there is viewable text because there needs to be a divider between the
			// first text log and the control information at the bottom of the screen.
			shader_set(shd_feathering);
			feathering_set_bounds(120, 0, _cameraWidth - 120, _cameraHeight, 10, 0, _cameraWidth - 10, _cameraHeight);
			var _offsetY = _startY;
			repeat(_numberDrawn + 1){
				draw_sprite_ext(spr_rectangle, 0, 10, _offsetY, _cameraWidth - 20, 1, 0, c_white, alpha);
				_offsetY -= _spacing;
			}
			
			// After all the required dividing lines have been rendered, the backgrounds for each of the
			// viewable text logs will be rendered using their original textbox colors.
			_offsetY = _startY - _spacing + 5;
			for (var i = 0; i < _numberDrawn; i++){
				feathering_set_bounds(100, _offsetY + (_spacing / 2), _cameraWidth - 100, _offsetY + (_spacing / 2), 0, _offsetY, _cameraWidth, _offsetY + _spacing);
				draw_sprite_ext(spr_rectangle, 0, 0, _offsetY, _cameraWidth, _spacing, 0, actorData[| i + viewOffset].backgroundColor, alpha * 0.75);
				_offsetY -= _spacing;
			}
			shader_reset();
		},
		
		/// @description Draw the three visible text logs onto the screen; from bottom-to-top based 
		/// on the newest to oldest logged text, respectively.
		/// @param {Real}	numberDrawn
		/// @param {Real}	startY
		/// @param {Real}	spacing
		draw_logged_surfaces : function(_numberDrawn, _startY, _spacing){
			for (var i = 0; i < _numberDrawn; i++){
				if (!surface_exists(surfTextLogs[i])){
					surfTextLogs[i] = surface_create(TEXTBOX_WIDTH, TEXTBOX_HEIGHT);
					buffer_set_surface(savedText[| i + viewOffset], surfTextLogs[i], 0);
				}

				draw_surface_ext(surfTextLogs[i], 20, _startY, 1, 1, 0, c_white, alpha);
				_startY -= _spacing;
			}
		},
		
		/// @description Much like above, the three curruently viewable actor names will be rendered to 
		/// the textbox above the text that was previous said by the respective actor(s). This is draw
		/// from bottom-to-top based on newest to oldest text log; just like the above function.
		/// @param {Real}	numberDrawn
		/// @param {Real}	startY
		/// @param {Real}	spacing
		draw_logged_actor_names : function(_numberDrawn, _startY, _spacing){
			shader_set_outline(font_gui_small, RGB_GRAY);
			var _name = "";	// Stores the name being processed so the list and struct only needs to be accessed once per loop.
			for (var i = 0; i < _numberDrawn; i++){
				_name = actorData[| i + viewOffset].nameString;
				if (_name != "") {draw_text_outline(25, _startY - 10, "-- " + _name + " --", HEX_WHITE, RGB_GRAY, alpha);}
				_startY -= _spacing;
			}
			shader_reset();
		},
		
		/// @description Stores a copy of the text that was being displayed on the textbox so the 
		/// player can optionally view that text again (If it hasn't been too long) by accessing the
		/// textbox log. Also stores a pointer to the actor paired with the newly logged textbox.
		/// @param {Id.Buffer}	buffer
		/// @param {Struct}		actor
		log_text_data : function(_buffer, _actor){
			var _index = ds_list_size(savedText);
			if (_index == TEXT_LOG_LIMIT){ // Remove the oldest logged text when the limit has been reached.
				buffer_delete(savedText[| _index - 1]);
				ds_list_delete(savedText, _index - 1);
			}
			
			// Insert the most recently logged text into the 0th index of the list; pushing 
			// the rest of the data back by one index until whatever was in the 49th element
			// is discarded from memory.
			ds_list_insert(actorData, 0, _actor);
			ds_list_insert(savedText, 0, buffer_create(TEXTBOX_WIDTH * TEXTBOX_HEIGHT * 4, buffer_fixed, 4));
			buffer_copy(_buffer, 0, TEXTBOX_WIDTH * TEXTBOX_HEIGHT * 4, savedText[| 0], 0);
			
			// Copies the buffers at the indexes within the log's view onto the surfaces that
			// show the data stored in said buffers to the player. If this wasn't done, nothing
			// would be update for the player to see unless the surfaces got flushed from memory.
			var _length = min(3, ds_list_size(savedText));
			for (var i = 0; i < _length; i++){
				if (surface_exists(surfTextLogs[i])) {buffer_set_surface(savedText[| i + viewOffset], surfTextLogs[i], 0);}
			}
		}
	};
	
	// Stores either the default or decision state, so the textbox can return to it once the
	// textbox log is closed by the user (Since the textbox can access the log regardless of
	// the state).
	lastStateExt = NO_STATE; 
	
	// Variables for the surface that is used as the canvas to render all of the textbox's text
	// onto. The buffer stores a copy of that texture data in RAM so it can be copied back onto
	// the surface in the event of it being flushed prematurely from VRAM. The alpha determines
	// the overall opacity of the surface independent of the textbox's own alpha.
	surfText = -1;
	surfTextBuffer = buffer_create(TEXTBOX_WIDTH * TEXTBOX_HEIGHT * 4, buffer_fixed, 4);
	surfAlpha = 1;
	
	// Variables that allow the text to have its "typewriter" effect. The first variable is the
	// latest character to be rendered from the effect, the second has its value updated relative
	// to the current text speed--adding a new character to be rendered one it is larger than the
	// "curChar" value and the final variable just stores the numerical value for how many characters
	// there are for the current text.
	curChar = 1;
	nextChar = 1;
	finalChar = 1;
	
	// Variables that allow for the temporary pause (Or skipping of said pause entirely when toggled)
	// of the typewriter effect when punctuation is reached in the text.
	punctuationTimer = 0;
	processPunctuation = false;
	
	// Variables that determine the positional offset on the text surface that the next character
	// in the typewriter effect will be rendered at, as well as the current colors used for that
	// character.
	charOffsetX = 0;
	charOffsetY = 0;
	charColor = HEX_WHITE;
	charOutlineColor = RGB_GRAY;
	
	// Causes the up and down motion of the little "advancement" indicator located in the bottom-right
	// corner of the textbox when it is safe to advance to the next one. I will increase until it hits
	// or surpasses a value of 2; resetting back to zero after that happens.
	indicatorOffset = 0;
	
	// 
	canProcessText = false;
	
	// 
	soundTimer = 0;
	
	// 
	inputAdvance =	false;
	inputLog =		false;
	inputMenuUp =	false;
	inputMenuDown =	false;
	inputSelect =	false;
	inputReturn =	false;
	
	#region Game Maker events as functions
	
	/// @description Code that should be placed into the "Step" event of whatever object is controlling
	/// obj_textbox_handler. In short, it will simply call the state function for the textbox if it is
	/// currently active and has a valid function stored within its "curState" variable.
	step = function(){
		if (isTextboxActive && curState != NO_STATE) {curState();}
	}
	
	/// @description Code that should be placed into the "End Step" event of whatever object is controlling
	/// obj_textbox_handler. In short, it will update the textbox to its next state if a change between
	/// states was set to occur during the "step" event. On top of that, all the additional effects that
	/// occur for a textbox (Sound effect playback/delayed playback, horizontal shaking) will be processed
	/// in this event.
	end_step = function(){
		if (curState != nextState) {curState = nextState;}
		
		// Don't process any of the code below this line if the textbox isn't currently active. Otherwise,
		// the scrolling sound would be able to play without any textbox being present if the  "canProcessText" 
		// bool is ever set to true.
		if (!isTextboxActive) {return;}
		
		// Handling the playback of the textbox's scrolling sound effect. It will play it at a set amount of
		// times per second that will very roughly match the speed of the characters appearing on screen.
		// Also, the bool for enabling that process is determined here, since the check for playing the sound
		// is that same as the check for display characters.
		canProcessText = (curChar <= finalChar && logger.alpha == 0);
		if (canProcessText && punctuationTimer <= 0){
			soundTimer -= DELTA_TIME;
			if (soundTimer <= 0){
				audio_play_sound_ext(snd_textbox_scroll, GET_UI_VOLUME * (0.08 + random_range(-0.02, 0.02)), 1.5);
				soundTimer = SCROLL_SOUND_INTERVAL;
			}
		}
		
		// In order to allow for a textbox's sound to be delayed, the timer for that delayed
		// playback is counted down here by access the "soundData" struct that is stored inside
		// the current textbox's data struct. Once that delay value reaches 0, the sound will be
		// played and the "index" will be set to NO_SOUND to prevent further playback.
		with(textbox.soundData){
			if (index != NO_SOUND){
				delay -= DELTA_TIME;
				if (delay <= 0){
					audio_play_sound_ext(index, volume, pitch);
					index = NO_SOUND;
				}
			}
		}
		
		// Handling the optional horizontal shaking effect that can occur for a given textbox. It
		// will slowly lose its intensity over the course of its "duration" value (Measured in 1/60th
		// of every real-world second being equal to a value of 1 for the variable). Once the power
		// of the shake has reached zero, it will no longer occur and this code will no longer run.
		with(textbox.shakeData){
			if (curPower > 0){
				curPower -= initialPower / duration * DELTA_TIME;
				other.x = ((camera_get_width() - TEXTBOX_WIDTH) / 2) + irandom_range(-curPower, curPower);
			}
		}
	}
	
	/// @description Code that should be placed into the "Draw GUI" event of whatever object is controlling
	/// obj_textbox_handler. In short, it will handle the rendering of the components that make up the
	/// textbox by calling their respective functions if the textbox is currently visible (alpha > 0)
	/// or toggled to an active state.
	/// @param {Real}	cameraWidth
	/// @param {Real}	cameraHeight
	draw_gui = function(_cameraWidth, _cameraHeight){
		if (!isTextboxActive || alpha == 0) {return;}
		
		// Drawing the "background" information for the currently viewable textbox data. The color of
		// these elements being dictated on a per-actor basis, and things like the portrait area and
		// namespace only being optional features to include.
		render_textbox_background(x - 15, y - 8, alpha);
		render_actor_information(x, y, alpha, textbox.portraitIndex);
		
		// Displaying the text advancement indicator; letting the player know that there is no more
		// text to be displayed onto the textbox, so they can safely advance without missing information.
		if (curChar > finalChar){
			draw_sprite_ext(spr_advance_indicator, 0, x + TEXTBOX_WIDTH - 2, y + TEXTBOX_HEIGHT - 2 - floor(indicatorOffset), 1, 1, 0, c_white, surfAlpha * alpha);
			indicatorOffset += 0.05 * DELTA_TIME;
			if (indicatorOffset >= 2) {indicatorOffset = 0;}
		}

		// Drawing the field that contains the current text information for the textbox. First, a 
		// check is performed to see if the surface used to contain that text exists; it's created if 
		// it was flushed from the GPU for whatever reason. Then, that surface is updated if there is
		// still additional text to display. Finally, that surface is rendered at an opacity relative
		// to the textbox itself and the surface's own alpha value.
		if (!surface_exists(surfText)){
			surfText = surface_create(TEXTBOX_WIDTH, TEXTBOX_HEIGHT);
			buffer_set_surface(surfTextBuffer, surfText, 0);
		}
		if (canProcessText) {update_text_surface(textbox.fullText);}
		draw_surface_ext(surfText, x, y, 1, 1, 0, c_white, surfAlpha * alpha);
		
		// Drawing the decision window and its available options whenever the alpha level for it is
		// greater than a value of zero, which would be fully transparent.
		if (decisionWindowAlpha > 0){
			draw_decision_window_background(_cameraWidth, _cameraHeight);
			draw_decision_window_choices(_cameraWidth, _cameraHeight);
		}
		
		// Draw the textbox log. If it has an alpha value of zero it will automatically have its
		// rendering skipped. Otherwise, it will be drawn overtop of the rest of the textbox.
		with(logger) {draw_gui(_cameraWidth, _cameraHeight);}
	}
	
	/// @description Code that should be placed into the "Clean Up" event of whatever object is controlling
	/// obj_textbox_handler. In short, it will clear out any data structures and struct objects created
	/// by the textbox handler before itself is removed from memory; preventing any lost pointers and
	/// memory leaks.
	cleanup = function(){
		// Remove all the structs from within the list storing currently existing textbox data; deleting the
		// structs contained within each of those structs before clearing out that main struct. After that,
		// the list is cleared from memory.
		var _length = ds_list_size(textboxData);
		for (var i = 0; i < _length; i++){
			with(textboxData[| i]){
				delete soundData;
				delete shakeData;
				ds_list_destroy(playerChoices);
			}
			delete textboxData[| i];
		}
		ds_list_destroy(textboxData);
		
		// Much like above, the actor data will have its structs cleared from memory before the data structure
		// storing those structs is cleared from memory.
		var _key = ds_map_find_first(actorData);
		while(!is_undefined(_key)){
			delete actorData[? _key];
			_key = ds_map_find_next(actorData, _key);
		}
		ds_map_destroy(actorData);
		
		// Delete both structs that stored redundant data from the current textbox and actor that were
		// being utilized by the handler for rendering and processing.
		delete textbox;
		delete actor;
		
		// Call the cleanup method found inside the logger struct, which will handle the cleaning up of
		// allocated memory for buffers and surfaces automatically. Then, delete that struct after the
		// cleaning has been executed.
		with(logger) {cleanup();}
		delete logger;
		
		// Clears out any control data and anchors that were added in by the textbox handler.
		control_info_clear_data();
		
		// Finally, free the surface if it still exists, (If it doesn't exist it has already been flushed
		// from memory, so freeing it will cause a crash) and delete the buffer that stored an identical
		// copy to use in the case of the surface being freed prematurely.
		if (surface_exists(surfText)) {surface_free(surfText);}
		buffer_delete(surfTextBuffer);
	}
	
	#endregion
	
	#region Player input function
	
	/// @description Gathers input from the player's currently active input method (A supported gamepad or 
	/// the computer's keyboard by default) and stores the states for all the required inputs into boolean
	/// variables, which are then referenced throughout the textbox's state logic to determine what needs
	/// to be processed for the current frame.
	get_input = function(){
		if (GAMEPAD_IS_ACTIVE){ // Getting input from the detected and in-use gamepad.
			var _gamepadID =	GAMEPAD_DEVICE_ID;
			inputAdvance =		gamepad_button_check_pressed(_gamepadID, PADCODE_ADVANCE);
			inputLog =			gamepad_button_check_pressed(_gamepadID, PADCODE_LOG);
			inputSelect =		gamepad_button_check_pressed(_gamepadID, PADCODE_SELECT);
			inputReturn =		gamepad_button_check_pressed(_gamepadID, PADCODE_RETURN);
			inputUp =			gamepad_button_check(_gamepadID, PADCODE_MENU_UP);
			inputDown =			gamepad_button_check(_gamepadID, PADCODE_MENU_DOWN);
			// TODO -- Add ability to select options by using the left or right thumbsticks.
		} else{ // Getting input from the default device keyboard.
			inputAdvance =		keyboard_check_pressed(KEYCODE_ADVANCE);
			inputLog =			keyboard_check_pressed(KEYCODE_LOG);
			inputSelect =		keyboard_check_pressed(KEYCODE_SELECT);
			inputReturn =		keyboard_check_pressed(KEYCODE_RETURN);
			inputUp =			keyboard_check(KEYCODE_MENU_UP);
			inputDown =			keyboard_check(KEYCODE_MENU_DOWN);
		}
	}
	
	#endregion
	
	#region Main textbox states (Advancing through text, player choice logic, etc.) 
	
	/// @description The textbox's "default" state, where the player is able to advance onto the next
	/// textbox OR completely skip over the typerwriter effect by pressing that same "advance" key before
	/// the effect has been completed. From there, it is determined whether the next textbox in the list
	/// will be used, if there needs to be a choice by the player, of if the textbox should close outright.
	state_default = function(){
		get_input(); // Before any logic is processed, get input from the user.
		
		// Showing the textbox log, which will allow the player to see text that was previously shown on 
		// the textbox. Pressing the input to view said log will cause its opening animation to play and
		// whatever state the log was opened from to be stored in a variable for use when closing the log.
		if (inputLog){
			object_set_next_state(state_animation_open_text_log);
			lastStateExt = state_default;
			return; // Exit the state function early.
		}
		
		// Pressing the textbox advance key, which can cause two different outcomes to occur: skipping the
		// typewriter animation effect for the text OR closing the current textbox in order to open the next
		// one; closing the textbox if no more remain or the textbox was signaled to close prematurely by
		// the current index of textbox data.
		if (inputAdvance){
			if (nextChar <= finalChar){ // Skipping the typewriter animation.
				processPunctuation = false;
				nextChar = finalChar + 1;
			} else{ // Determine what to do for closing the current textbox.
				if (textbox.closeTextbox || index == ds_list_size(textboxData) - 1){
					object_set_next_state(state_animation_close_textbox);
					control_info_set_alpha_target(0, 0.075);
					targetIndex = -1; // Tells the textbox that it should close after completing the animation.
				} else{
					// UNIQUE CASE -- If there is player choice data found within the list for such data
					// that exists within each textbox data struct, the textbox will enter its decision
					// state; having the next index determined relative to the choice made by the player.
					if (ds_list_size(textbox.playerChoices) > 1){
						object_set_next_state(state_animation_open_decision_window);
						return;
					}
					
					// STANDARD CASE -- Check if an actor swap needs to occur between the current and the
					// next textbox. An actor swap will play the closing animation without actually closing
					// the textbox. Meanwhile, the non-actor swap will fade out the old text before moving
					// onto the next textbox data is displayed.
					actorSwap = (textbox.actorID != textboxData[| index + 1].actorID);
					if (!actorSwap) {object_set_next_state(state_animation_fade_previous_text);}
					else {object_set_next_state(state_animation_close_textbox);}
					targetIndex = index + 1;
				}
			}
		}
	}
	
	/// @description 
	state_select_decision = function(){
		get_input(); // Before any logic is processed, get input from the user.
		
		// Showing the textbox log, which will allow the player to see text that was previously shown on 
		// the textbox. Pressing the input to view said log will cause its opening animation to play and
		// whatever state the log was opened from to be stored in a variable for use when closing the log.
		if (inputLog){
			object_set_next_state(state_animation_open_text_log);
			lastStateExt = state_select_decision;
			return; // Exit the state function early.
		}
		
		// 
		if (inputSelect){
			audio_play_sound_ext(snd_gui_select, 100, GET_UI_VOLUME, 1);
			object_set_next_state(state_animation_close_decision_window);
			var _playerChoices = textbox.playerChoices[| curOption];
			event_set_flag(_playerChoices.eventFlag, _playerChoices.flagState);
			targetIndex = _playerChoices.outcomeIndex;
			return; // Exit the state function prematurely.
		}
		
		// 
		var _movement = (inputDown - inputUp);
		if (_movement != 0){
			cursorTimer -= DELTA_TIME;
			if (cursorTimer <= 0){
				if (!isAutoScrolling){ // Initial button hold has a longer interval between option switches.
					isAutoScrolling = true;
					cursorTimer = 30;
				} else{ // Shorten the timer between option switches when the cursor is held.
					cursorTimer = 10;
				}
				
				// Update the position of the cursor, but prevent it from surpassing the valid index bounds 
				// of the list of available choices to the player.
				var _listSize = ds_list_size(textbox.playerChoices);
				var _curOption = curOption;
				curOption += _movement;
				if (curOption >= _listSize) {curOption = _listSize - 1;}
				else if (curOption < 0) {curOption = 0;}
				
				// Only play the sound for the "cursor" moving to another decision if the movement was
				// actually able to alter the value of "curOption". Otherwise, the sound would play when
				// there isn't any actual movement in the menu.
				if (_curOption != curOption) {audio_play_sound_ext(snd_gui_move, 100, GET_UI_VOLUME * 0.5, 1);}
			}
		} else{ // Reset the cursor timer back down to zero if the movement buttons are released before it hits zero again.
			isAutoScrolling = false;
			cursorTimer = 0;
		}
	}
	
	/// @description The state for the textbox whenever the player is looking at the previous textbox
	/// text that was stored within the logger object struct. It handles exiting the state by pressing
	/// the "return" input, and shifting through the logged text with the "up" and "down" menu inputs.
	state_textbox_log = function(){
		get_input(); // Before any logic is processed, get input from the user.
		
		// Exit the textbox log state to return to whatever the previous state the textbox was in. This
		// could be one of two outcomes: the default textbox state OR the player choice state.
		if (inputReturn){
			object_set_next_state(state_animation_close_text_log);
			logger.viewOffset = 0; // Reset the offset to show the most recent logged text.
			return;
		}
		
		// Handling cursor movement, which can occur automatically in either direction if said direction
		// is held down. If that occurs, the view offset of the text log will update until it reaches
		// the upper limit or a value of zero; with no rollover like how a menu's cursor functions.
		var _movement = (inputDown - inputUp);
		if (_movement != 0){
			cursorTimer -= DELTA_TIME;
			if (cursorTimer <= 0){
				if (!isAutoScrolling){ // Initial button hold has a longer interval between option switches.
					isAutoScrolling = true;
					cursorTimer = 30;
				} else{ // Shorten the timer between option switches when the cursor is held.
					cursorTimer = 10;
				}
				
				// Jump into scope of the logger struct, which is responsible for processing the cursor input
				// into moving and updating the currently in-view text logs.
				with(logger){
					// Lock the view offset within the range of 0 to however many text logs currently exist
					// (Up to a limit of 50 elements). Movement is inverted to match how the log is shown.
					var _viewOffset = viewOffset;
					var _size = ds_list_size(actorData);
					if (_movement == -1 && viewOffset < _size - 3) {viewOffset++;}
					else if (_movement == 1 && viewOffset > 0) {viewOffset--;}
					
					// Refresh the surfaces that display the currently in-view logged text if the view offset 
					// changed because of player input. If no view offset change happened, no surfaces will
					// be updated.
					if (_viewOffset != viewOffset){
						var _length = min(3, _size);
						for (var i = 0; i < _length; i++){
							if (!surface_exists(surfTextLogs[i])) {surfTextLogs[i] = surface_create(TEXTBOX_WIDTH, TEXTBOX_HEIGHT);}
							buffer_set_surface(savedText[| i + viewOffset], surfTextLogs[i], 0); 
						}
					}
				}
			}
		} else{ // Reset the cursor timer back down to zero if the movement buttons are released before it hits zero again.
			isAutoScrolling = false;
			cursorTimer = 0;
		}
	}
	
	#endregion
	
	#region Animation states (Opening, closing, fading out old text, changing actors, etc.) 
	
	/// @description The textbox's opening animation, which causes it to slide onto the screen from the
	/// bottom; fading itself in as that position translation occurs. Once the animation has been finished,
	/// the textbox's state is set to its "default" where player input can be processed.
	state_animation_open_textbox = function(){
		alpha = value_set_linear(alpha, 1, 0.05);
		y = value_set_relative(y, targetY, 0.15);
		if (alpha == 1 && y < targetY + 0.5){
			object_set_next_state(state_default);
			y = targetY;
		}
	}
	
	/// @description The textbox's closing animation, which simply fades the textbox and all of its contents
	/// out of visibility. Once that is done, one of two different things can occur: the textbox can be
	/// deactivated or the opening animation can be performed again. These outcomes can occurs when the
	/// textbox is set to be closed or if an actor swap has occurred between this and the previous textbox,
	/// respectively.
	state_animation_close_textbox = function(){
		alpha = value_set_linear(alpha, 0, 0.075);
		if (alpha == 0){
			if (targetIndex == -1){ // Closes the textbox.
				textbox_deactivate();
			} else{ // Prepares the next textbox; playing the opening animation again.
				object_set_next_state(state_animation_open_textbox);
				prepare_next_textbox(targetIndex, true);
				y = initialY;
			}
		}
	}
	
	/// @description A simplified transition animation that fades out the old textbox text before any new
	/// text is rendered onto the screen. It can only occur when a textbox change has occurred, but an
	/// actor swap didn't happen during that change.
	state_animation_fade_previous_text = function(){
		surfAlpha = value_set_linear(surfAlpha, 0, 0.1);
		if (surfAlpha == 0){
			object_set_next_state(state_animation_fade_new_text);
			prepare_next_textbox(targetIndex, true);
		}
	}
	
	/// @description A reverse process compared to the state function above this one; it will fade in the
	/// surface that is responsible for displaying the text contents for the textbox into visibility so it
	/// smoothly transitions between the two textboxes.
	state_animation_fade_new_text = function(){
		surfAlpha = value_set_linear(surfAlpha, 1, 0.1);
		if (surfAlpha == 1) {object_set_next_state(state_default);}
	}
	
	/// @description 
	state_animation_open_decision_window = function(){
		decisionWindowAlpha = value_set_linear(decisionWindowAlpha, 1, 0.1);
		if (decisionWindowAlpha == 1){
			object_set_next_state(state_select_decision);
			initialize_decision_control_info();
			curOption = 0;
		}
	}
	
	/// @description 
	state_animation_close_decision_window = function(){
		decisionWindowAlpha = value_set_linear(decisionWindowAlpha, 0, 0.1);
		if (decisionWindowAlpha == 0){
			object_set_next_state(state_default);
			prepare_next_textbox(targetIndex, true);
			initialize_default_control_info();
		}
	}
	
	/// @description A transition animation for opening the textbox's log. It will smoothly fade it into
	/// visibility until its alpha reaches a value of 1. Once that occurs, the textbox state will switch
	/// to the log state so the player can use inputs to view/close it.
	state_animation_open_text_log = function(){
		var _animationComplete = false;
		with(logger){
			alpha = value_set_linear(alpha, 1, 0.075);
			_animationComplete = (alpha == 1);
		}
		
		if (_animationComplete){
			object_set_next_state(state_textbox_log);
			initialize_log_control_info();
		}
	}
	
	/// @description A reverse process of the textbox log's opening function. It will reduce the alpha
	/// level of said log's graphical interface until it reaches zero. Once that happens, the textbox
	/// will be returned to the state it was in before the log was first opened (Stored within the
	/// "lastStateExt" variable).
	state_animation_close_text_log = function(){
		var _animationComplete = false;
		with(logger){
			alpha = value_set_linear(alpha, 0, 0.075);
			_animationComplete = (alpha == 0);
		}
		
		if (_animationComplete){
			object_set_next_state(lastStateExt);
			if (nextState == state_select_decision)	{initialize_decision_control_info();}
			else if (nextState == state_default)	{initialize_default_control_info();}
		}
	}
	
	#endregion
	
	#region Textbox struct list management functions
	
	/// @description Swaps the data used for the "old" textbox with data found at the new index value;
	/// text data, actor data, new portraits, and so on. It will also clear out the buffer that stored
	/// the characters that are rendered onto the textbox so the new text can be rendered onto it.
	/// @param {Real}	index
	/// @param {Bool}	logText
	prepare_next_textbox = function(_index, _logText = false){
		// 
		if (_logText) {logger.log_text_data(surfTextBuffer, actorData[? textbox.actorID]);}
		buffer_fill(surfTextBuffer, 0, buffer_u32, 0, TEXTBOX_WIDTH * TEXTBOX_HEIGHT * 4);
		if (surface_exists(surfText)) {buffer_set_surface(surfTextBuffer, surfText, 0);}
		
		// Assign the new index value to the variable that determines which textbox struct to pull its
		// data from; allowing new data to be used instead of the old textbox's data.
		index = _index;
		
		// Update the "current textbox" struct with the data that is found in the struct at the current
		// index within the "textboxData" ds_list. Set all of the redundant values to their counterparts
		// for easier access during code execution.
		var _text = textboxData[| index];
		with(textbox){
			fullText =			_text.fullText;
			textSpeed =			_text.textSpeed;
			textScale =			_text.textScale;
			actorID =			_text.actorID;
			portraitIndex =		_text.portraitIndex;
			
			soundData =			_text.soundData;
			shakeData =			_text.shakeData;
			
			playerChoices =		_text.playerChoices;
			closeTextbox =		_text.closeTextbox;
		}
		
		// Only bother updating the current actor data if an actor swap occurred between this and the
		// previous textbox. Otherwise, it would be a waste to fill the struct with the same data it
		// already had for use with the previous textbox.
		if (actorSwap){
			var _actor = actorData[? _text.actorID];
			with(actor){
				nameString =		_actor.nameString;
				portrait =			_actor.portrait;
				backgroundColor =	_actor.backgroundColor;
				
				draw_set_font(font_gui_small); // Ensures string width calculations are correct.
				nameWidth =			string_width(nameString) + 20;
			}
		}
		
		// Reset the character variables that cause the typewriter text effects to even function to begin
		// with. The final character's value for the new text is stored within the "finalChar" variable,
		// so the typerwriter effect knows when it has been completed.
		curChar = 1;
		nextChar = 1;
		finalChar = string_length(_text.fullText);
		
		// Reset the punctuation timer variables to enable punctuation to actually be processed for the
		// new textbox (This is only a possibility if the player skips the typewriter animation).
		punctuationTimer = 0;
		processPunctuation = true;
		
		// Reset the indicator offset so it always starts at the same position when it shows up.
		indicatorOffset = 0;
		
		// Reset the textbox scroll sound effect timer so its initial playback lines up with the text.
		soundTimer = 0;
		
		// Reset character position and color data to their defaults so the new text doesn't begin where
		// the character offset was after the previous textbox's text completed its rendering.
		charOffsetX = 0;
		charOffsetY = 0;
		charColor = HEX_WHITE;
		charOutlineColor = RGB_GRAY;
	}
	
	/// @description Removes all textbox, actor, and surface data from the textbox handler's respective
	/// variables. After cleaning out all that old data, the flag for the textbox's "state" is set to false
	/// and whatever state was currently given to the textbox will be reset to NO_STATE; preventing any
	/// textbox code from running without conversation/actor data available for use.
	textbox_deactivate = function(){
		object_set_next_state(NO_STATE);
		
		// Loop through each textbox data struct; cleaning out the structs and other data within that needs
		// to be freed from memory before said struct's pointer is lost by the "ds_list_clear" function.
		var _cLength = 0;
		var _length = ds_list_size(textboxData);
		for (var i = 0; i < _length; i++){
			with(textboxData[| i]){
				delete soundData;
				delete shakeData;
				
				_cLength = ds_list_size(playerChoices);
				for (var j = 0; j < _cLength; j++){delete playerChoices[| j];}
				ds_list_destroy(playerChoices);
			}
		}
		ds_list_clear(textboxData);
		
		// Removes the now invalid pointers that once pointed to the last textbox's sound and shake structs.
		// Done so GameMaker's garbage collector doesn't see the unused pointer values and think the structs 
		// themselves should still exist as a result.
		with(textbox){
			soundData = noone;
			shakeData = noone;
		}
		
		// Destroy any existing buffers, and then clear out the list that stored said buffers and also clear
		// the list that stored pointers to actor data structs. The logger's surfaces don't need to be touched.
		with(logger){
			_length = ds_list_size(savedText);
			for (var i = 0; i < _length; i++) {buffer_delete(savedText[| i]);}
			ds_list_clear(savedText);
			ds_list_clear(actorData);
		}
		
		// Delete all structs created and stored within the "actorData" ds_map; freeing them from memory
		// before their pointers are lost by the "ds_map_clear" function call.
		var _key = ds_map_find_first(actorData);
		while(!is_undefined(_key)){
			delete actorData[? _key];
			_key = ds_map_find_next(actorData, _key);
		}
		ds_map_clear(actorData);
		
		// Clear out control information that existed for the textbox, and also reset all alpha variables
		// within that control information object back to the default values of zero.
		control_info_clear_data();
		control_info_reset_alpha();
		
		// Free the surface from VRAM if it hasn't be prematurely flushed and set the main state of the 
		// textbox to false, so it no longer processes state or rendering logic.
		surface_free(surfText);
		isTextboxActive = false;
		
		// 
		var _prevEntityStates = prevEntityStates;
		with(par_dynamic_entity){
			curState =		_prevEntityStates[? id][0];
			nextState =		_prevEntityStates[? id][1];
			lastState =		_prevEntityStates[? id][2];
		}
		ds_map_clear(prevEntityStates);
	}
	
	#endregion
	
	#region Textbox rendering functions
	
	/// @description Renders the background elements for the textbox. (Excluding the background elements required 
	/// for the "textbox decision" section; those elements being contained in their own function) The color of 
	/// these elements are dictacted by the actor that is currently using the textbox to speak. As such the
	/// rendering occurs within the scope of that current actor struct. Note that the namespace and portrait area
	/// backgrounds are only displayed if there is a name or portrait image to display, respectively.
	/// @param {Real}	x
	/// @param {Real}	y
	/// @param {Real}	alpha
	render_textbox_background = function(_x, _y, _alpha){
		with(actor){
			draw_sprite_stretched_ext(spr_textbox_background, 0, _x, _y, TEXTBOX_WIDTH + 30, TEXTBOX_HEIGHT + 16, backgroundColor, _alpha);
			if (nameString != "") {draw_sprite_stretched_ext(spr_textbox_namespace, 0, _x + 10, _y - 11, nameWidth, 13, backgroundColor, _alpha);}
			if (portrait != NO_SPRITE) {draw_sprite_stretched_ext(spr_textbox_portrait, 0, _x + TEXTBOX_WIDTH - 70, _y - 45, 86, 47, backgroundColor, _alpha);}
		}
	}
	
	/// @description Renders the additional information that can exist alongside the standard text field that
	/// is always shown to the player on each textbox; the actor's name and their current portrait image. Much
	/// like the background graphics for the data, the name and portraits aren't rendered if there is no valid
	/// data to display or the actor doesn't required them.
	/// @param {Real}	x
	/// @param {Real}	y
	/// @param {Real}	alpha
	/// @param {Real}	portraitIndex
	render_actor_information = function(_x, _y, _alpha, _portraitIndex){
		with(actor){
			// Drawing the name of the currently speaking "actor" onto the area meant to display the name
			// for the current speaker (If they have a name). If there is no name, this code is ignored
			// and no namespace is rendered for the textbox.
			if (nameString != ""){
				shader_set_outline(font_gui_small, RGB_GRAY);
				draw_set_halign(fa_center);
				draw_text_outline(_x - 5 + round(nameWidth / 2), _y - 15, nameString, HEX_WHITE, RGB_GRAY, _alpha);
				draw_set_halign(fa_left);
				shader_reset();
			}
			
			// Drawing the current portrait sprite (the given frame for that sprite is determined by the
			// value of "_portraitIndex" on the screen at a set position. If no portrait sprite exists for
			// the actor, no rendering is done.
			if (portrait != NO_SPRITE){
				draw_sprite_ext(portrait, _portraitIndex, _x + TEXTBOX_WIDTH - 64, _y - 52, 1, 1, 0, c_white, _alpha);
			}
		}
	}
	
	/// @description The function that handles the typewriter effect when text is actively being rendered
	/// onto the surface that is then drawn onto the textbox's background to display said text. It will
	/// also handle briefly stopping that effect when it comes to valid puncuation. (AKA "it has a space
	/// after it")
	/// @param {String}	text
	update_text_surface = function(_text){
		// Pause any processing of the textbox's typewriter effect until the punctuation timer runs out
		// if the textbox hasn't been set to ignore said timer.
		if (processPunctuation && punctuationTimer > 0){
			punctuationTimer -= TEXT_SPEED * DELTA_TIME * textbox.textSpeed;
			soundTimer = 0; // Ensures instant text scroll sound effect playback after the punctuation pause.
			return;
		}
		
		// Increment the value for "nextChar" until it exceeds the value for "curChar". Once this occurs,
		// it means that more characters must be rendered to the surface as is required by the text's
		// typewriter effect. To do this, it will loop; rendering each new character until the value for
		// "curChar" is finally greater than "nextChar" or the final character in the string has been hit.
		nextChar += TEXT_SPEED * DELTA_TIME * textbox.textSpeed;
		if (nextChar > curChar){
			// Render the required characters to the text surface. Also, copy that surface data into a
			// buffer so it doesn't get lost if the surface is freed for whatever reason.
			shader_set_outline(font_gui_small, charOutlineColor);
			surface_set_target(surfText);
			
			var _scale, _charString;
			_scale = textbox.textScale;
			while(nextChar > curChar){
				_charString = string_char_at(_text, curChar);
				
				// Check for punctuation, which simply means it's one of six unique characters (? , . ; : !) that 
				// will temporarily pause the typewriter effect for the textbox for a duration that is unique to
				// each character. However, multiple simultaneous punctuation characters in a row will ignore all
				// but the final one when it comes to the pause effect, and the final character won't be considered
				// since a pause is unnecessary in that context.
				var _isValidPunctuation = (curChar != finalChar && (is_character_punctuation(_charString) && !is_character_punctuation(string_char_at(_text, curChar + 1))));
				if (processPunctuation && _isValidPunctuation) {punctuationTimer = get_punctuation_time(_charString);}
				
				// Call the function that will render the required character onto the textbox at the proper
				// coordinates. If the value for "curChar" exceeds "finalChar", the loop will exit since
				// no more characters are left to render.
				render_character_to_surface(_charString, _text, _scale);
				if (curChar > finalChar || (processPunctuation && punctuationTimer > 0)) {break;}
			}
			
			surface_reset_target();
			shader_reset();
			buffer_get_surface(surfTextBuffer, surfText, 0);
		}
	}
	
	/// @description Attempts to draw a character to the text surface that will be rendered onto the
	/// textbox's background. There are a few exception to this rendering process, however. For example,
	/// the "parse color" character (*) will cause the next chunk in the string to be read as a color code
	/// that will then be used to draw the next character(s) as said color. Other than that, the "reset
	/// color" character (#) is used to reset back to the default text color, and a space/hyphen character
	/// will cause the rendering system to check if the next word exceeds the width limit for a line on
	/// the textbox. A separate function is used to handle the length limit check.
	/// @param {String}	charString
	/// @param {String}	text
	/// @param {Real}	scale
	render_character_to_surface = function(_charString, _text, _scale){
		if (_charString == CHAR_PARSE_COLOR){ // Begin parsing color data from the string.
			parse_character_color_data(_text, _scale);
			return;
		} else if (_charString == CHAR_RESET_COLOR){ // Reset the current text color data.
			reset_character_color_data();
			return;
		} else if ((_charString == CHAR_SPACE || _charString == CHAR_HYPHEN) && does_next_word_exceed_line_width(_text, _scale)){
			if (_charString == CHAR_HYPHEN) {draw_text_outline(TEXT_X_BORDER + charOffsetX, charOffsetY, _charString, charColor, charOutlineColor, 1, _scale, _scale);}
			charOffsetX = 0;
			charOffsetY += floor((string_height("M") + 1) * _scale);
			return;
		}
		
		// Render the character before adding its width to the next character's rendering position. Update
		// the value for "curChar" so it will attempt to render the next available character in the string.
		draw_text_outline(TEXT_X_BORDER + charOffsetX, charOffsetY, _charString, charColor, charOutlineColor, 1, _scale, _scale);
		charOffsetX += floor(string_width(_charString) * _scale);
		curChar++;
	}
	
	#endregion
	
	#region Textbox formatting functions
	
	/// @description Attempts to parse out the data within the textbox's displayed text that is found 
	/// between any two asterisk (*) symbols. It does this by first searching through the string to find
	/// the next asterisk. (The first one is what triggered the call to this function in the first place)
	/// Once it finds said symbol, it will get the "color" by copying the characters found between the
	/// pair of symbols. Then, the color is updated to match the color string found in the data.
	/// @param {String}	text
	/// @param {Real}	scale
	parse_character_color_data = function(_text, _scale){
		var _color, _endCharPos;
		_endCharPos = string_pos_ext(CHAR_PARSE_COLOR, _text, curChar + 1);
		_color = string_copy(_text, curChar + 1, _endCharPos - curChar - 1);
		
		// Attempt to grab an inner color and outer color pair for the text that matches the string found
		// within the text. If no valid color exists for the string that was found, the default text color
		// will be used instead.
		switch(_color){
			case BLUE:		charColor = HEX_LIGHT_BLUE;		charOutlineColor = RGB_DARK_BLUE;		break;
			case GREEN:		charColor = HEX_GREEN;			charOutlineColor = RGB_DARK_GREEN;		break;
			case RED:		charColor = HEX_RED;			charOutlineColor = RGB_DARK_RED;		break;
			case YELLOW:	charColor = HEX_LIGHT_YELLOW;	charOutlineColor = RGB_DARK_YELLOW;		break;
			case GRAY:		charColor = HEX_GRAY;			charOutlineColor = RGB_DARK_GRAY;		break;
			default:		charColor = HEX_WHITE;			charOutlineColor = RGB_GRAY;			break;
		}
		
		// Advance the character parsing index to skip over the data found between the two "*" symbols.
		nextChar = max(nextChar, _endCharPos + 2);
		curChar = _endCharPos + 1;
	}
	
	/// @description Automatically resets the text's inner and outer colors back to their default values.
	reset_character_color_data = function(){
		charColor = HEX_WHITE;
		charOutlineColor = RGB_GRAY;
		nextChar++;
		curChar++;
	}
	
	/// @description Performs a check to see if the next word that will be added to the textbox is too
	/// long to fit onto the current line that is being rendered. If that happens to be the case, the 
	/// current line will be ended, and a new line of characters will begin to be rendered, instead.
	/// @param {String}	text
	/// @param {Real}	scale
	does_next_word_exceed_line_width = function(_text, _scale){
		var _wordWidth, _curChar, _charString;
		_wordWidth = 0;
		_curChar = curChar + 1;
		_charString = string_char_at(_text, _curChar);
		
		// Loop through the string until the next space or hyphen character is reached. Once that
		// occurs, the "word" that was being built here will be completed and a check for the line width
		// plus the new word being larger than the maximum possible width is performed.
		while(_charString != CHAR_SPACE && _charString != CHAR_HYPHEN && _curChar <= finalChar){
			_curChar++;
			_charString = string_char_at(_text, _curChar);
			
			// Ignore unique code characters so they don't make the word sizes inaccurate to what is
			// shown to the user after the text is parsed and drawn onto its surface.
			if (_charString == CHAR_PARSE_COLOR)		{break;}
			else if (_charString == CHAR_RESET_COLOR)	{continue;}
			
			_wordWidth += string_width(_charString);
		}

		// Add the word onto the current line and see if that value exceeds the maximum width of a
		// line given the textbox's dimensions. If the value is greater, a new line is created, but
		// nothing additional is performed if the word can fit on the current line.
		if (charOffsetX + ((string_width(" ") + _wordWidth) * _scale) >= LINE_MAX_WIDTH){
			nextChar++;
			curChar++;
			return true;
		}
		return false;
	}
	
	/// @description Determines if the current character is "valid punctuation", which simply means that 
	/// it is one of the six unique characters seen in the below "return" statement.
	/// @param {String}	charString
	is_character_punctuation = function(_charString){
		return ((_charString == "!") || (_charString == ",") || (_charString == ".") || 
				(_charString == ":") || (_charString == ";") || (_charString == "?"));
	}
	
	/// @description Returns a unique value that will be used to pause the textbox's stypewriter effect for
	/// the desired duration given the current puncuation character that was found. Once second of pausing
	/// is equal to a value of 60, so these numbers are calculated relative to that full second value.
	/// @param {String}	charString
	get_punctuation_time = function(_charString){
		switch(_charString){
			case "!":	return 18;
			case ",":	return 12;
			case ".":	return 21;
			case ":":	return 15;
			case ";":	return 15;
			case "?":	return 18;
			default:	return 0;
		}
	}
	
	#endregion
	
	#region Decision window rendering function
	
	/// @description 
	draw_decision_window_background = function(_cameraWidth, _cameraHeight){
		// 
		draw_set_font(font_gui_small);
		var _height = 30 + (ds_list_size(textbox.playerChoices) * floor(string_height("M") + 2));
		var _halfHeight = (_height / 2);
		var _fifthHeight = (_height / 5);
		
		// 
		var _backgroundCenterY = (_cameraHeight / 2) - 40;
		var _cameraHalfWidth = (_cameraWidth / 2);
		
		// 
		shader_set(shd_feathering);
		feathering_set_bounds(_cameraHalfWidth - 80, _backgroundCenterY - _fifthHeight, _cameraHalfWidth + 80, _backgroundCenterY + _fifthHeight, 0, _backgroundCenterY - _halfHeight, _cameraWidth, _backgroundCenterY + _halfHeight);
		draw_sprite_ext(spr_rectangle, 0, 0, _backgroundCenterY - _halfHeight, _cameraWidth, _height, 0, HEX_BLACK, decisionWindowAlpha * alpha * 0.75);
		shader_reset();
	}
	
	/// @description 
	/// @param cameraWidth
	/// @param cameraHeight
	draw_decision_window_choices = function(_cameraWidth, _cameraHeight){
		shader_set_outline(font_gui_small, RGB_GRAY);
		draw_set_halign(fa_center);
		
		// 
		var _cameraHalfWidth = _cameraWidth / 2;
		var _textSpacingY = string_height("M") + 2;
		
		// 
		var _playerChoices = textbox.playerChoices;
		var _length = ds_list_size(_playerChoices);
		var _yOffset = (_cameraHeight / 2) - 40 - floor((_length * _textSpacingY) / 2);
		
		// 
		for (var i = 0; i < _length; i++){
			if (i == curOption) {draw_text_outline(_cameraHalfWidth, _yOffset, _playerChoices[| i].textString, HEX_LIGHT_YELLOW, RGB_DARK_YELLOW, decisionWindowAlpha * alpha);}
			else				{draw_text_outline(_cameraHalfWidth, _yOffset, _playerChoices[| i].textString, HEX_WHITE, RGB_GRAY, decisionWindowAlpha * alpha);}
			_yOffset += _textSpacingY;
		}
		
		draw_set_halign(fa_left);
		shader_reset();
	}
	
	#endregion
	
	#region Miscellaneous functions
	
	/// @description Returns a struct that contains information about the actor relative to the ID value
	/// that was passed into the function. By default, a textbox will be given the "Actor.None" (0) ID,
	/// which is the default composition for a textbox. Otherwise, a unique ID can be provided which 
	/// changes the color, adds a visible name, and even a visible sprite for the actor speaking.
	/// @param {Enum.Actor}	actorID
	actor_get_data = function(_actorID){
		switch(_actorID){
			case Actor.None:
				return {
					nameString :		"",
					portrait :			NO_SPRITE,
					backgroundColor :	make_color_rgb(0, 0, 188),
				};
			case Actor.Claire:
				return {
					nameString :		"Claire",
					portrait :			spr_claire_portraits,
					backgroundColor :	make_color_rgb(88, 0, 188),
				};
		}
	}
	// TODO -- Potentially change this to a JSON file of data to simplify the code.
	
	/// @description 
	initialize_default_control_info = function(){
		control_info_clear_anchor(TEXTBOX_MAIN_INFO);
		control_info_add_data(TEXTBOX_MAIN_INFO, INPUT_ADVANCE, "Next");
		control_info_add_data(TEXTBOX_MAIN_INFO, INPUT_LOG, "Log");
		control_info_initialize_anchor(TEXTBOX_MAIN_INFO);
		
		control_info_clear_anchor(TEXTBOX_EXTRA_INFO);
	}
	
	/// @description 
	initialize_decision_control_info = function(){
		control_info_clear_anchor(TEXTBOX_MAIN_INFO);
		control_info_add_data(TEXTBOX_MAIN_INFO, INPUT_SELECT, "Select");
		control_info_add_data(TEXTBOX_MAIN_INFO, INPUT_LOG, "Log");
		control_info_initialize_anchor(TEXTBOX_MAIN_INFO);
		
		// If there is already data for controls contained inside of the "extras" anchor, there is no 
		// need to add that data again since it has to be the same format as the controls needed for the 
		// textbox log (The "up" and "down" menu inputs).
		if (ds_list_size(CONTROL_INFO.anchorPoint[? TEXTBOX_EXTRA_INFO].info) == 0){
			control_info_add_data(TEXTBOX_EXTRA_INFO, INPUT_MENU_DOWN, "");
			control_info_add_data(TEXTBOX_EXTRA_INFO, INPUT_MENU_UP, "Move");
			control_info_initialize_anchor(TEXTBOX_EXTRA_INFO);
		}
	}
	
	/// @description 
	initialize_log_control_info = function(){
		control_info_clear_anchor(TEXTBOX_MAIN_INFO);
		control_info_add_data(TEXTBOX_MAIN_INFO, INPUT_RETURN, "Close");
		control_info_initialize_anchor(TEXTBOX_MAIN_INFO);
		
		// There is no need to display menu cursor controls when there are less textboxes logged than
		// can be viewed by the player at any given time, which is less than four, overall. So, if there
		// are less than that amount, any potential movement controls are cleared out of their anchor.
		if (ds_list_size(logger.savedText) <= 3){
			control_info_clear_anchor(TEXTBOX_EXTRA_INFO);
			return; // Exit before any menu cursor controls can be added.
		}
		
		// If there is already data for controls contained inside of the "extras" anchor, there is no 
		// need to add that data again since it has to be the same format as the controls needed for the 
		// textbox log (The "up" and "down" menu inputs).
		if (ds_list_size(CONTROL_INFO.anchorPoint[? TEXTBOX_EXTRA_INFO].info) == 0){
			control_info_add_data(TEXTBOX_EXTRA_INFO, INPUT_MENU_DOWN, "");
			control_info_add_data(TEXTBOX_EXTRA_INFO, INPUT_MENU_UP, "Move");
			control_info_initialize_anchor(TEXTBOX_EXTRA_INFO);
		}
	}
	
	#endregion
}

#endregion

#region Global functions related to obj_textbox_handler

/// @description Adds a new textbox data struct to the end of the list that stores said data. From here,
/// all the data required by the textbox (Even the optional stuff like sound and shake effect structs) are
/// initialized and have their data set accordingly; either to what is provided in the arguments or with
/// defaults since they aren't altered through this function. After this function, all textbox manipulation
/// function will reference the struct created here since it will be the latest one in the list.
/// @param {String}		text
/// @param {Real}		speed
/// @param {Real}		scale
/// @param {Enum.Actor}	actorID
/// @param {Real}		portraitIndex
function textbox_add_text(_text, _speed = 1, _scale = 1, _actorID = Actor.None, _portraitIndex = 0){
	with(TEXTBOX_HANDLER){
		if (isTextboxActive) {return;}
		
		// Creates the struct containing all the data that is unique to this textbox and stores its
		// pointer within the "textboxData" list found in the textbox handler.
		ds_list_add(textboxData, {
			// The main data for the textbox that determines what is rendered to the screen for 
			// the player to see and how it'll be rendered (Ex. scaled text).
			fullText :			_text,
			textSpeed :			_speed,
			textScale :			_scale,
			actorID :			_actorID,
			portraitIndex :		_portraitIndex,
			
			// A struct that stores data about the optional sound effect that can exist within each
			// textbox. This sound can have a unique playback delay relative to its textbox being
			// reached, volume, and pitch.
			soundData :	{
				index :			NO_SOUND,
				delay :			0,
				volume :		GET_UI_VOLUME,
				pitch :			1,
			},
			
			// Another struct that stores data about the horizontal shake that can be applied to a
			// textbox as an optional effect whenever required. Simply stores the current strength
			// and remaining duration of the effect.
			shakeData : {
				initialPower :	0,
				curPower :		0,
				duration :		0,
			},
			
			// The remaining variables that will be responsible for two very different tasks; the first
			// storing all the structs containing information about a given choice available to the player
			// by this textbox, and a flag that can signal the handler to close itself prematurely. Both
			// are useful for branching dialogue.
			playerChoices :		ds_list_create(),
			closeTextbox :		false,
		});
		
		// Add actor data into the map containing all currently available actor structs if the one
		// required for this newly created textbox isn't already found within this map.
		if (is_undefined(actorData[? _actorID])) {ds_map_add(actorData, _actorID, actor_get_data(_actorID));}
	}
}

/// @description Stores the provided power and duration values into the most recently created textbox
/// struct's shake effect data struct. This data is then used to cause the entire textbox to shake randomly
/// from left to right over the course of time determined by the "duration" value.
/// @param {Real}	power
/// @param {Real}	duration
function textbox_add_shake_effect(_power, _duration){
	with(TEXTBOX_HANDLER){
		var _index = ds_list_size(textboxData) - 1;
		if (_index >= 0){ // Only attempt to add data with a valid index.
			with(textboxData[| _index].shakeData){
				initialPower = _power;
				curPower = _power;
				duration = _duration;
			}
		}
	}
}

/// @description Adds data for a sound effect to the most recently created textbox struct. The 
/// sound can have an option delay added to it that pauses its playback for a given amount of time
/// relative to when the textbox is first displayed, and its volume/pitch can be adjusted, too.
/// @param {Asset.GMSound}	sound
/// @param {Real}			delay
/// @param {Real}			volume
/// @param {Real}			pitch
function textbox_add_sound_effect(_sound, _delay = 0, _volume = GET_UI_VOLUME, _pitch = 1){
	with(TEXTBOX_HANDLER){
		var _index = ds_list_size(textboxData) - 1;
		if (_index >= 0){ // Only attempt to add data with a valid index.
			with(textboxData[| _index].soundData){
				index = _sound;
				delay = _delay;
				volume = _volume;
				pitch = _pitch;
			}
		}
	}
}

/// @description Adds a player choice struct to the list of player choices stored within the most recently
/// created textbox struct. This choice data will store the text used for when the option is displayed to
/// the player, the outcome index of the textbox handler after the choice is chosen, and optionally a
/// paired flag that will set to a given state when said choice is selected by the player.
/// @param {String}			text
/// @param {Real}			outcomeIndex
/// @param {Real}			eventFlag
/// @param {Bool}			flagState
function textbox_add_player_choice(_text, _outcomeIndex, _eventFlag = INVALID_FLAG, _flagState = false){
	with(TEXTBOX_HANDLER){ // Only attempt to add data with a valid index.
		var _index = ds_list_size(textboxData) - 1;
		if (_index >= 0){
			with(textboxData[| _index]){
				// Create the struct for the player choice data and store it within the list
				// of current player choices stored within this most recent textbox struct.
				ds_list_add(playerChoices, {
					textString :	_text,
					outcomeIndex :	_outcomeIndex,
					eventFlag :		_eventFlag,
					flagState :		_flagState,
				});
			}
		}
	}
}

/// @description Sets the flag within the textbox data struct that causes the textbox itself to
/// close before reaching the final index of the textbox struct list to true. Meaning, at this
/// index the textbox will close regardless of if there is more data contained after it in the
/// list.
function textbox_set_to_close(){
	with(TEXTBOX_HANDLER){
		var _index = ds_list_size(textboxData) - 1;
		if (_index >= 0) {textboxData[| _index].closeTextbox = true;}
	}
}

/// @description Signals to the textbox object that it can begin rendering and processing the data
/// that was loaded into it before this function call. If no data was loaded into the textbox prior
/// to this function call, nothing will occur since there is no data to process. The starting index
/// into the list can be altered if required.
/// @param {Real}	startingIndex
function textbox_activate(_startingIndex = 0){
	with(TEXTBOX_HANDLER){
		if (ds_list_size(textboxData) == 0 || isTextboxActive) {return;}
		
		// Prepare the textbox by setting it to the proper coordinates on the screen that will
		// result in it being centered horizontally and around 14 pixels from the bottommost edge
		// of the text window. Set its state to its default opening animation.
		var _cameraWidth = camera_get_width();
		var _cameraHeight = camera_get_height();
		x = (_cameraWidth - TEXTBOX_WIDTH) / 2;
		y = _cameraHeight + 60;
		targetY = _cameraHeight - 58;
		initialY = y; // Stored for when the textbox needs to perform an actor swap animation.
		isTextboxActive = true;
		actorSwap = true; // Allows the first textbox to actually initialize its actor data.
		prepare_next_textbox(_startingIndex);
		object_set_next_state(state_animation_open_textbox);
		
		// 
		control_info_create_anchor(TEXTBOX_MAIN_INFO, _cameraWidth - 5, _cameraHeight - 12, ALIGNMENT_RIGHT);
		control_info_create_anchor(TEXTBOX_EXTRA_INFO, 5, _cameraHeight - 12, ALIGNMENT_LEFT);
		control_info_set_alpha_target(1, 0.075);
		initialize_default_control_info();
		
		// 
		var _prevPlayerState = prevPlayerState;
		with(PLAYER){
			if (curState == NO_STATE) {return;}
			
			// 
			array_set(_prevPlayerState, 0, curState);
			array_set(_prevPlayerState, 1, nextState);
			array_set(_prevPlayerState, 2, lastState);
			
			// 
			curState = NO_STATE;
			nextState = NO_STATE;
			lastState = NO_STATE;
		}
	}
}

#endregion