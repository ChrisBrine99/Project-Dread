/// @description A file containing all the code and logic for the game's camera. 

#region	Initializing any macros that are useful/related to obj_camera

// Constants for the game's camera dimensions (Not the actual application window's dimensions) that determine
// the true resolution. There are three valid aspect ratios for the user to choose from, and the values for
// the width and height cooresponding to each are found here.
#macro	WIDTH_SIXTEEN_BY_NINE		320		// 16:9 aspect
#macro	HEIGHT_SIXTEEN_BY_NINE		180
#macro	WIDTH_SIXTEEN_BY_TEN		320		// 16:10 aspect
#macro	HEIGHT_SIXTEEN_BY_TEN		200
#macro	WIDTH_TWENTYONE_BY_NINE		420		// 21:9 aspect (USUSED DUE TO BUG)
#macro	HEIGHT_TWENTYONE_BY_NINE	180
#macro	WIDTH_THREE_BY_TWO			324		// 3:2 aspect
#macro	HEIGHT_THREE_BY_TWO			216

// Constants that shorten the amount of typing needed to retrieve the camera's current width and height, as
// well as the values for half of those respective values which are stored alongside them.
#macro	CAM_WIDTH					global.cameraDimensions.curWidth
#macro	CAM_HEIGHT					global.cameraDimensions.curHeight
#macro	CAM_HALF_WIDTH				global.cameraDimensions.halfWidth
#macro	CAM_HALF_HEIGHT				global.cameraDimensions.halfHeight

// A constant that stores whatever the current aspect ratio is for the camera and game window; minimizing the
// total amount of typing needed to access that value.
#macro	CAM_ASPECT_RATIO			global.cameraDimensions.curAspectRatio

// A constant that stores whatever the current scaling factor is for the window; minimizing the total amount
// of typing that is needed to access that information.
#macro	WINDOW_SCALE				global.cameraDimensions.scale

// Constants that store the key values for each camera function represented in the global.cameraStates
// map. This will prevent any accidental typos when referencing said keys.
#macro	KEY_FOLLOW_OBJECT			"follow_object"
#macro	KEY_TO_POSITION				"to_position"
#macro	KEY_TO_POSITION_SMOOTH		"to_position_smooth"
#macro	KEY_TO_OBJECT				"to_object"
#macro	KEY_TO_OBJECT_SMOOTH		"to_object_smooth"

// Much like above, these constants represent data related to the global.cameraStates map, but instead of
// just being the key value it stores the actual index value given to the method during runtime.
#macro	STATE_FOLLOW_OBJECT			global.cameraStates[? KEY_FOLLOW_OBJECT]
#macro	STATE_TO_POSITION			global.cameraStates[? KEY_TO_POSITION]
#macro	STATE_TO_POSITION_SMOOTH	global.cameraStates[? KEY_TO_POSITION_SMOOTH]
#macro	STATE_TO_OBJECT				global.cameraStates[? KEY_TO_OBJECT]
#macro	STATE_TO_OBJECT_SMOOTH		global.cameraStates[? KEY_TO_OBJECT_SMOOTH]

#endregion

#region Initializing enumerators that are useful/related to obj_camera

/// @description A simple enumerator that stores each of the game's support aspect ratios as an index. In 
/// order they are 16:9 (0), 16:10 (1), 21:9 (2), and 3:2 (3).
enum AspectRatio{
	SixteenByNine,
	SixteenByTen,
	TwentyOneByNine,
	ThreeByTwo,
}

#endregion

#region Initializing any globals that are useful/related to obj_camera

