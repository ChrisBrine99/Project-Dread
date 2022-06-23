/// @description A script file containing all the code and logic for the game's textbox.

#region Initializing any macros that are useful/related to obj_textbox_handler

// Two constants that keep the target and starting position consistent throughout all of the textbox handler's 
// code. They are used for the opening animation and only that animation; the closing doesn't move the textbox.
#macro	TEXTBOX_TARGET_Y			(CAM_HEIGHT - 58)
#macro	TEXTBOX_START_Y				(CAM_HEIGHT + 60)

// Macros for the color names that can be embedded into a given textbox's text data inside of a pair of
// asterisks "*" that will alter the text to a pair of colors (both inner and outline, respectively) 
// matching that given color's name.
#macro	BLUE						"blue"
#macro	GREEN						"green"
#macro	RED							"red"
#macro	YELLOW						"yellow"

#endregion

#region	Initializing any enumerators that are useful/related to obj_textbox_handler

/// @description Stores unqiue ID values for all possible "actors" that can use the textbox and its extended
/// functionalities. Other than the "NoActor" enum value, the remaining values should all be characters and
/// other actual "characters" in the actual game world.
enum Actor{
	NoActor,
	Test01,
}

#endregion

#region Initializing any globals that are useful/related to obj_textbox_handler
#endregion

#region	The main object code for obj_textbox_handler

