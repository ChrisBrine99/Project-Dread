/// @description Stores all expanded functions that work off of the same principles of a standard GML
/// function. Things like new collision functions, new instance/struct creation functions, text rendering
/// functions, and so on will be found within this script.

#region Instance creation functions with extended functionality

/// @description A simple function that provides some structure to the creation process of making new struct
/// or lightweight object instances. In order for a struct to successfully be created, it must not be one that 
/// exists as a singleton; otherwise that would cause unnecessary duplication of important functions/code 
/// handled by the respective singleton struct.
/// @param struct
function instance_create_struct(_struct){
	if (get_singleton_object_key(_struct) == undefined){
		var _structInstance = new _struct();
		if (variable_struct_exists(_structInstance, "initialize")) {_structInstance.initialize();}
		return _structInstance;
	}
	return noone; // No instance was created; return noone to signify that.
}

/// @description A simple function that reflects the "instance_create_struct" function, but instead of dealing
/// with the creation of the structs and prevention of singleton creation--it prevents the deletion of them.
/// @param instanceID
function instance_destroy_struct(_structID){
	if (get_singleton_object_key(_structID.object_index) == undefined){
		if (variable_struct_exists(_structID, "cleanup")) {_structID.cleanup();}
		delete _structID; // Destroy the struct if it isn't a singleton
	}
}

/// @description A simple function that creates an object at a given position within the room at a constant
/// depth value of 205. It also prevents the creation of duplicate singleton objects, which are created at
/// the start of the game much like the singleton struct objects are.
/// @param x
/// @param y
/// @param object
function instance_create_object(_x, _y, _object){
	if (get_singleton_object_key(_object) == undefined) {return instance_create_depth(_x, _y, 30, _object);}
	return noone; // No instance was created; return noone to signify that.
}

/// @description A simple function that reflects the "instance_create_object" function, but instead of dealing
/// with the creation of duplicate singleton objects it prevents the deletion of those singleton objects.
/// @param instanceID
/// @param performEvents
function instance_destroy_object(_objectID, _performEvents = true){
	if (get_singleton_object_key(_objectID.object_index) == undefined){
		instance_destroy(_objectID, _performEvents);
	}
}

#endregion

#region Object collision functions with extended functionality

/// @description An extension of the standard "place_meeting" function that allows for three-dimensional
/// collision checks to occur within a wholly 2D game. It does so by turning the z-axis values into another
/// rectangle check that is done within the horizontal space, but it will look like 3D exists in the game.
/// @param x
/// @param y
/// @param z
/// @param object
function place_meeting_3d(_x, _y, _z, _object){
	// Create some variables that will be referenced later in the code--for both seeing if a collision has
	// been detected (This is a combination of both "_xyMeeting" and "_zMeeting"'s results from the function.
	// The horizontal collision check is done as the first thing within the function; storing its result in
	// the "_xyMeeting" variable.
	var _xyMeeting, _zHeight, _zMeeting;
	_xyMeeting = instance_place(_x, _y, _object);
	_zHeight = zHeight;
	_zMeeting = false;
	
	// Only bother checking for a Z collision if there was a collision detected with Game Maker's standard
	// 2D collision code. This will then compare the z-axis information of both colliding objects to see
	// if a collision was found; returning "true" or "false" depending on that condition.
	if (_xyMeeting){
		with(_xyMeeting) {_zMeeting = rectangle_in_rectangle(0, z, 1, z - zHeight, 0, _z, 1, _z - _zHeight);}
	}
	
	// Returns if a collision has been detected on both the horizontal axis (The standard Game Maker collision
	// check) AND the fake z-axis. (This is done using the "rectangle_in_rectangle" check with both instance's
	// z values and their heights along said axis) Both must be true for a collision to be true.
	return (_xyMeeting && _zMeeting);
}

#endregion

#region Audio playback functions with extended functionality

/// @description A simple extension of the standard "audio_play_sound" function that allows the function to
/// stop any previous instances of a given sound from playing before playing the new instance of it. Also, it
/// is able to manipulate the volume and pitch of the sound on a per-instance basis.
/// @param sound
/// @param priority
/// @param volume
/// @param pitch
/// @param stopPrevious
function audio_play_sound_ext(_sound, _priority, _volume, _pitch, _stopPrevious){
	if (_stopPrevious && audio_is_playing(_sound)) {audio_stop_sound(_sound);}
	var _soundID = audio_play_sound(_sound, _priority, false);
	audio_sound_gain(_soundID, _volume, 0);
	audio_sound_pitch(_soundID, _pitch);
	return _soundID; // Returns the unique ID for the sound played for easy manipulation outside of the function.
}