// Stores all the data related to the camera's aspect ratio and current window scaling factor. Also store the
// values for half the width and height for easy reference to those values in other pieces of code.
global.cameraDimensions = {
	// By default, the game will run at a 16:9 aspect ratio with a window scaling factor of 4
	curWidth :			WIDTH_SIXTEEN_BY_NINE,
	curHeight :			HEIGHT_SIXTEEN_BY_NINE,
	scale :				4,
	
	// Stores the current aspect ratio for the camera in the struct itself. This allows there to be an easy
	// reference to whatever the current aspect ratio is from anywhere in the code.
	curAspectRatio :	AspectRatio.SixteenByNine,
	
	// Store the values for half the width and half the height of the current camera dimensions
	halfWidth :			(WIDTH_SIXTEEN_BY_NINE / 2),
	halfHeight :		(HEIGHT_SIXTEEN_BY_NINE / 2),
};

// A map that stores index references to all functions within obj_camera that are public in nature; being able 
// to be referenced outside of the object for the purpose of changing the camera's current logic function.
global.cameraStates = ds_map_create();

#endregion

#region	The main object code for obj_camera

function obj_camera() constructor{
	// Much like Game Maker's own x and y variables, these store the current position of the camera within 
	// the current room. By default they are always set to a value of zero.
	x = 0;
	y = 0;
	
	// Much like Game Maker's own object_index variable, this will store the unique ID value provided to this
	// object by Game Maker during runtime; in order to easily use it within a singleton system.
	object_index = obj_camera;
	
	// This pair of variables store the fractional values for the camera's movement on both the x-axis and
	// y-axis, respectively. When a whole number can be parsed from either of the values, they will be added
	// to the camera's current position.
	hspdFraction = 0;
	vspdFraction = 0;
	
	// A flag that toggles whether or not the camera can show the player the outside of a given room. Useful
	// for when the current room is an interior area, which uses the unlocked camrea, or the room is an 
	// exterior area, which uses the locked camera.
	lockViewBounds = false;
	
	// Two variables that determine what function is handling camera logic at the moment. It can be anything
	// from moving the camera to a set position in the room, following an object around, moving towards an
	// object, and so on. The second of the two variables is an array containing all the required arguments
	// for the function stored in the first variable.
	camState = NO_STATE;
	camStateArgs = -1;
	
	// Variables that are responsible for managing the camera's optional shaking effect that can be temporarily
	// applied to the viewport. The first two variables store the origin point of the shake at the given
	// moment; otherwise the shake will swing the camera all over the place. Next, the set strength and
	// current strength store how strong the shake began at and what it currently is in real time. Finally,
	// the last variable is simply the duration in "physics" frame (60 = 1 second) that the shake should
	// last for before ending.
	shakeOriginX = 0;
	shakeOriginY = 0;
	shakeSetStrength = 0;
	shakeCurStrength = 0;
	shakeDuration = 0;
	
	// Creating the camera and placing its unique ID into a variable. After the initialization, use the
	// returned ID to alter the size of the camera's view into the game world to the desired size and
	// also make sure the position in the room is set as well.
	cameraID = camera_create();
	camera_set_view_size(cameraID, CAM_WIDTH, CAM_HEIGHT);
	camera_set_view_pos(cameraID, 0, 0);
	
	// Update the dimensions of the game window itself to reflect the camera's viewport dimensions, but
	// magnified to the desired scale that was set upon obj_camera's creation.
	window_update_dimensions(CAM_WIDTH * WINDOW_SCALE, CAM_HEIGHT * WINDOW_SCALE);
	
	// Finally, set the size of the game's default application surface to match the dimensions of the
	// camera's viewport and window. Also, set the gui size to reflect those dimensions as well.
	surface_resize(application_surface, CAM_WIDTH, CAM_HEIGHT);
	display_set_gui_size(CAM_WIDTH, CAM_HEIGHT);
	
	/// @description Code that should be placed into the "End Step" event of whatever object is controlling
	/// obj_camera. In short, it is ran every frame and checks to see if there is a valid movement function
	/// attached to the camera. If there is one, it will execute it; letting said function handle all the
	/// logic based on what it is designed to do.
	end_step = function(){
		if (camState != NO_STATE) {script_execute_ext(camState, camStateArgs);}
		
		// Apply the shake effect to the camera's position based on its current strength relative to its
		// starting strength and the duration of the shake in real seconds. (1 = second = 60 in the code)
		// The duration determines how fast the strength of the shake will decrease.
		if (shakeCurStrength > 0){
			shakeCurStrength -= shakeSetStrength / shakeDuration * global.deltaTime;
			camera_set_view_pos(cameraID, shakeOriginX + irandom_range(-shakeCurStrength, shakeCurStrength), shakeOriginY + irandom_range(-shakeCurStrength, shakeCurStrength));
		}
	}
	
	/// @description Code that should be placed into the "Room Start" event of whatever object is controlling
	/// obj_camera. In short, it simply enables the viewport for the new room and sets said view to be visible 
	/// AND attaches the camera's camera to it by providing its ID.
	room_start = function(){
		view_enabled = true;
		view_set_camera(0, cameraID);
		view_set_visible(0, true);
	}
	
	/// @description Code that should be placed into the "Cleanup" event of whatever object is controlling
	/// obj_camera. In short, it will cleanup any data that needs to be freed from memory that isn't collected
	/// by Game Maker's built-in garbage collection handler.
	cleanup = function(){
		// Remove the camera dimension struct from memory and also remove the list for the publicly 
		// accesible camera functions.
		delete global.cameraDimensions;
		ds_map_destroy(global.cameraStates);
		
		// Delete the camera from memory and remove its unique ID value.
		camera_destroy(cameraID);
		cameraID = undefined;
	}
	
	/// @description Updates the camera's position based on how many pixels it's been set to move for the
	/// given "frame" of game physics' speed. (60 = 1 second of real-time) On top of that, it prevents the
	/// camera's position from being a non-integer value, which would cause the pixels to be rendered in
	/// odd offset shapes.
	/// @param hspd
	/// @param vspd
	update_position = function(_hspd, _vspd){
		// First things first, the delta movement amount for the frame must be calculated.
		var _hspdDelta, _vspdDelta;
		_hspdDelta = _hspd * global.deltaTime;
		_vspdDelta = _vspd * global.deltaTime;
		
		// After that, the previous fraction values need to be added back into the movement values.
		_hspdDelta += hspdFraction;
		_vspdDelta += vspdFraction;
		
		// Once the previous fraction values have been added back in, they need to be removed along with any
		// of the other fractional values that exists in both delta variables upon the initial calculation. 
		hspdFraction = _hspdDelta - (floor(abs(_hspdDelta)) * sign(_hspdDelta));
		vspdFraction = _vspdDelta - (floor(abs(_vspdDelta)) * sign(_vspdDelta));
		
		// Finally, the new fractional values are removed from the delta values to turn it into a true integer
		// value for the required movement speed in both the x and y axis.
		_hspdDelta -= hspdFraction;
		_vspdDelta -= vspdFraction;
		
		// One additional step: if the room's boundaries are currently set to be the camera's viewport bounds
		// as well--make sure this is true by clamping whatever the x and y values plus their delta values
		// would be to the room's valid range of possible camera coordinates.
		if (lockViewBounds){
			x = clamp(x + _hspdDelta, 0, room_width - CAM_WIDTH);
			y = clamp(y + _vspdDelta, 0, room_width - CAM_HEIGHT);
		} else{
			x += _hspdDelta;
			y += _vspdDelta;
		}
		
		// After everything has been calculated, update the origin point of the camera's shaking calculations
		// and update the viewport to be at those same previously calculated x and y positions.
		camera_set_view_pos(cameraID, x, y);
		shakeOriginX = x;
		shakeOriginY = y;
	}
	
	/// @description A movement function for the camera that centers itself on a given object; that object
	/// being a unique ID provided within the _objectID argument space. The camera will remain stationary
	/// whilst the object is within a defined "deadzone" and will only begin moving with the object when it
	/// reaches the bounds of said deadzone.
	/// @param objectID
	/// @param deadzoneSize
	move_follow_object = function(_objectID, _deadzoneSize){
		// First, the target position needs to be acquired, which will then be checked against the camera's
		// current coordinates to see if movement needs to occur. If there is no valid object for the given
		// ID value, the target variables will remain undefined. This will prevent the function from performing
		// any of its positioning calculations.
		var _targetX, _targetY;
		with(_objectID){
			_targetX = x;
			_targetY = y;
		}
		
		// Only one of the variables needs to be checked for "undefined" status because they're both set to
		// an object's respective coordinates if it exists, and both are undefined otherwise.
		if (is_undefined(_targetX)) {return;}
		
		// First, create two variables that store the camera's position within the room, but offset it by half
		// the width and height in order to center to coordinate within the camera. This will then be used in
		// tandem with the _deadzoneSize variable in order to see if movement should occur.
		var _cameraX, _cameraY;
		_cameraX = x + CAM_HALF_WIDTH;
		_cameraY = y + CAM_HALF_HEIGHT;
		
		// Checking for horizontal movement; clamping the player to the edge of the deadzone for that 
		// respective direction until they cease moving in said direction.
		if (_targetX >= _cameraX + _deadzoneSize)		{_cameraX = _targetX - _deadzoneSize;}
		else if (_targetX <= _cameraX - _deadzoneSize)	{_cameraX = _targetX + _deadzoneSize;}
		
		// Check for vertical movement as well; clamping the player the same as it would for the x-axis.
		if (_targetY >= _cameraY + _deadzoneSize)		{_cameraY = _targetY - _deadzoneSize;}
		else if (_targetY <= _cameraY - _deadzoneSize)	{_cameraY = _targetY + _deadzoneSize;}
		
		// Next, set the coordinates for the camera to be equal to the _cameraX and _cameraY values, but
		// with their offsets removed since no more calculations will occur. 
		x = _cameraX - CAM_HALF_WIDTH;
		y = _cameraY - CAM_HALF_HEIGHT;
		shakeOriginX = x;	// Don't forget to store the shake origin for an accurate shake effect!
		shakeOriginY = y;
		
		// Finally, lock the position of the camera to within the valid bounds of the current room given its
		// dimensions. This will prevent the edges of the room from being bypassed by the view. After that has
		// been checked and corrected, the camera's view position is updated for the frame.
		if (lockViewBounds){
			x = clamp(x, 0, room_width - CAM_WIDTH);
			y = clamp(y, 0, room_height - CAM_HEIGHT);
		}
		camera_set_view_pos(cameraID, x, y);
	}
	
	/// @description A simple function that moves the camera to the provided position within the current room.
	/// If the view bounaries are locked, the target position will be locked within the valid range of values
	/// should the X of Y targets exceed said ranges.
	/// @param targetX
	/// @param targetY
	/// @param moveSpeed
	move_to_position = function(_targetX, _targetY, _moveSpeed){
		// If the camera is set to lock its bounds within the valid values for the current room make sure 
		// that the target values are clamped to said ranges for the X and Y axis, respectively.
		if (lockViewBounds){
			_targetX = clamp(_targetX, 0, room_width - CAM_WIDTH);
			_targetY = clamp(_targetY, 0, room_height - CAM_HEIGHT);
		}
		
		// If the camera has reached its position OR it's about to reach its position, prevent the camera 
		// from moving anymore and simply set its position to the target values before exiting the function
		// early.
		if ((x == _targetX && y == _targetY) || point_distance(x, y, _targetX, _targetY) < _moveSpeed){
			x = _targetX;
			y = _targetY;
			camera_set_view_pos(cameraID, x, y);
			return;
		}
		
		// Grab the direction that the camera should linearly approach the target by and apply some trig to
		// ensure both target values are hit at the same time. Otherwise, they'd need to be the same distance
		// on both axes in order for both targets to be reached at the same time.
		var _direction = point_direction(x, y, _targetX, _targetY);
		update_position(lengthdir_x(_moveSpeed, _direction), lengthdir_y(_moveSpeed, _direction));
	}
	
	/// @description A simple function that moves the camera much like the function above, but it moves with
	/// a relative speed instead of a linear speed. This means that as the camera approaches its target, the
	/// speed that it moves per-physics frame will be slower and slower.
	/// @param targetX
	/// @param targetY
	/// @param moveSpeed
	move_to_position_smooth = function(_targetX, _targetY, _moveSpeed){
		// This chunk of code operates the exact same way that it does in the function "camera_move_to_position"
		if (lockViewBounds){
			_targetX = clamp(_targetX, 0, room_width - CAM_WIDTH);
			_targetY = clamp(_targetY, 0, room_height - CAM_HEIGHT);
		}
		
		// The logic behind this code is identical to its sister function "camera_move_to_position" when it
		// comes to checking if the target is reached-aside from a what the point_distance check does. In this
		// function it checks based on the current difference of the camera's position and its target and if
		// that is less than its movement speed for that physics frame.
		if ((x == _targetX && y == _targetY) || point_distance(0, 0, _targetX - x, _targetY - y) < _moveSpeed){
			x = _targetX;
			y = _targetY;
			camera_set_view_pos(cameraID, x, y);
			return;
		}
		
		// Update the position of the camera based on where it currently is relative to the target values;
		// with those values multiplied by the speed the camera should move on top of that current difference.
		update_position((_targetX - x) * _moveSpeed, (_targetY - y) * _moveSpeed);
	}
	
	/// @description A simple function that works identically to how "camera_move_to_position" works, but
	/// instead of a set position within the arguments it's the position of the target object, which can 
	/// change on a per-frame basis in some cases. So, it will constantly update that target position until
	/// the camera reaches the target values, and then the function is by whatever it found in the final
	/// two argument spaces.
	/// @param objectID
	/// @param moveSpeed
	/// @param nextFunction
	/// @param nextFunctionArgs
	move_to_object = function(_objectID, _moveSpeed, _nextFunction = NO_STATE, _nextFunctionArgs = -1){
		// First, get the position of the target, but default the values to the cmaera's x and y position in
		// the event of an invalid object ID being supplied. Otherwise, those failsafe values are overwritten
		// by the object's position in the room, and the camera is moved to that position.
		var _targetX, _targetY;
		_targetX = x;
		_targetY = y;
		with(_objectID){
			_targetX = x - CAM_HALF_WIDTH;
			_targetY = y - CAM_HALF_HEIGHT;
		}
		
		// Since this works identically to the "camera_move_to_position" function, take the target position
		// values set above and plug them into that function itself. After that, a check to see if the target
		// has been hit which will then overwrite the camera's current state with the new data.
		move_to_position(_targetX, _targetY, _moveSpeed);
		if (x == _targetX && y == _targetY){
			camState = _nextFunction;
			camStateArgs = _nextFunctionArgs;
		}
	}
	
	/// @description This function is the same as the "camera_move_to_object" in the case of how it functions
	/// relative to another movement function for the camera, but it's for the *_smooth variations on that
	/// base movement function. Like above, it will constantly update the target position to whatever the
	/// followed object's position on a given frame; only this time it will be smooth camera movement instead
	/// of a linear camera movement like the non-smooth counterparts.
	/// @param objectID
	/// @param moveSpeed
	/// @param nextFunction
	/// @param nextFunctionArgs
	move_to_object_smooth = function(_objectID, _moveSpeed, _nextFunction = NO_STATE, _nextFunctionArgs = -1){
		// This chunk of code works the exact same way as it does in the non-smooth variation of this camera
		// state; taking the target variables and applying the followed object's coordinates only if it's a
		// valid instance--otherwise, use the camera's coordinates instead.
		var _targetX, _targetY;
		_targetX = x;
		_targetY = y;
		with(_objectID){
			_targetX = x - CAM_HALF_WIDTH;
			_targetY = y - CAM_HALF_HEIGHT;
		}
		
		// Call the default smooth movement position function to handle the movement and camera locking
		// logic from there. After that, check if the target position has been reached, and if so, end
		// the movement function and set the target camera state to the respective argument value.
		move_to_position_smooth(_targetX, _targetY, _moveSpeed);
		if (x == _targetX && y == _targetY){
			camState = _nextFunction;
			camStateArgs = _nextFunctionArgs;
		}
	}
	
	// Add all of the function indexes for the ones that should be allowed to be referenced outside of the
	// obj_camera object to its public function map. In short, this allows these functions to be referenced 
	// in order to change how the camera's movement logic is currently working anywhere in the code.
	ds_map_add(global.cameraStates, KEY_FOLLOW_OBJECT,		move_follow_object);
	ds_map_add(global.cameraStates, KEY_TO_POSITION,		move_to_position);
	ds_map_add(global.cameraStates, KEY_TO_POSITION_SMOOTH,	move_to_position_smooth);
	ds_map_add(global.cameraStates, KEY_TO_OBJECT,			move_to_object);
	ds_map_add(global.cameraStates, KEY_TO_OBJECT_SMOOTH,	move_to_object_smooth);
}