function obj_textbox_handler() constructor{
	// Much like Game Maker's own x and y variables, these store the current position of the camera within 
	// the current room. By default the textbox is set to be centered in the middle of the screen, and its
	// y-position is set to be locked onto the bottom of the screen.
	x = CAM_HALF_WIDTH - 140;
	y = TEXTBOX_TARGET_Y;
	
	// Much like Game Maker's own object_index variable, this will store the unique ID value provided to this
	// object by Game Maker during runtime; in order to easily use it within a singleton system.
	object_index = obj_textbox_handler;
	
	// A map that will store the current states for all entities that currently exist whenever the textbox
	// is called to run and process all of its stored text data. It will clear all those state variables
	// to "NO_STATE" for all entities, and then return these state values back to them once the textbox
	// had finished its execution. HOWEVER, this doesn't happen when a cutscene is currently executing
	// since the cutscene manager will be handling entity states.
	entityStates = ds_map_create();
	
	// A simple flag that can easily be referenced in code to see if the textbox is currently in its
	// execution state (Set to true). Otherwise, it will be inactive and set to false.
	isTextboxActive = false;
	
	// Variables that allow the textbox to have its alpha channel altered depending on what the current target
	// value is. This allows for smooth animations in the opacity to occur on top of whatever other animations
	// are being played for the textbox during its opening and closing animations.
	alphaTarget = 0;
	alpha = 0;
	
	// Much like the variable pair above, this pair will handle the alpha for a specific aspect of the 
	// textbox's rendering, but it will only affect whatever is drawn for the player decision window. This 
	// window is only ever visible when the textbox needs input from the player to move forward, which is also
	// known as a decision within the code.
	decisionAlphaTarget = 0;
	decisionAlpha = 0;
	
	// A variable that stores the color for the feathered background area that goes beneath all of the
	// textbox decision options that whenever they are being displayed to the player. It is always set to a
	// darker variation of the main textbox color; much like how the namespace coloring works.
	decisionBackColor = c_white;
	
	// A simple pair of variables that works identically to how the same pair of highlighting variables works
	// within a given menu struct; flashing the currently highlighted option between the highlight color and
	// the option's standard color in order to draw attention to it so the player knows which option they have
	// currently highlighted out of the full list.
	highlightTimer = 0;
	highlightOption = false;
	
	// Stores the currently highlighted decision index for the player relative to the list of available options
	// shown to them. When they press the selection input, this number will be used to determine the next index
	// of textbox to move onto from the overall list. The second variable simply stores the total number of
	// decisions (The array's length) that the player can choose from for simpler reference.
	decisionIndex = 0;
	numDecisions = 0;
	
	// Two values that store the "width" and "height" of the textbox, which is actually the exact dimensions
	// of the surface in which the current text is rendered onto. The actual textbox background's size is
	// slightly larger than this, but it still uses these dimensions as a base value.
	textboxWidth = 280;
	textboxHeight = 35;
	
	// The three default state variables that are required for any object/entity/struct that uses states.
	// The first value is the "current state" which is what is actually called during state execution. The
	// "next state" is the second variables and causes the current state to be switched to match it at the
	// end of everyu frame if it doesn't currently match. Finally, the "last state" is stored in the final
	// variables for easy reference in case the previous state is needed in the new state, and so on.
	curState = NO_STATE;
	lastState = NO_STATE;
	nextState = NO_STATE;
	
	// Flags that store the states for all necessary inputs for the textbox's functionality. The first 
	// handles the advancing of the textbox, and the last three are used for when the player is asked to 
	// make a decision in the dialogue/cutscene.
	inputAdvance =	false;
	inputUp =		false;
	inputDown =		false;
	inputSelect =	false;
	
	// Creates and stores a surface; a texture that is the exact dimensions of the textbox given its width
	// and height variables. This surface is then used to render the text onto whenever the textbox is
	// displaying information to the player. Below that is a buffer that stores a copy of the surface in
	// memory; restoring the surface to what it was in case it gets randomly freed during gameplay.
	surfText = surface_create(textboxWidth, textboxHeight);
	surfTextBuffer = buffer_create(textboxWidth * textboxHeight * 4, buffer_fixed, 4);
	
	// All the variables for the textboxes themselves. The first stores a list of textbox structs that contain
	// the data unique to each textbox: their text, scaling, par-character color data, and so on. The next
	// variable simply stores the number of textboxes within that list for easy reference in the rest of the
	// code.
	textboxData = ds_list_create();
	totalTextboxes = 0;
	
	// Stores the flag that is unique to each textbox struct. If that current textbox struct's flag is set to
	// true it means that the textbox will close itself when the player next pressed the "advance" input on
	// their keyboard/gamepad; even if the textbox isn't at its last index.
	closeTextbox = false;
	
	// A map that stores all of the actor data structs, which are then called and used by each textbox that
	// shares the same "actor ID" value as the key/value pairs in this map. This prevents the actors from
	// having to be stored on a per-textbox basis, which would be a lot of duplicate data for no real gain
	// in performance. The flag "actorSwap" will allow the textbox to repeat its opening and closing animation
	// whenever the next textbox has a different actor than the previous one.
	actorData = ds_map_create();
	actorSwap = false;
	
	// These four variables are what can be altered by the current actor's data. The first simply stores
	// the name for the actor that is then rendered to the textbox over its namespace area. The second 
	// stores the sprite index forn the portrait. Likewise, the current portrait image is stored within the
	// third variable. Finally, the color of the textbox's main area is stored within the fourth variable.
	// All these simply store redundant data from the actor's data to speed up the textbox rendering code.
	actorName = "";
	actorPortrait = 0;
	actorPortraitIndex = 0;
	textboxColor = c_white;
	
	// This value works similarly to how the textboxWidth variable does; only with the namespace instead of
	// the actual textbox. It will accurately size the namespace's width so that the name will be evenly
	// centered within it.
	actorNameWidth = 0;
	
	// Stores the current index out of the group of textboxes that is currently being rendering onto the
	// screen for the player to view. This value usually increments up by one whenever a previous textbox
	// is closed, but it can be manipulated to jump around to various indexes for things like branching
	// decisions or early exits from execution.
	curTextboxIndex = 0;
	
	// Stores the current colors for a group of given characters that are currently being rendered onto the
	// textbox. These can be swapped and edited during the rendering process in order to swap colors around
	// for different words or word groups. The asterisk "*" is used to denote that a color swap is occurring,
	// and the logic for parsing out the color's name is found below in the actual rendering logic for the
	// text characters.
	textColor = HEX_WHITE;
	textOutlineColor = RGB_GRAY;
	
	// The current offset position on the textbox's text rendering surface that the next character should be
	// placed; relative to the text's starting point. It's reset whenever the text is cleared to make room
	// for the new textbox data.
	characterX = 0;
	characterY = 0;
	
	// Two important variables for the text to be properly formatted within the dimensions of the text surface.
	// The offset variable is used whenever there is a portrait shown on the textbox alongside the text. In
	// that case this value is altered to move the text out of the way of the portrait sprite. Likewise, the
	// max line width will prevent the text from overshooting the right edge of the textbox; starting a new
	// line to prevent it. The value is shrunk when a portrait is being displayed on the textbox.
	textOffsetX = 0;
	maxLineWidth = 0;
	
	// A variable that simply stores the value of the text speed set by the user; preventing the code from
	// having to jump into the settings to retrieve this value on a per-frame basis while the text is still
	// scrolling onto the screen.
	textSpeed = 0;
	
	// The three main variables for rendering the text and also allowing it to have a typewriter animation
	// effect for rendering the text onto the surface it uses. The first variable is what the index for the
	// latest to-be-rendered character is, the second is what the next to-be-rendered character should be
	// and the final variable is the simply length of the string.
	curCharacter = 1;
	nextCharacter = 1;
	finalCharacter = 0;
	
	// A simple variable that counts up at a given speed (0.05 per 1/60th of a second) until it reaches a
	// value of two. After that, it will be reset to 0 and begin the process again. The result is the textbox
	// having an "advancement" indicator that bobs up and down at a given interval.
	indicatorOffset = 0;
	
	// A slightly simplified variation on the camera's shake effect variables. In short, it allows the
	// textbox to have a horizontal shaking effect applied when a given textbox is opened; to relay the
	// intensity of the dialogue within said textbox. 
	shakeCurStrength = 0;
	shakeDuration = 0;
	
	// 
	cutsceneTargetIndex = -1;
	
	/// @description Code that should be placed into the "Step event of whatever object is controlling
	/// obj_textbox_handler. In short, it checks for input from the game's currently active input device
	/// and then it manipulates the textbox accordingly.
	step = function(){
		// Waiting until the textbox fades away before completing the transition to the new textbox data;
		// resetting all necessary variables in order to allow this new textbox to display its text properly.
		if (actorSwap && alpha == 0){
			// Open up the next textbox now that the current one has fully closed.
			open_next_textbox();
			// Set all of the textbox's variables for its animation to what they are when the textbox first
			// opens; triggering its opening animation once again for the new actor's textbox.
			y = TEXTBOX_START_Y;
			alphaTarget = 1;
			actorSwap = false;
		}
		
		// In order to prevent the player from animating in place if they were moving when a textbox opens,
		// their sprite needs to be set to the standing sprite in whatever direction they were facing.
		if (isTextboxActive){
			with(PLAYER) {set_sprite(spr_player_unarmed_stand0, 0);}
		}
		
		// Don't allow any input to be processed by the textbox if it currently isn't actively displaying
		// text to the player OR while it's animation. Failing to check if there is a state will result
		// in the game crashing, and the pause for animation stops it from jittering when the player mashes
		// their "advance" input.
		if (curState == NO_STATE || alphaTarget != alpha || y != TEXTBOX_TARGET_Y) {return;}
		curState();
	}
	
	/// @description Code that should be placed into the "End Step" event of whatever object is controlling
	/// obj_textbox_handler. In short, it handles updating the current state for the textbox to the new state
	/// if one was set in the frame.
	end_step = function(){
		if (curState != nextState) {curState = nextState;}
	}
	
	/// @description Code that should be placed into the "Draw GUI" event of whatever object is controlling
	/// obj_textbox_handler. In short, it handles generating the texture for the textbox's text as well as
	/// all the graphical rendering that is necessary for the textbox to look how it does.
	draw_gui = function(){
		// Prevents the textbox from rendering whenever it is both invisible to the player and inactive.
		if (!isTextboxActive) {return;}
		
		// Adjust the two values that are responsible for the textbox's opening and closing animation on a
		// per-frame basis. This prevents the animation from getting stuck and also minimizes the code needed
		// for the textbox to perform said animation; given its relative simplicity.
		y = value_set_relative(y, TEXTBOX_TARGET_Y, 0.25);
		alpha = value_set_linear(alpha, alphaTarget, 0.075);
		if (!actorSwap && alpha == 0) {textbox_end_execution();}
		
		// Setting the alpha of the control info on the screen ONLY WHEN the textbox is currently the object
		// in control of that alpha level. Otherwise, it will be managed by another object (Ex. being controlled
		// by obj_cutscene_manager whenever a cutscene is active) and the alpha code will not be overwritten.
		var _alpha, _curTextboxIndex, _totalTextboxes, _closeTextbox;
		_alpha = alpha;
		_curTextboxIndex = curTextboxIndex;
		_totalTextboxes = totalTextboxes;
		_closeTextbox = closeTextbox;
		with(CONTROL_INFO){
			if (curController == TEXTBOX_HANDLER && (_closeTextbox || _curTextboxIndex == 0 || _curTextboxIndex == _totalTextboxes)) {alpha = _alpha;}
		}
		
		// Handling the option shake effect that can occur on a per-textbox basis. In short, it will rock
		// the entire textbox back and forth on the x-axis for a set amount of "frames" and (60 frames being
		// 1 second of real-time) slowly depleting strength over that time. Since the textbox's state is
		// temporarily removed during the shake effect, it is re-enabled after the effect has completed.
		if (shakeCurStrength > 0){
			shakeCurStrength -= 5 / shakeDuration * DELTA_TIME;
			x = CAM_HALF_WIDTH - 140 + irandom_range(-shakeCurStrength, shakeCurStrength);
			if (shakeCurStrength <= 0) {object_set_next_state(lastState);}
		}
		
		// Drawing the textbox's background and advancement indicator // 
		
		// Displaying the background of the textbox as a stretched nineslice sprite that spans the entire
		// width and height set for the textbox. The color that the textbox will become is determined by
		// whatever the current actor's color data says it should be.
		draw_sprite_stretched_ext(spr_textbox_background, 0, x - 15, y - 8, textboxWidth + 30, textboxHeight + 17, textboxColor, alpha);
		
		// If the textbox has finished displaying all of the required string onto the surface for rendering,
		// a small downward-facing arrow will be shown bouncing up and down at regular intervals based on
		// the speed of the indicatorOffset's value change over time. ("Time" being 1/60th of a second)
		var _decisionState = (curState == state_choose_decision);
		if (curCharacter > finalCharacter && !_decisionState){
			indicatorOffset += DELTA_TIME * 0.05;
			if (indicatorOffset >= 2) {indicatorOffset = 0;}
			draw_sprite_ext(spr_advance_indicator, 0, x + textboxWidth - 2, y + textboxHeight - floor(indicatorOffset), 1, 1, 0, HEX_WHITE, alpha);
		}
		
		// Drawing the background for the decision area of the textbox // 
		
		// Only render the background that the options will be displayed on if the current state of the 
		// textbox is asking the player to make a decision based on what is stored in the decisionData array
		// of the given textbox.
		var _decisionElementAlpha = alpha * decisionAlpha;
		if (_decisionState){
			var _xx, _yy, _halfHeight; // Store these values in order to prevent the calculations from being duplicated below.
			_xx = CAM_WIDTH - 160;
			_yy = y - 8 - ((numDecisions + 1) * 10);
			_halfHeight = ((numDecisions + 1) * 5) + 2;
			// Display the background as a feathered rectangle that is attached to the right edge of the screen.
			// It's height is determined by the number of decisions available to the player, and its vertical
			// position is determined with that amount as well.
			draw_sprite_feathered(spr_rectangle, 0, _xx, _yy, 200, _halfHeight * 2, _xx + 140, _yy + _halfHeight, _xx + 140, _yy + _halfHeight, 0, decisionBackColor, _decisionElementAlpha * 0.75);
			shader_reset(); // Must be somewhere after the "draw_sprite_feathered" since it automatically changes the shader to the feathering one.
		}
		
		// Drawing the namespace's background, it's text, and portrait to the screen //
		
		// Only render the portrait image to the textbox IF both the actor portrait and portrait image index
		// are set to valid values. (Their defaults are both -1) Otherwise, a crash can and will occur.
		if (actorPortrait != -1 && actorPortraitIndex != -1){
			draw_sprite_ext(actorPortrait, actorPortraitIndex, x - 2, y - 5, 1, 1, 0, c_white, alpha);
		}
		
		// Only attempt to render the name of the actor and the namespace that goes behind said name if the
		// actor actually has a name stored within its respective variable. Otherwise, the name will be an
		// empty string "" and the namespace isn't rendered.
		if (actorName != ""){
			draw_sprite_stretched_ext(spr_textbox_namespace, 0, x - 5, y - 19, actorNameWidth, 13, textboxColor, alpha);
			shader_set_outline(RGB_GRAY, font_gui_small);
			draw_text_outline(x, y - 15, actorName, HEX_WHITE, RGB_GRAY, alpha);
			if (!_decisionState) {shader_reset();} // Don't reset the shader if the decision text needs to be rendered
		}
		
		// Drawing the textbox's decision text whenever it needs to be shown to the player //
		
		// Only attempt to display the decision data array for the current textbox if the player is being
		// given the opportunity to make a decision within by the current textbox, which occurs after the
		// dialogue within said textbox has fully rendered to the screen. Then, this chunk of code will run
		// and render each of those options onto the screen above the previously rendered background elements.
		if (_decisionState){
			shader_set_outline(RGB_GRAY, font_gui_small);
			draw_set_halign(fa_right);
			for (var i = 0; i < numDecisions; i++){
				if (i == decisionIndex){ // Draw the highlighted text and a cursor next to the option.
					var _yPosition, _decisionText; // Can initialize in the loop since this will only ever run once per loop.
					_yPosition = y - (10 * (numDecisions - i - 1)) - 20;
					_decisionText = textboxData[| curTextboxIndex].decisionData[i][0];
					// Drawing the square cursor that goes next to the highlighted option
					draw_sprite_ext(spr_rectangle, 0, CAM_WIDTH - 20 - string_width(_decisionText), _yPosition + 2, 4, 4, 0, HEX_DARK_YELLOW, _decisionElementAlpha);
					draw_sprite_ext(spr_rectangle, 0, CAM_WIDTH - 19 - string_width(_decisionText), _yPosition + 3, 2, 2, 0, HEX_LIGHT_YELLOW, _decisionElementAlpha);
					// Drawing the option text itself; flashing at regular intervals between the highlight color and normal color
					if (highlightOption) {draw_text_outline(CAM_WIDTH - 10, _yPosition, _decisionText, HEX_LIGHT_YELLOW, RGB_DARK_YELLOW, _decisionElementAlpha);}
					else {draw_text_outline(CAM_WIDTH - 10, _yPosition, _decisionText, HEX_WHITE, RGB_GRAY, _decisionElementAlpha);}
				} else{ // Simply draw the option in the default color/outline color.
					draw_text_outline(CAM_WIDTH - 10, y - (10 * (numDecisions - i - 1)) - 20, textboxData[| curTextboxIndex].decisionData[i][0], HEX_WHITE, RGB_GRAY, _decisionElementAlpha);
				}
			}
			draw_set_halign(fa_left);
			
			// Finally, reset the shader before rendering the textbox's text surface. Otherwise, a second 
			// outline will appear on each of the surface's characters, since they are rendered onto the
			// surface with an outline to begin with.
			shader_reset();
		}
		
		// Drawing to the text surface and rendering it on the textbox //
		
		// If the surface is ever randomly flushed out of the current GPU memory, it needs to be reinitialized
		// and the data contained within its buffer needs to be applied to said surface; restoring what the
		// previous surface looked like before being flushed out of memory.
		if (!surface_exists(surfText)){
			surfText = surface_create(textboxWidth, textboxHeight);
			buffer_set_surface(surfTextBuffer, surfText, 0);
		}
		
		// Only allow the textbox's text-to-surface rendering to occur while there are actually still parts
		// of the string that haven't been rendered onto said surface. After that, all that needs to be done
		// is simply rendering that texture, so this entire chunk will be ignored; saving processing time
		// that would be useless otherwise.
		if (nextCharacter < finalCharacter + 1){
			nextCharacter += textSpeed * DELTA_TIME;
			
			// If there isn't a possibility to render a new character onto the text surface, don't bother
			// with any setting of shaders and surface rendering targets since they won't be utilized.
			// Instead, just render the currently visible text to the screen and exit the drawing function.
			if (curCharacter >= floor(nextCharacter)){
				draw_surface_ext(surfText, x, y, 1, 1, 0, c_white, alpha);
				draw_control_info_background(CAM_WIDTH, CAM_HEIGHT, alpha * 0.75);
				return; // "Return" can be used here since this are the last things to need rendering.
			}
			
			// Before rendering new characters to the textbox's text surface, data from the current textbox
			// struct is pulled and stored into local variables for easier access while looping to render
			// all those needed characters. Specifically, it takes the text scaling attributes and the
			// full string from that textbox struct.
			var _xScale, _yScale, _fullText;
			with(textboxData[| curTextboxIndex]){
				_xScale = textXScale;
				_yScale = textYScale;
				_fullText = fullText;
			}
			
			// Once the necessary data has been grabbed from the current textbox struct, the outline shader
			// will begin its execution in order to render what would normally be standard text with a one
			// pixel wide outline of a given color around itself. Also, the rendering target is set to
			// the text surface since it is what is used to display the text for a given textbox.
			shader_set_outline(textOutlineColor, font_gui_small);
			surface_set_target(surfText);
			
			// Being looping for however many iterations are needed relative to the difference between the
			// values of "curCharacter" and the interger representation of "nextCharacter"; parsing any
			// necessary color data from the string and pulling out the necessary amount of characters
			// for rendering.
			var _curChar = "";
			while(curCharacter < floor(nextCharacter)){
				_curChar = string_char_at(_fullText, curCharacter);
				
				// An asterisk "*" was found, this means that a color code needs to be parsed in order to
				// set the next chunk of text to the desired colors. It does this by looping again until
				// a second asterisk character is hit, which ends the parsing process for the required
				// color.
				if (_curChar == "*"){
					// Before starting the color name parsing, some temporary variables must be initialized
					// to assist with that process. Namely, the string of parsed color name and also a
					// temporary offset starting from the NEXT possible character after the first asterisk,
					// since the symbol itself does nothing other than trigger this process.
					var _colorName, _offset;
					_colorName = "";
					_offset = curCharacter + 1;
					while(_offset <= finalCharacter){
						_curChar = string_char_at(_fullText, _offset);
						
						// That second required asterisk was hit, so the color name will have assumed to
						// be successfully parsed from the text data. It will then take this parsed string
						// to attempt to retrieve the matching colors for the next region of text before
						// exiting this data parsing loop.
						if (_curChar == "*"){
							var _colorData = get_text_color_data(_colorName);
							textColor =			_colorData[0];
							textOutlineColor =	_colorData[1];
							curCharacter =		_offset + 1;
							nextCharacter =		curCharacter;
							break;
						}
						
						// Keep adding characters and increasing the offset until that next required
						// asterisk character it hit in order to end the color code parsing.
						_colorName += _curChar;
						_offset++;
					}
					continue;
				}
				// The hashtag "#" characer signifies the end of a region of text that is colored whatever
				// had been set previously by an asterisk pair plus inner color name. It simply resets
				// the previous color with the text's default colors of white and gray for the inner and
				// outline, respectively.
				else if (_curChar = "#"){
					textColor =			HEX_WHITE;
					textOutlineColor =	RGB_GRAY;
					curCharacter++;
					nextCharacter++;
					continue;
				}
				// Much like the logic that is used for formatting strings within the custom "string_format_width"
				// function, this code checks for any spaces or hyphens in the text in order to see if the 
				// maximum string width will be exceeded by adding the next word to the current line.
				else if (_curChar == " " || _curChar == "-"){
					var _nextWordWidth, _skipCharacter, _curCharExt;
					_nextWordWidth = 0;
					_skipCharacter = false;
					for (var i = curCharacter + 1; i <= finalCharacter; i++){
						// Grab the next available character after the space of the hyphen, but if it is
						// found to be the initializer character for reading a color code; don't bother
						// with this loop and simply exit before doing anything.
						_curCharExt = string_char_at(_fullText, i);
						if (_curCharExt == "*") {break;}
						
						// If the string has hit it's last character OR a space/hypen is the current 
						// character, perform the check to see if the current word should be placed on 
						// the current line or if it should be put on a new line instead. If it moves onto
						// a new line, the character that started this wrapping check will be placed at
						// the current target position for the character if it was a hyphen and not a
						// space character.
						if (i == finalCharacter || _curCharExt == " " || _curCharExt == "-"){
							if (characterX + _nextWordWidth >= maxLineWidth){
								if (_curChar == "-") {draw_character(_curChar, textColor, textOutlineColor, _xScale, _yScale);}
								characterX = 0;
								characterY += string_height("M") * _yScale;
								_skipCharacter = true;
							}
							break; // Exits out of the current for loop; regardless of it's completed or not.
						}
						
						// Keep adding the "next" character's width to the word's full width until a space,
						// hyphen OR the end of the string has been reached, which will then use this value
						// to determine where that word ends up on a line-to-line basis.
						_nextWordWidth += string_width(_curCharExt) * _xScale;
					}
					
					// 
					if (_skipCharacter){
						curCharacter++;
						continue;
					}
				}
				
				// Display the current character with the currently set colors onto the surface of the
				// textbox's text surface; scaling relative to what is needed from the textbox itself.
				draw_character(_curChar, textColor, textOutlineColor, _xScale, _yScale);
				
				// Make sure to store the current state of the surface into its buffer; preserving it in case
				// the surface is randomly flushed out of the GPU's memory.
				buffer_get_surface(surfTextBuffer, surfText, 0);
				
				// Finally, offset the character's x position by the last rendered character's width, and move
				// onto rendering the next character onto the surface if the value for curCharacter is still
				// lower than what the code thinks the next rendered character should be. (This is all relative
				// to whatever the current text speed is)
				characterX += string_width(_curChar) * _xScale;
				curCharacter++;
			}
			
			// After looping through and adding all of the necessary characters to the surface that will
			// then be placed onto the textbox itself, reset the rendering target and stop using the 
			// outline shader while rendering.
			surface_reset_target();
			shader_reset();
		}
		
		// Display whatever text is currently on the surface at the end of each draw_gui call for the textbox.
		// This ensures that it will always be placed above the textbox's background elements.
		draw_surface_ext(surfText, x, y, 1, 1, 0, c_white, alpha);
		
		// Draw the final element (the background that the input control information goes on) of the textbox
		// af an feathered rectangle that is placed along the bottom of the screen behind said information.
		draw_control_info_background(CAM_WIDTH, CAM_HEIGHT, alpha * 0.75);
	}
	
	/// @description Code that should be placed into the "Cleanup" event of whatever object is controlling
	/// obj_textbox_handler. In short, it will cleanup any data that needs to be freed from memory that isn't 
	/// collected by Game Maker's built-in garbage collection handler.
	cleanup = function(){
		// Removes the text's surface if it still exists in memory, and also removes the surface's buffer from
		// memory as well.
		if (surface_exists(surfText)) {surface_free(surfText);}
		buffer_delete(surfTextBuffer);
		
		// Delete the data structure that is responsible for storing all the existing entity's given states
		// from BEFORE the textbox was open, since the textbox modifies those states temporarily.
		ds_map_destroy(entityStates);
		
		// Loop through all of the actor data contained within the map to delete each struct pointer from it.
		// After that, the map itself is destroyed and removed from memory.
		var _key = ds_map_find_first(actorData);
		while(!is_undefined(_key)){
			delete actorData[? _key];
			_key = ds_map_find_next(actorData, _key);
		}
		ds_map_destroy(actorData);
		
		// Much like above, remove the structs containing data for each of the remaining textboxes. After that,
		// destroy the list much like the map above; clearing it from memory.
		for (var i = 0; i < totalTextboxes; i++) {delete textboxData[| i];}
		ds_list_destroy(textboxData);
	}
	
	/// @description Gathers input for the textbox's input variables from either the keyboard or the gamepad
	/// depending on which one is considered the active controller by the game.
	get_input = function(){
		if (!global.gamepad.isActive){ // Gathering Keyboard Input
			inputAdvance =	keyboard_check_pressed(global.settings.keyAdvance);
			inputUp =		keyboard_check_pressed(global.settings.keyMenuUp);
			inputDown =		keyboard_check_pressed(global.settings.keyMenuDown);
			inputSelect =	keyboard_check_pressed(global.settings.keySelect);
		} else{ // Gathering Controller Input
			var _deviceID = global.gamepad.deviceID;
			inputAdvance =	gamepad_button_check_pressed(_deviceID, global.settings.gpadAdvance);
			inputUp =		gamepad_button_check_pressed(_deviceID, global.settings.gpadMenuUp);
			inputDown =		gamepad_button_check_pressed(_deviceID, global.settings.gpadMenuDown);
			inputSelect =	gamepad_button_check_pressed(_deviceID, global.settings.gpadSelect);
		}
	}
	
	/// @description A simple default state for the textbox. It gathers input from the user and then sees
	/// whether or not the textbox should autofill its text/advance, or open the text log for the player
	/// to view all previous textboxes for the current string of textboxes OR full cutscene.
	state_default = function(){
		// First, gather input from the currently active control method through the function below.
		get_input();
		
		// Whenever the advancing text input has been detected, the textbox handler will check if the text
		// has been fully displayed by the typewriter effect. If not, it will skip the animation. Otherwise,
		// it will check if there is a decision list that needs to be shown to the player. If so, the textbox
		// will have its state set to choose a decision. Otherwise, the textbox will automatically advance to
		// the next available textbox; closing itself out if there are no more textboxes after the current one.
		if (inputAdvance){
			if (nextCharacter > finalCharacter){ // Opening the next textbox OR allowing the player to make a decision
				var _numDecisions = array_length(textboxData[| curTextboxIndex].decisionData);
				if (_numDecisions <= 1){ // No decision list or it has only one option; open next textbox
					curTextboxIndex++;
					if (curTextboxIndex == totalTextboxes || textboxData[| curTextboxIndex - 1].closeTextbox){
						alphaTarget = 0;
						actorSwap = false;
						return; // Exit the event since the textbox is now closed.
					}
					// Stores either true or false to let the textbox know it needs to perform its closing and 
					// opening animation in between the two textboxes. This is done since a new actor is in
					// control of the upcoming textbox.
					actorSwap = (textboxData[| curTextboxIndex - 1].actorID != textboxData[| curTextboxIndex].actorID);
					if (actorSwap){ // Begin closing animation if a new actor is next to use the textbox
						alphaTarget = 0;
						return; // Exit the event since the next textbox opens AFTER the closing animation
					}
					// If no actor swap occurred, simply open the next textbox from here, which will instantly
					// start displaying the next string without an animation in between.
					open_next_textbox();
				} else{ // A decision needs to be made by the player for the current textbox
					// First, jump into the state that allows the player to make a decision based on the 
					// available options; pausing the textbox until they do so.
					object_set_next_state(state_choose_decision);
					// Next, set the alpha value for this section to transition to fully opaque in a simple
					// fading animation; also get the total number of options for the player to choose from
					// for later use in the code.
					decisionAlphaTarget = 1;
					decisionIndex = 0;
					numDecisions = _numDecisions;
					// Finally, update the control information that is currently being displayed on the bottom
					// of the screen to show the player what inputs allow them to move the cursor to other
					// options and what input allows them to select said option.
					control_info_add_displayed_icon(INPUT_MENU_UP, "", ALIGNMENT_LEFT);
					control_info_add_displayed_icon(INPUT_MENU_DOWN, "Choose Option", ALIGNMENT_LEFT);
					control_info_edit_displayed_icon(0, INPUT_SELECT, "Select", ALIGNMENT_RIGHT);
				}
			} else{ // Filling out the textbox's text instantly
				nextCharacter = finalCharacter;
			}
		}
	}
	
	/// @description A state that the textbox is run in whenever it needs to get a decision from the player
	/// based on a list of options provided by the currently viewed textbox. After the player presses the
	/// select input the state will parse what to do based on the decision index and then return the textbox
	/// back to its normal state.
	state_choose_decision = function(){
		// Before any input logic can be processed, the highlight timer that will flash the highlighted option
		// at regular intervals until it is no longer being highlighted, will be decremented based on delta
		// time until the flag needs to be flipped and the timer needs to be reset.
		highlightTimer -= DELTA_TIME;
		if (highlightTimer <= 0){ // Flip the flag for flashing the option and reset the timer
			highlightTimer += OPTION_FLASH_INTERVAL;
			highlightOption = !highlightOption;
		}
		
		// Much like the highlight timer, the alpha level needs to be updated before the input can be processed
		// by the state. However, unlike the above chunk of code, this code will actually prevent the input
		// processing below it from being ran until the alpha level matches whatever the target value is.
		if (decisionAlpha != decisionAlphaTarget){
			decisionAlpha = value_set_linear(decisionAlpha, decisionAlphaTarget, 0.1);
			// Closing out the state if the target alpha and current alpha of the decision area of the
			// textbox are both set to 0. In this case, the state will be reset to the default state and
			// the index of current textbox will be set to whatever is stored in the decision data array.
			if (decisionAlpha == 0 && decisionAlphaTarget == 0){
				// First, change the state back to the default state in order to restore normal textbox 
				// functionality; changing the "curState" value instantly to avoid weird issues.
				object_set_next_state(state_default);
				curState = state_default; // Prevents accidental overwriting if the next textbox has a shake applied to it
				// Assign the target index that the cutscene's current instruction index will be assigned
				// to once said textbox has finished its execution. If this is any value other than -1
				// it will manipulate that scene instruction value. Otherwise, nothing will happen.
				var _data = textboxData[? curTextboxIndex];
				if (CUTSCENE_MANAGER.isCutsceneActive) {cutsceneTargetIndex = _data[decisionIndex][2];}
				// Move onto whatever textbox the stored index within the decision data contains. This allows
				// for branching dialogue and different outcomes based on decisions chosen.
				curTextboxIndex = _data.decisionData[decisionIndex][1];
				open_next_textbox();
				// Reset the control information to remove the "Up" and "Down" inputs from it and reset the
				// right-aligned input to show the advancement input for the textbox.
				control_info_remove_displayed_icon(1); // Deletes the "Menu Up" display data
				control_info_remove_displayed_icon(1); // Deletes the "Menu Down" display data
				control_info_edit_displayed_icon(0, INPUT_SELECT, "Next", ALIGNMENT_RIGHT);
			}
			return; // Don't allow player input during the opening/closing animation
		}
		
		// First, gather input from the currently active control method through the function below.
		get_input();
		
		// If the selection input has been pressed by the user, the processing for fading out the display
		// before processing the decision chosen and returning to the default state, will begin.
		if (inputSelect){
			decisionAlphaTarget = 0;
			return; // Exit early to prevent the decision index from updating
		}
		
		// Handling menu cursor movement in a simple way--having no automatic scrolling since there won't
		// ever be too many options to choose from. In short, it stores the value based on the up and down
		// inputs; resulting in a -1 if the up key is pressed, 1 for the down key, and 0 if both or none
		// are pressed. After that, the value is wrapped around if it exceeds the bounds of the list.
		var _input = (inputDown - inputUp);
		decisionIndex += _input;
		if (decisionIndex < 0) {decisionIndex = numDecisions - 1;}
		else if (decisionIndex >= numDecisions) {decisionIndex = 0;}
		
		// Resetting the highligting variables to ensure that the newly selected option is always set to
		// highlight itself initially. Otherwise, there's a chance that an option change can occur while
		// the flag is set to false; not converying the change properly without audio if that's the case.
		if (_input != 0){
			highlightTimer = OPTION_FLASH_INTERVAL;
			highlightOption = true;
		}
	}
	
	/// @description A simple function that draws a character onto the textbox's surface at a given position.
	/// The position can be horiztonally offset whether or not a portrait image is visible, and the color and
	/// outline color's are set based on their respecitve argument fields.
	/// @param character
	/// @param color
	/// @param outlineColor
	/// @param xScale
	/// @param yScale
	draw_character = function(_character, _color = HEX_WHITE, _outlineColor = RGB_GRAY, _xScale = 1, _yScale = 1){
		if (characterX == 0 && _character == " ") {return;}
		draw_text_outline((2 * _xScale) + characterX + textOffsetX, 1 + characterY, _character, _color, _outlineColor, 1, _xScale, _yScale);
	}
	
	/// @description Another realtively simple drawing function that will render a background for the
	/// current control information to be placed upon; that background being a black rectangle that is
	/// feathered on the left, top, and right sides.
	/// @param camWidth
	/// @param camHeight
	/// @param alpha
	draw_control_info_background = function(_camWidth, _camHeight, _alpha){
		shader_set(shd_feathering);
		with(global.shaderFeathering){
			shader_set_uniform_f(sFadeStart, 60, _camHeight - 5, _camWidth - 60, _camHeight);
			shader_set_uniform_f(sFadeEnd, -30, _camHeight - 20, _camWidth + 30, _camHeight);
			draw_sprite_ext(spr_rectangle, 0, 0, _camHeight - 20, _camWidth, 20, 0, HEX_BLACK, _alpha);
		}
		shader_reset();
	}
	
	/// @description A simple fucntion that returns a struct containing data unique to each of the game's
	/// actors. An actor is simply an enumerator value that relates to a character or type of textbox for
	/// actors that aren't tied to actual game characters. The structs contain the following:
	///
	///		actorName		--		Stores a string that is placed within the textbox's namespace area.
	///		portraitSprite	--		Stores the index for the sprite that is the actor's portrait.
	///		textboxColor	--		Stores a unique color for the textbox when the actor is active.
	///
	/// @param actor
	get_actor_data = function(_actor){
		switch(_actor){
			case Actor.NoActor: // The default actor, which is a dummy for just displaying simple textboxes and the like.
				return {
					actorName : "",
					portraitSprite : -1,
					textboxColor : HEX_BLUE,
				};
			case Actor.Test01:
				return {
					actorName : "Claire",
					portraitSprite : spr_claire_portraits,
					textboxColor : make_color_rgb(68, 0, 188),
				};
		}
	}
	
	/// @description Retrieves a pre-set pair of colors for text within the textbox given the color code
	/// that was provided to the function. If no valid color is found with the argument, the default
	/// colors of white and gray will be set, instead.
	/// @param colorName
	get_text_color_data = function(_colorName){
		switch(_colorName){
			case RED:			return [HEX_RED, RGB_DARK_RED];
			case GREEN:			return [HEX_GREEN, RGB_DARK_GREEN];
			case BLUE:			return [HEX_LIGHT_BLUE, RGB_DARK_BLUE];
			case YELLOW:		return [HEX_LIGHT_YELLOW, RGB_DARK_YELLOW];
			default:			return [HEX_WHITE, RGB_GRAY];
		}
	}
	
	/// @description A simple function that condenses the entire process of resetting variables and data in
	/// order to prepare for the next chunk of text to be displayed within the textbox down to a single line
	/// of code. Necessary due to the two places in code where the next textbox can be opened.
	open_next_textbox = function(){
		// Reset the character offset values to ensure the characters for the next textbox aren't
		// placed at the wrong coordinates for the surface.
		characterX = 0;
		characterY = 0;
		
		// Also, reset all the typerwriter effect variables in order to begin it again with the new
		// chunk of text to be rendered. Reset the text color variables back to the defaults in case they
		// weren't reset by the end of the previous textbox's text rendering finished.
		curCharacter = 1;
		nextCharacter = 1;
		textColor = HEX_WHITE;
		textOutlineColor = RGB_GRAY;
		
		// Call the functions that will apply the additional optional effects for the newly opened textbox;
		// whether it should close out the textbox handler earlier, play a sound, apply the shaking effect,
		// and whatever other effects are able to occur on a per-textbox basis; the other function updating
		// the actor information used to color the textbox, show a name, and even their current portrait
		// to show alongside the text.
		apply_extra_textbox_effects(curTextboxIndex);
		update_current_actor_info(actorSwap);
		
		// Reset the text surface by clearing out the buffer of any data and applying that cleared
		// out data to the surface, which should set every pixel to (0, 0, 0, 0).
		if (!surface_exists(surfText)) {surfText = surface_create(textboxWidth, textboxHeight);}
		buffer_fill(surfTextBuffer, 0, buffer_u32, 0, textboxWidth * textboxHeight * 4);
		buffer_set_surface(surfTextBuffer, surfText, 0);
	}
	
	/// @description A simple function that sets the variables responsible for showing the actor's name and
	/// portrait--along with the textbox color required for said actor; to the actual variables that will
	/// be used in the textbox rendering code to display all this information. Optionally, the actor data
	/// can be skipped over so that only the portrait's image index is updated; saving on a bit of code
	/// execution.
	update_current_actor_info = function(_updateActorVariables){
		if (_updateActorVariables){
			var _actor = actorData[? textboxData[| curTextboxIndex].actorID]; // This keeps the code looking nicer
			actorName =				_actor.actorName;
			actorPortrait =			_actor.portraitSprite;
			textboxColor =			_actor.textboxColor;
			
			// Create the backing color for the decision display area, which is a slightly darker variation
			// of the textbox's main color. It's created here in order to prevent the draw event from having
			// to create this color every frame using what this variable stores; saving processing time.
			decisionBackColor =		make_color_rgb(color_get_red(textboxColor) * 0.25, 
												   color_get_green(textboxColor) * 0.25,
												   color_get_blue(textboxColor) * 0.25);
			
			// Store the width of the actor's name so that it evenly fits within the textbox's namespace.
			draw_set_font(font_gui_small); // Set the font for an accurate calculation.
			actorNameWidth =		string_width(actorName) + 9;
			
			// Determine if the text needs to be offset in order to make room for a portrait image. If that is
			// the case, an offset of 50 pixels will be added in order to allow enough room for it. The images 
			// are 46 by 46 pixels, so the additional 4 pixels replicates the offest without the portrait nicely.
			if (actorPortrait != -1){
				textOffsetX = 50;
				maxLineWidth = textboxWidth - 58;
			} else{ // No portrait exists; clear out any text offset values.
				textOffsetX = 0;
				maxLineWidth = textboxWidth - 8;
			}
		}
		// The only value that is stored on a per-textbox basis; not per-actor. So, it is always updated when
		// this function gets called.
		actorPortraitIndex =		textboxData[| curTextboxIndex].actorPortraitIndex;
	}
	
	/// @description Ends the execution for the textbox by cleaning up all the memory and data that is no 
	/// longer in use now that the textbox is closed. Also, set the active state of textbox to false and
	/// reset the game's state back to what it was previously.
	textbox_end_execution = function(){
		// Clear out the buffer by writing all 0s to it, and then free the surface from memory for the time
		// being since it's no longer being used to render text onto the screen.
		buffer_fill(surfTextBuffer, 0, buffer_u32, 0, textboxWidth * textboxHeight * 4);
		if (surface_exists(surfText)) {surface_free(surfText);}
	
		// Run through each of the actors that were required for the current chunk of textboxes and delete
		// their pointers from memory; signaling to Game Maker to unload the struct data found within each
		// pointer.
		var _key = ds_map_find_first(actorData);
		while(!is_undefined(_key)){
			delete actorData[? _key];
			_key = ds_map_find_next(actorData, _key);
		}
		ds_map_clear(actorData);
		
		// Create a local variable that allows for easy accessing of the three state indexes from the array
		// that is stored within each of the map indexes of the entityStates ds_map.
		var _states = noone;
		
		// Loop through all of the stores entity state data and bring the states back to each of the entities
		// that still exist within the current room; clearing that entire list out after the fact. However,
		// this will only occur when a textbox has been created outside of a cutscene.
		if (!CUTSCENE_MANAGER.isCutsceneActive){
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
			
			// The game state will also only be reset if the game isn't already within a cutscene when the
			// textbox has completed its execution. Otherwise, it will restore the previous game state on
			// its own since it also sets it to the "cutscene" state upon its execution starting when
			// there is no cutscene playing.
			GAME_SET_STATE(GAME_STATE_PREVIOUS, true);
		}
	
		// Run through the list and delete all the structs found within it. After that, clear out the list
		// so it becomes completely empty of data; ready for new textbox data to be added in.
		for (var i = 0; i < totalTextboxes; i++) {delete textboxData[| i];}
		ds_list_clear(textboxData);
		totalTextboxes = 0; // Reset this value so it can be used accurately on subsequent textbox groups.
		
		// If the textbox was in control of the textbox during its execution it needs to clean out the input
		// display data before fully ending its own execution. To do this, the controller variable is reset,
		// the alpha is set to fully opaque, and the displayed icon list is cleared from memory.
		with(CONTROL_INFO){
			if (curController == TEXTBOX_HANDLER){
				control_info_clear_displayed_icons();
				curController = noone;
				alpha = 0;
			}
		}
	
		// Finally, set the textbox's state to NO_STATE, set its activity flag to false to halt its 
		// updating and rendering logic.
		object_set_next_state(NO_STATE);
		isTextboxActive = false;
	}
	
	/// @description 
	/// @param index
	apply_extra_textbox_effects = function(_index){
		// 
		var _textbox = textboxData[| _index];
		if (is_undefined(_textbox)) {return;}
		
		// 
		finalCharacter =	string_length(_textbox.fullText);
		
		// 
		shakeCurStrength =	_textbox.shakeData[0];
		shakeDuration =		_textbox.shakeData[1];
		if (shakeCurStrength != 0 && shakeDuration != 0) {object_set_next_state(NO_STATE);}
		
		// 
		var _soundEffect = _textbox.soundEffect; // Stores the array reference for a cleaner look for the function call below.
		if (_soundEffect[0] != NO_SOUND) {audio_play_sound_ext(_soundEffect[0], 0, _soundEffect[1], _soundEffect[2], false);}
	
		// 
		closeTextbox =		_textbox.closeTextbox;
	}
}