/// @description Much like the above function, this audo function will extend the functionality of the built-in
/// "audio_play_sound_at" function, which allows for sounds that fade based on distance and play louder in
/// whichever ear is closer to the audio's position. The extended functionality allows the previous instance
/// of the sound to be stopped automatically, and the pitch/volume of the sound can be adjusted in the same
/// function call. On top of that, the fade's starting distance and the maximum distance for the sound to be
/// audible can also be adjusted.
/// @param x
/// @param y
/// @param sound
/// @param priority
/// @param volume
/// @param pitch
/// @param refDistance
/// @param maxDistance
/// @param falloffFactor
/// @param stopPrevious
function audio_play_sound_at_ext(_x, _y, _sound, _priority, _volume, _pitch, _refDistance, _maxDistance, _falloffFactor, _stopPrevious){
	if (_stopPrevious && audio_is_playing(_sound)) {audio_stop_sound(_sound);}
	var _soundID = audio_play_sound_at(_sound, _x, _y, 0, _refDistance, _maxDistance, _falloffFactor, false, _priority);
	audio_sound_gain(_soundID, _volume, 0);
	audio_sound_pitch(_soundID, _pitch);
	return _soundID; // Returns the unique ID for the sound played for easy manipulation outside of the function.
}

#endregion

#region Text rendering functions with extended functionality

/// @description A simple function that allows both axes of text alignment to be altered with a single line
/// of code; removing clutter from the already cluttered drawing events that Game Maker inevitably achieves.
/// @param halign
/// @param valign
function draw_set_text_align(_hAlign, _vAlign){
	draw_set_halign(_hAlign);
	draw_set_valign(_vAlign);
}