#endregion

#region Global functions related to obj_camera

/// @description Sets the camera's aspect ratio to one of the three possible ratios: 16:9, 16:10, and 21:9.
/// After updating the width and height of the camera's viewport, the window is adjust to match as well.
/// @param aspectRatio
function camera_set_aspect_ratio(_aspectRatio){
	// First, jump into the camera dimensions struct in order to update the variables from within; changing
	// them all to reflect the new aspect ratio if the one in the argument field is in face a new ratio.
	with(global.cameraDimensions){
		// If there supplied aspect ratio is identical to the current aspect ratio; don't change anything.
		if (_aspectRatio == curAspectRatio) {return;}
		
		// Set the aspect ratio variable within the struct to the new aspect ratio.
		curAspectRatio = _aspectRatio;
		if (curAspectRatio == AspectRatio.TwentyOneByNine) {curAspectRatio = AspectRatio.ThreeByTwo;}
		
		// Search through the switch statement below and adjust the camera's width and height values to
		// reflect the new aspect ratio. Then, update the dimension's of the camera viewport to reflect
		// those new changes--along with the application surface and GUI dimensions.
		switch(curAspectRatio){
			case AspectRatio.SixteenByNine:
				curWidth =		WIDTH_SIXTEEN_BY_NINE;
				curHeight =		HEIGHT_SIXTEEN_BY_NINE;
				break;
			case AspectRatio.SixteenByTen:
				curWidth =		WIDTH_SIXTEEN_BY_TEN;
				curHeight =		HEIGHT_SIXTEEN_BY_TEN;
				break;
			case AspectRatio.TwentyOneByNine: // Unused due to a bug
				curWidth =		WIDTH_TWENTYONE_BY_NINE;
				curHeight =		HEIGHT_TWENTYONE_BY_NINE;
				break;
			case AspectRatio.ThreeByTwo:
				curWidth =		WIDTH_THREE_BY_TWO;
				curHeight =		HEIGHT_THREE_BY_TWO;
				break;
		}
		camera_set_view_size(CAMERA.cameraID, curWidth, curHeight);
		surface_resize(application_surface, curWidth, curHeight);
		display_set_gui_size(curWidth, curHeight);
		
		// Update the stored half width and height values before calculating the new aspect ratio's half 
		// width and half height values. The stored previous values will be used further down in the function 
		// to determine the offset that camera needs to move by to remained centered on what it's current 
		// viewing.
		var _prevHalfWidth, _prevHalfHeight;
		_prevHalfWidth = halfWidth;
		_prevHalfHeight = halfHeight;
		halfWidth = (curWidth / 2);
		halfHeight = (curHeight / 2);
		
		// Offset the position of the camera so that it remains centered on its view despite the new aspect
		// ratio. After that, update the dimensions of the window viewport to reflect the new aspect ratio.
		camera_set_position(CAMERA.x - (halfWidth - _prevHalfWidth), CAMERA.y - (halfHeight - _prevHalfHeight));
		window_update_dimensions(curWidth * scale, curHeight * scale);
	}
	
	// 
	with(EFFECT_HANDLER){
		windowTexelWidth = 1 / CAM_WIDTH;
		windowTexelHeight = 1 / CAM_HEIGHT;
	}
	
	// Update the position of the textbox on the screen so that it remains centered. Otherwise, it'd be offset
	// to the right side of the screen if the aspect ratio went from 16:9 or 16:10 to 21:9, or be offset to
	// the left side of the screen if the change was the other way around.
	with(TEXTBOX_HANDLER){
		x = CAM_HALF_WIDTH - (textboxWidth / 2);
		y = TEXTBOX_TARGET_Y;
	}
	
	// Re-calculate the position of the right-aligned control information, since it will not be anchored to
	// that edge of the screen if the aspect ratio goes from 16x9 to 21x9, or vice versa.
	with(CONTROL_INFO) {calculate_control_display_positions(ALIGNMENT_RIGHT);}
}