#endregion

#region Global functions related to obj_textbox_handler

/// @description A simple function that prepares the textbox to begin displaying its data to the player on
/// a per-page basis until it runs out of pages. It does so by resetting any necessary variables to their
/// defaults and setting others to their required values.
function textbox_begin_execution(){
	with(TEXTBOX_HANDLER){
		// Don't bother reinitializing the textbox if it's currently in an active state.
		if (isTextboxActive) {return;}
		
		// 
		curTextboxIndex = 0;
		
		// Reset the offset position values that will be used for rendering the next character onto the
		// textbox's text surface with a smooth typewriter-like scrolling effect.
		characterX = 0;
		characterY = 0;
		
		// Next, reset the variables responsible for the typerwriter text scrolling effect and also set the
		// final character's value to the length of the 0th textbox data's text data. Set the text speed
		// variable to match the settings' "text speed" option value as well.
		curCharacter = 1;
		nextCharacter = 1;
		textSpeed = global.settings.textSpeed;
		
		// Reset the color data to the standard of white and gray in case it wasn't reset by the closing
		// of the previous textbox. (Meaning a "#" wasn't found in the last textbox's text data)
		textColor = HEX_WHITE;
		textOutlineColor = RGB_GRAY;
		
		// After all the text variables have been set to their desired values, set the textbox's animation
		// variables by placing the textbox temporarily off screen and setting its alpha target to full
		// opacity.
		y = TEXTBOX_START_Y;
		alphaTarget = 1;
		
		// Assign the textbox's state to its default and flip the "active" flag to true to signify to
		// other objects that the textbox is currently moving through the data that has been loaded into
		// the text data structure.
		object_set_next_state(state_default);
		isTextboxActive = true;
		
		// Call the two functions that will apply additional effects that could be contained within the
		// textbox's struct (shaking effect, unique starting sound effect, etc.) and actor information,
		// (textbox color, name, portrait, etc.) respectively.
		apply_extra_textbox_effects(0);
		update_current_actor_info(true);
		
		// When the game isn't currently within a cutscene already, the states of all of the entities will
		// be stored while they are cleared out from the entity objects themselves; restoring those states
		// after the textbox has finished its execution. HOWEVER, this doesn't need to occur when a true
		// cutscene is being executed since the cutscene handler will perform all this on its own.
		if (!CUTSCENE_MANAGER.isCutsceneActive){
			// Loop through every currently existing entity and add their three state variables to an
			// array that is then stored within the textbox's entity state storage map.
			var _entityStates = entityStates;
			with(par_dynamic_entity){
				ds_map_add(_entityStates, id, [curState, nextState, lastState]);
				// After adding the state values to the storage map, set all the state variables to NO_STATE to
				// halt any execution of current states for the duration of the textbox's execution.
				curState = NO_STATE;
				nextState = NO_STATE;
				lastState = NO_STATE;
			}
			
			// Since a textbox existing alone technically works much like how a cutscene would within the
			// game world, the state of the game will be set to Cutscene to apply all those same effects
			// for the textbox's execution duration.
			GAME_SET_STATE(GameState.Cutscene);
		}
		
		// Display the textbox's controls at the bottom of the screen; right below the actual textbox. If the
		// textbox isn't currently set to log text, that input will not be shown; only the "next" input will
		// be shown to the player.
		if (CONTROL_INFO.curController == noone){
			control_info_clear_displayed_icons(); // Always clear in case there is leftover data
			control_info_add_displayed_icon(INPUT_ADVANCE, "Next", ALIGNMENT_RIGHT, true);
			CONTROL_INFO.curController = TEXTBOX_HANDLER;
		}
	}
}