/// @description A simple function that condenses the reset for both the horizontal and vertical text 
/// alignment (Back to fa_left and fa_top, respectively) into a single, more readable, line of code instead 
/// of the two calls necessary to reset them normally.
function draw_reset_text_align(){
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

/// @description Renders a string of text onto the screen, but with a one-pixel outline relative to what a
/// "pixel" if for the current string--altered by how large or small the scaling factors on both axes. In
/// short, it will use the outline shader to render the text with an outline onto the screen at the given
/// coordinates; scaling and rotating being possible, but optional.
/// @param x
/// @param y
/// @param string
/// @param innerColor
/// @param outerColor[r/g/b]
/// @param alpha
/// @param xScale
/// @param yScale
/// @param angle
function draw_text_outline(_x, _y, _string, _innerColor, _outerColor, _alpha, _xScale = 1, _yScale = 1, _angle = 0){
	outline_set_color(_outerColor); // Sets the correct color to be used by the outline shader
	draw_text_transformed_color(_x, _y, _string, _xScale, _yScale, _angle, _innerColor, _innerColor, _innerColor, _innerColor, _alpha);
}

/// @description Renders a string of text onto the screen, but uses a set separation value for each character
/// instead of their unique width values. Allows quickly changing values like timers and such from quivering
/// and shaking as the number values change since each number has a different width with most fonts. An option
/// can be toggled to ignore special characters and use their character's spacing instead of the monospacing.
/// This allows things like timers and other number/special character based values not have odd spacing.
/// @param x
/// @param y
/// @param separation
/// @param string
/// @param innerColor
/// @param outerColor[r/g/b]
/// @param alpha
/// @param xScale
/// @param yScale
/// @param angle
/// @param ignoreSpecialCharacters
function draw_text_outline_monospaced(_x, _y, _separation, _string, _innerColor, _outerColor, _alpha, _xScale = 1, _yScale = 1, _angle = 0, _ignoreSpecialCharacters = false){
	// Outside of the loop, set the color for the string since none of the characters can change color
	// during the rendering loop; saving time instead of placing this within the loop.
	outline_set_color(_outerColor);
	
	// Create some variables to store important data about the program's current text alignment settings which
	// will determine how the monospaced text is rendered relative to the x and y position arguments. Also,
	// get and store the height of the text since it doesn't change from line to line.
	var _curHAlign, _curVAlign, _currentFont, _monospaceHeight;
	_curHAlign = draw_get_halign();
	_curVAlign = draw_get_valign();
	_currentFont = draw_get_font();
	_monospaceHeight = string_height("M") * _yScale;

	// Calculate the initial alignment offset based on the current horizontal text alignment. If it's centered,
	// the text will be aligned to half the current line's width. (This value changes for every new line that
	// is rendered within the loop) The same is true for right-aligned text aside from it offseting by the
	// entire with of the line instead of just half.
	var _alignOffsetX = 0;
	if (_curHAlign == fa_right)			{_alignOffsetX = -string_width_monospace(string_get_line(_string), _separation, _currentFont, _ignoreSpecialCharacters) * _xScale;}
	else if (_curHAlign == fa_center)	{_alignOffsetX = -floor(string_width_monospace(string_get_line(_string), _separation, _currentFont, _ignoreSpecialCharacters) * _xScale / 2);}
	draw_set_halign(fa_left); // Temporaryily set the horizontal alignment to its default for proper rendering.
	
	// Exactly like above, the offset is calculated based on the current text alignment, but for the vertical
	// alignment and y position instead. However, these values aren't changed on a per-line basis like the
	// x offset is because the height of the text can't change every line, but the width can.
	var _alignOffsetY = 0;
	if (_curVAlign == fa_bottom)		{_alignOffsetY = -string_height(_string) * _yScale;}
	else if (_curVAlign == fa_middle)	{_alignOffsetY = -floor(string_height(_string) * _yScale / 2);}
	draw_set_valign(fa_top); // Temporarily set the vartical alignment to its default for proper rendering.
	
	// Loop through the entire string; placing each character in the correct place within the monospacing's
	// width value (The third argument field in the function) If the "ignore special characters" flag is set
	// to true, the monospace width will not be applied to those characters.
	var _length, _offsetX, _offsetY, _curChar;
	_length = string_length(_string);
	_offsetX = 0;
	_offsetY = 0;
	for (var i = 1; i <= _length; i++){
		// Get the current character at the position i within the string. (i ranges from 1 to the length of
		// the provided string) From here, text rendering and new line logic can commence.
		_curChar = string_char_at(_string, i);
		if (_curChar == "\n"){ // 
			if (_curHAlign == fa_right){ // Overwrite the previous alignment by getting the width of the next line in the string.
				_alignOffsetX = -string_width_monospace(string_get_line(_string, i + 1), _separation, _currentFont, _ignoreSpecialCharacters) * _xScale;
			} else if (_curHAlign == fa_center){ // The same effect as above, but it only aligns for half the width; centering the next line properly.
				_alignOffsetX = -floor(string_width_monospace(string_get_line(_string, i + 1), _separation, _currentFont, _ignoreSpecialCharacters) * _xScale / 2);
			}
			_offsetX = 0; // Reset the character offset and push the y offset down to a new line.
			_offsetY += _monospaceHeight;
			continue;
		}
		
		// Display the character at the current character offset and string alignment offset values. Then, add
		// the _separation variable's value to the width OR the character's actual width if ignoring special
		// characters is being applied to the string and it happens to be a special character currently. If
		// that isn't the case, the former option of using the _separation value is applied instead.
		draw_text_transformed_color(_x + _offsetX + _alignOffsetX, _y + _offsetY + _alignOffsetY, _curChar, _xScale, _yScale, _angle, _innerColor, _innerColor, _innerColor, _innerColor, _alpha);
		if (_ignoreSpecialCharacters && is_special_character(_curChar))	{_offsetX += string_width(_curChar) * _xScale;}
		else															{_offsetX += _separation * _xScale;}
	}
	
	// Finally, reset the text alignment to what it prviously was in order to preserve proper text alignment
	// after this function has completed since it temporarily alters the values.
	draw_set_text_align(_curHAlign, _curVAlign);
}

#endregion

#region Sprite rendering functions with extended functionality

/// @description A simple function that automates the process for drawing a sprite that is feathered along 
/// its edges. On top of that, it also automatically sets the current shader to be the feathering one if that
/// shader wasn't already applied prior to this function's use. The two XY pairs determines after what region
/// will the feathering begin on the sprite's texture itself; with its edges being where the alpha is zero.
/// @param sprite
/// @param imageIndex
/// @param xPos
/// @param yPos
/// @param width
/// @param height
/// @param x1
/// @param y1
/// @param x2
/// @param y2
/// @param angle
/// @param color
/// @param alpha
function draw_sprite_feathered(_sprite, _imageIndex, _xPos, _yPos, _width, _height, _x1, _y1, _x2, _y2, _angle, _color, _alpha){
	// Automatically set the target rendering shader to the feathering shader if it wasn't already done
	// prior to this function being called; mainly for convenience purposes and cleaning overall code.
	if (shader_current() != shd_feathering) {shader_set(shd_feathering);}
	
	// First, calculate the true with and height by dividing the values placed in the argument fields by the
	// actual base width and height of the sprite itself; getting how much it needs to be scaled on both axes
	// in order to achieve those desired width and height.
	var _trueWidth, _trueHeight;
	_trueWidth = _width / sprite_get_width(_sprite);
	_trueHeight = _height / sprite_get_height(_sprite);
	
	// Finally, plug the values from the two XY pairs in for the beginning bounds of the fade while also
	// plugging in the position and dimensions of the sprite's image for the ending bounds of the feathering
	// effect. Then, draw the sprite after all that has been finished to apply the effect.
	feathering_set_bounds(_x1, _y1, _x2, _y2, _xPos, _yPos, _xPos + _trueWidth, _yPos + _trueHeight);
	draw_sprite_ext(_sprite, _imageIndex, _xPos, _yPos, _trueWidth, _trueHeight, _angle, _color, _alpha);
}

#endregion