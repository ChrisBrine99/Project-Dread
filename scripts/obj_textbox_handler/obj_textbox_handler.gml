/// @description A script file containing all the code and logic for the game's textbox.

#region Initializing any macros that are useful/related to obj_textbox_handler

// Macros that store the "dimensions" of the textbox, which is actually just the width and height
// for the surface that all text is rendered onto. The actual background is determined by these
// values along with adjustments to provide some empty space between the edges and the text.
#macro	TEXTBOX_WIDTH				280
#macro	TEXTBOX_HEIGHT				35

// The first macro determines how many pixels there are on the left and right edges of the surface
// that the characters are rendered onto. The second one determines how long a single line of text
// can be on said surface in pixels. These values don't factor in the outlining of the text.
#macro	TEXT_X_BORDER				2
#macro	LINE_MAX_WIDTH				276

// Macros used for the opening/actor swap animation. The first value is the position that the textbox
// will begin at BEFORE any movement has occured, and the second value is the position the textbox
// wil need to reach in order to complete the movement portion of the animation.
#macro	TEXTBOX_INITIAL_Y			(CAM_HEIGHT + 60)
#macro	TEXTBOX_TARGET_Y			(CAM_HEIGHT - 58)

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
	// 
	x = CAM_HALF_WIDTH - (TEXTBOX_WIDTH / 2);
	y = 0;
	object_index = obj_textbox_handler;
	
	// 
	curState = NO_STATE;
	lastState = NO_STATE;
	nextState = NO_STATE;
	
	// 
	isTextboxActive = false;
	alpha = 0;
	
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
	
	// 
	indicatorOffset = 0;
	
	// Variables that store the input state for the various actions that can be done through the
	// textbox by the player; advancing to the next chunk of text, checking previous text through
	// the "log", and moving the cursor to different decisions when the player is required to make
	// a decision.
	inputAdvance = false;
	inputLog = false;
	inputSelect = false;
	inputUp = false;
	inputDown = false;
	
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
		
		// In order to allow for a textbox's sound to be delayed, the timer for that delayed
		// playback is counted down here by access the "soundData" struct that is stored inside
		// the current textbox's data struct. Once that delay value reaches 0, the sound will be
		// played and the "index" will be set to NO_SOUND to prevent further playback.
		with(textbox.soundData){
			if (index != NO_SOUND){
				delay -= DELTA_TIME;
				if (delay <= 0){
					audio_play_sound_ext(index, 0, volume, pitch);
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
				other.x = (CAM_HALF_WIDTH - (TEXTBOX_WIDTH / 2)) + irandom_range(-curPower, curPower);
			}
		}
	}
	
	/// @description Code that should be placed into the "Draw GUI" event of whatever object is controlling
	/// obj_textbox_handler. In short, it will handle the rendering of the components that make up the
	/// textbox by calling their respective functions if the textbox is currently visible (alpha > 0)
	/// and toggled to an active state.
	draw_gui = function(){
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
		if (curChar <= finalChar) {update_text_surface(textbox.fullText);}
		draw_surface_ext(surfText, x, y, 1, 1, 0, c_white, surfAlpha * alpha);
	}
	
	/// @description Code that should be placed into the "Clean Up" event of whatever object is controlling
	/// obj_textbox_handler. In short, it will clear out any data structures and struct objects created
	/// by the textbox handler before itself is removed from memory; preventing any lost pointers and
	/// memory leaks.
	cleanup = function(){
		// 
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
		
		// 
		var _key = ds_map_find_first(actorData);
		while(!is_undefined(_key)){
			delete actorData[? _key];
			_key = ds_map_find_next(actorData, _key);
		}
		ds_map_destroy(actorData);
		
		// 
		delete textbox;
		delete actor;
		
		// 
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
			inputAdvance =		gamepad_button_check_pressed(_gamepadID, PAD_ADVANCE);
			inputLog =			gamepad_button_check_pressed(_gamepadID, PAD_LOG);
			inputSelect =		gamepad_button_check_pressed(_gamepadID, PAD_SELECT);
			inputUp =			gamepad_button_check(_gamepadID, PAD_MENU_UP);
			inputDown =			gamepad_button_check(_gamepadID, PAD_MENU_DOWN);
			// TODO -- Add ability to select options by using the left or right thumbsticks.
		} else{ // Getting input from the default device keyboard.
			inputAdvance =		keyboard_check_pressed(KEY_ADVANCE);
			inputLog =			keyboard_check_pressed(KEY_LOG);
			inputSelect =		keyboard_check_pressed(KEY_SELECT);
			inputUp =			keyboard_check(KEY_MENU_UP);
			inputDown =			keyboard_check(KEY_MENU_DOWN);
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
					object_set_next_state(state_closing_animation);
					targetIndex = -1; // Tells the textbox that it should close after completing the animation.
				} else{
					// UNIQUE CASE -- If there is player choice data found within the list for such data
					// that exists within each textbox data struct, the textbox will enter its decision
					// state; having the next index determined relative to the choice made by the player.
					if (ds_list_size(textbox.playerChoices) > 1){
						//object_set_next_state(state_fade_in_decision_data);
						return;
					}
					
					// STANDARD CASE -- Check if an actor swap needs to occur between the current and the
					// next textbox. An actor swap will play the closing animation without actually closing
					// the textbox. Meanwhile, the non-actor swap will fade out the old text before moving
					// onto the next textbox data is displayed.
					actorSwap = (textbox.actorID != textboxData[| index + 1].actorID);
					if (!actorSwap) {object_set_next_state(state_fade_out_previous_text);}
					else {object_set_next_state(state_closing_animation);}
					targetIndex = index + 1;
				}
			}
		}
	}
	
	/// @description
	state_select_decision = function(){
		
	}
	
	#endregion
	
	#region Animation states (Opening, closing, fading out old text, changing actors, etc.) 
	
	/// @description The textbox's opening animation, which causes it to slide onto the screen from the
	/// bottom; fading itself in as that position translation occurs. Once the animation has been finished,
	/// the textbox's state is set to its "default" where player input can be processed.
	state_opening_animation = function(){
		alpha = value_set_linear(alpha, 1, 0.05);
		y = value_set_relative(y, TEXTBOX_TARGET_Y, 0.15);
		if (alpha == 1 && y < TEXTBOX_TARGET_Y + 0.5){
			object_set_next_state(state_default);
			y = TEXTBOX_TARGET_Y;
		}
	}
	
	/// @description The textbox's closing animation, which simply fades the textbox and all of its contents
	/// out of visibility. Once that is done, one of two different things can occur: the textbox can be
	/// deactivated or the opening animation can be performed again. These outcomes can occurs when the
	/// textbox is set to be closed or if an actor swap has occurred between this and the previous textbox,
	/// respectively.
	state_closing_animation = function(){
		alpha = value_set_linear(alpha, 0, 0.075);
		if (alpha == 0){
			if (targetIndex == -1){ // Closes the textbox.
				textbox_deactivate();
			} else{ // Prepares the next textbox; playing the opening animation again.
				object_set_next_state(state_opening_animation);
				prepare_next_textbox(targetIndex);
				y = TEXTBOX_INITIAL_Y;
			}
		}
	}
	
	/// @description A simplified transition animation that fades out the old textbox text before any new
	/// text is rendered onto the screen. It can only occur when a textbox change has occurred, but an
	/// actor swap didn't happen during that change.
	state_fade_out_previous_text = function(){
		surfAlpha = value_set_linear(surfAlpha, 0, 0.1);
		if (surfAlpha == 0){
			object_set_next_state(state_fade_in_new_text);
			prepare_next_textbox(targetIndex);
		}
	}
	
	/// @description A reverse process compared to the state function above this one; it will fade in the
	/// surface that is responsible for displaying the text contents for the textbox into visibility so it
	/// smoothly transitions between the two textboxes.
	state_fade_in_new_text = function(){
		surfAlpha = value_set_linear(surfAlpha, 1, 0.1);
		if (surfAlpha == 1) {object_set_next_state(state_default);}
	}
	
	#endregion
	
	#region Textbox struct list management functions
	
	/// @description Swaps the data used for the "old" textbox with data found at the new index value;
	/// text data, actor data, new portraits, and so on. It will also clear out the buffer that stored
	/// the characters that are rendered onto the textbox so the new text can be rendered onto it.
	/// @param {Real}	index
	prepare_next_textbox = function(_index){
		// Completely clear the surface of the old text by writing nothing but zeroes to the surface
		// buffer. Then, copy the new zeroed out buffer to the surface, which completely clears out any
		// previously existing graphical data.
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
		var _length, _cLength;
		_length = ds_list_size(textboxData);
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
		
		// Delete all structs created and stored within the "actorData" ds_map; freeing them from memory
		// before their pointers are lost by the "ds_map_clear" function call.
		var _key = ds_map_find_first(actorData);
		while(!is_undefined(_key)){
			delete actorData[? _key];
			_key = ds_map_find_next(actorData, _key);
		}
		ds_map_clear(actorData);
		
		// Finally, free the surface from VRAM if it hasn't be prematurely flushed and set the main state
		// of the textbox to false, so it no longer processes state or rendering logic.
		surface_free(surfText);
		isTextboxActive = false;
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
			draw_sprite_stretched_ext(spr_textbox_background, 0, _x, _y, TEXTBOX_WIDTH + 30, TEXTBOX_HEIGHT + 17, backgroundColor, _alpha);
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
				shader_set_outline(RGB_GRAY, font_gui_small);
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
			punctuationTimer -= global.settings.textSpeed * DELTA_TIME * textbox.textSpeed;
			nextChar = curChar; // Stops the "nextChar" value from going too high when delta time is too large.
			return;
		}
		
		// Increment the value for "nextChar" until it exceeds the value for "curChar". Once this occurs,
		// it means that more characters must be rendered to the surface as is required by the text's
		// typewriter effect. To do this, it will loop; rendering each new character until the value for
		// "curChar" is finally greater than "nextChar" or the final character in the string has been hit.
		nextChar += global.settings.textSpeed * DELTA_TIME * textbox.textSpeed;
		if (nextChar > curChar){
			// Render the required characters to the text surface. Also, copy that surface data into a
			// buffer so it doesn't get lost if the surface is freed for whatever reason.
			shader_set_outline(charOutlineColor, font_gui_small);
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
				volume :		SOUND_VOLUME,
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
function textbox_add_sound_effect(_sound, _delay = 0, _volume = SOUND_VOLUME, _pitch = 1){
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
function textbox_add_player_choice(_text, _outcomeIndex, _eventFlag = EVENT_FLAG_INVALID, _flagState = false){
	with(TEXTBOX_HANDLER){ // Only attempt to add data with a valid index.
		var _index = ds_list_size(textboxData) - 1;
		if (_index >= 0){
			with(textboxData[| _index]){
				// Ensures that the event flag for the newly added decision being selected is 
				// actually created and ready for use by the game.
				if (_eventFlag != EVENT_FLAG_INVALID) {EVENT_CREATE_FLAG(_eventFlag);}
			
				// Create the struct for the player choice data and store it within the list
				// of current player choices stored within this most recent textbox struct.
				ds_list_add(playerChoices, {
					text :			_text,
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
		if (ds_list_size(textboxData) == 0) {return;}
		y = TEXTBOX_INITIAL_Y;
		isTextboxActive = true;
		actorSwap = true; // Allows the first textbox to actually initialize its actor data.
		prepare_next_textbox(_startingIndex);
		object_set_next_state(state_opening_animation);
	}
}

#endregion