/// @description A simple function that adds text to the textbox's data list. Optionally, an actor can be
/// supplied in order to display a name and also a portrait if a valid index is provided within either of
/// the two argument fields. Color data isn't added within this function to allow for better readability and
/// flexibility when coding textbox stuff.
/// @param text
/// @param actor
/// @param portraitIndex
/// @param textXScale
/// @param textYScale
function textbox_add_text_data(_text, _actor = Actor.NoActor, _portraitIndex = -1, _textXScale = 1, _textYScale = 1){
	with(TEXTBOX_HANDLER){
		// Only add the actor's information to the actor map if it doesn't exist already. This prevents code
		// from being duplicated if each actor was stored within each textbox.
		if (is_undefined(actorData[? _actor])) {ds_map_add(actorData, _actor, get_actor_data(_actor));}
		
		// Add the data as a struct into the list of currently existing textbox data. It contains the full
		// string of text to display, the color data for changing text colors mid-string, the actor's ID
		// index for easy reference, and the portrait sprite's image index if one should be displayed.
		ds_list_add(textboxData, {
			fullText :				_text,
			textXScale :			_textXScale,
			textYScale :			_textYScale,
			decisionData :			array_create(0, 0),
			shakeData :				array_create(2, 0),
			soundEffect :			[NO_SOUND, SOUND_VOLUME, 1],
			actorID :				_actor,
			actorPortraitIndex :	_portraitIndex,
			closeTextbox :			false, // Can be altered when calling the function "textbox_set_to_close"
		});
		
		// Finally, increment the total number of textboxes by one. This value is used to determine when to
		// fade the control information at the bottom of the screen in and out of visibility. Otherwise, it
		// will keep doing so on a per-textbox basis, which looks wrong.
		totalTextboxes++;
	}
}