/// @description A simple function that will instantly snap the camera to a new position; based on a few
/// factors and exceptions. If the view bounds are locked to the room's boundaries, the values will be clamped
/// as such to handle that. Otherwise, any value is possible, but any decimal values are dropped from them.
/// @param x
/// @param y
function camera_set_position(_x, _y){
	with(CAMERA){
		if (lockViewBounds){ // Clamp the x and y to remain within the room's dimensions.
			x = clamp(floor(_x), 0, room_width - CAM_WIDTH);
			y = clamp(floor(_y), 0, room_height - CAM_HEIGHT);
		} else{ // The room's dimensions don't matter; set the positions with no changes.
			x = floor(_x);
			y = floor(_y);
		}
		camera_set_view_pos(cameraID, x, y);
	}
}

/// @description A simple function that applies a shake to the camera for a set duration. In order for the
/// supplied argument to overwrite the current shake effect, the strength must be greater in intensity.
/// Otherwise, the function will simply do nothing.
/// @param shakeStrength
/// @param duration
function camera_set_shake(_shakeStrength, _duration){
	with(CAMERA){
		if (_shakeStrength >= shakeCurStrength){
			shakeSetStrength = _shakeStrength;
			shakeCurStrength = _shakeStrength;
			shakeDuration = _duration;
		}
	}
}