/// @description A simple function that adds a option to the decision data found within the most recently
/// created textbox. Each index of the decision data array contains another array that has two values:
///		Index		Data
///			0	=		Decision's Descriptor
///			1	=		Outcome Textbox Index
///			2	=		Target Instruction Index (ONLY FOR CUTSCENES)
/// @param optionText
/// @param outcomeIndex
function textbox_add_decision_data(_optionText, _outcomeIndex, _cutsceneOutcomeIndex = -1){
	with(TEXTBOX_HANDLER){
		with(textboxData[| totalTextboxes - 1]){
			decisionData[array_length(decisionData)] = [
				_optionText,
				_outcomeIndex,
				_cutsceneOutcomeIndex
			];
		}
	}
}

/// @description A simple function that adds a shaking effect to a most recently created textbox; putting a 
/// -1 instead to signify the most recently added textbox data. In short, it will add an array of size two 
/// to the textbox's "shake data" which will then be referenced and applied to the opening animation of that 
/// textbox.
/// @param shakeStrength
/// @param shakeDuration
function textbox_add_shake_effect(_shakeStrength, _shakeDuration){
	with(TEXTBOX_HANDLER) {textboxData[| totalTextboxes - 1].shakeData = [_shakeStrength, _shakeDuration];}
}

/// @description 
/// @param sound
/// @param volume
/// @param pitch
function textbox_add_sound_effect(_sound, _volume = SOUND_VOLUME, _pitch = 1){
	with(TEXTBOX_HANDLER){
		with(textboxData[| totalTextboxes - 1]){
			array_set(soundEffect, 0, _sound);
			array_set(soundEffect, 1, _volume);
			array_set(soundEffect, 2, _pitch);
		}
	}
}

/// @description An extremely simple function that will set a textbox to signal to the textbox handler that
/// it will need to close itself after the player attempts to advance the "next" textbox, if there is one.
/// It's used exclusively for whenever there is branching dialogue for a textbox; allowing different dialogue
/// to occur for each unique decision.
function textbox_set_to_close(){
	with(TEXTBOX_HANDLER) {textboxData[| totalTextboxes - 1].closeTextbox = true;}
}

#endregion