/// @description A simple function that overwrites the camera's current logic function and its arguments with
/// new data that is provided in the argument fields. The function is run in the "camera_end_step" function
/// which is processed on every available in-game frame.
/// @param state
/// @param arguments[]
function camera_set_state(_state, _arguments){
	with(CAMERA){
		camState = method_get_index(_state);
		camStateArgs = _arguments;
	}
}

/// @description A simple function that updates the dimensions of the current window to match the current
/// camera dimensions with a given scale applied to the values (Shown as "_width" and "_height" in the
/// argument fields. It also keeps the window centered on the display it's being rendered on.
/// @param width
/// @param height
function window_update_dimensions(_width, _height){
	// First, determine the maximum possible scaling that the window can achieve before either the width OR
	// the height surpasses the resolution of the current display. That value will then be used to clamp the
	// provided dimensions to a valid range.
	var _maxScale = min(floor(display_get_width() / CAM_WIDTH), floor(display_get_height() / CAM_HEIGHT));
	_width = clamp(_width, CAM_WIDTH, CAM_WIDTH * _maxScale);
	_height = clamp(_height, CAM_HEIGHT, CAM_HEIGHT * _maxScale);
	
	// Then, the offset of the window based on its width and height from the center of the display is calculated
	// in order to keep the window centered on said display. Otherwise, updating the dimensions will cause it
	// to expand to the right and downward.
	var _xOffset, _yOffset;
	_xOffset = floor((display_get_width() - _width) / 2);
	_yOffset = floor((display_get_height() - _height) / 2);
	
	// Finally, set the size of the window to the final width and height values and the position to the offset
	// so it remains in the center of the screen.
	window_set_size(_width, _height);
	window_set_position(_xOffset, _yOffset);
}

#endregion