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
	
	// 
	cameraID = camera_create();
	
	// 
	curWidth = 0;
	curHeight = 0;
	halfWidth = 0;
	halfHeight = 0;
	
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
	camStateArgs = array_create(0);
	
	// 
	shakeData = {
		originX :		0,
		originY :		0,
		initialPower :	0,
		curPower :		0,
		duration :		0,
	};
	
	/// @description Code that should be placed into the "End Step" event of whatever object is controlling
	/// obj_camera. In short, it handles executing the current movement state and the camera's shake effect 
	/// that can occur for it if said effect happens to be currently active.
	end_step = function(){
		if (camState != NO_STATE) {script_execute_ext(camState, camStateArgs);}
		
		// Update the shake effect by slowly lowering its intensity until it reaches or goes below a value
		// of zero. The shake is based on an "origin" position instead of the camera's actual position in
		// order to allow the object's position within the deadzone to remain relatively consistent both 
		// before and after the shake effect occurs.
		with(shakeData){
			if (curPower > 0){
				curPower -= initialPower / duration * DELTA_TIME;
				other.x = originX + irandom_range(-curPower, curPower);
				other.y = originY + irandom_range(-curPower, curPower);
			}
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
		ds_map_destroy(global.cameraStates);
		camera_destroy(cameraID);
		cameraID = undefined;
	}
	
	/// @description 
	/// @param {Real}	x
	/// @param {Real}	y
	/// @param {Real}	width
	/// @param {Real}	height
	/// @param {Real}	scale
	camera_initialize = function(_x, _y, _width, _height, _scale){
		// 
		x = _x;
		y = _y;
		curWidth = _width;
		curHeight = _height;
		halfWidth = (_width / 2);
		halfHeight = (_height / 2);
		
		// 
		camera_set_view_size(cameraID, _width, _height);
		camera_set_view_pos(cameraID, _x, _y);
		
		// 
		surface_resize(application_surface, _width, _height);
		display_set_gui_size(_width, _height);
		
		// 
		window_initialize(_width * _scale, _height * _scale);
		
		// 
		with(EFFECT_HANDLER){
			windowTexelWidth = 1 / _width;
			windowTexelHeight = 1 / _height;
		}
	}
	
	/// @description 
	/// @param {Real}	width
	/// @param {Real}	height
	window_initialize = function(_width, _height){
		var _maxScale = floor(min(display_get_width() / curWidth, display_get_height() / curHeight));
		window_set_size(clamp(_width, curWidth, curWidth * _maxScale), clamp(_height, curHeight, curHeight * _maxScale));
		window_set_position(floor((display_get_width() - _width) / 2),  floor((display_get_height() - _height) / 2));
	}
	
	/// @description Updates the camera's position based on how many pixels it's been set to move for the
	/// given "frame" of game physics' speed. (60 = 1 second of real-time) On top of that, it prevents the
	/// camera's position from being a non-integer value, which would cause the pixels to be rendered in
	/// odd offset shapes.
	/// @param {Real}	hspd
	/// @param {Real}	vspd
	update_position = function(_hspd, _vspd){
		// First things first, the delta movement amount for the frame must be calculated.
		var _hspdDelta, _vspdDelta;
		_hspdDelta = _hspd * DELTA_TIME;
		_vspdDelta = _vspd * DELTA_TIME;
		
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
		shakeData.originX = x;
		shakeData.originY = y;
	}
	
	/// @description A movement function for the camera that centers itself on a given object; that object
	/// being a unique ID provided within the _objectID argument space. The camera will remain stationary
	/// whilst the object is within a defined "deadzone" and will only begin moving with the object when it
	/// reaches the bounds of said deadzone.
	/// @param {Id.Instance}	objectID
	/// @param {Real}			deadzoneSize
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
		var _cameraX = x + CAM_HALF_WIDTH;
		var _cameraY = y + CAM_HALF_HEIGHT;
		
		// Checking for horizontal movement; clamping the player to the edge of the deadzone for that 
		// respective direction until they cease moving in said direction.
		if (_targetX >= _cameraX + _deadzoneSize)		{_cameraX = _targetX - _deadzoneSize;}
		else if (_targetX <= _cameraX - _deadzoneSize)	{_cameraX = _targetX + _deadzoneSize;}
		
		// Check for vertical movement as well; clamping the player the same as it would for the x-axis.
		if (_targetY >= _cameraY + _deadzoneSize)		{_cameraY = _targetY - _deadzoneSize;}
		else if (_targetY <= _cameraY - _deadzoneSize)	{_cameraY = _targetY + _deadzoneSize;}
		
		// Update the position of the camera to whatever its new position SHOULD be after checking if the
		// object it is currently following has surpassed the deadzone range in the camera's center. After,
		// make sure the camera doesn't exceed its bounds if the view is locked to only show the room's
		// area. Finally, update the camera's view position and shake effect's new origin position.
		x = _cameraX - CAM_HALF_WIDTH;
		y = _cameraY - CAM_HALF_HEIGHT;
		if (lockViewBounds){
			x = clamp(x, 0, room_width - CAM_WIDTH);
			y = clamp(y, 0, room_height - CAM_HEIGHT);
		}
		camera_set_view_pos(cameraID, x, y);
		shakeData.originX = x;
		shakeData.originY = y;
	}
	
	/// @description A simple function that moves the camera to the provided position within the current room.
	/// If the view bounaries are locked, the target position will be locked within the valid range of values
	/// should the X of Y targets exceed said ranges.
	/// @param {Real}	targetX
	/// @param {Real}	targetY
	/// @param {Real}	moveSpeed
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
	/// @param {Real}	targetX
	/// @param {Real}	targetY
	/// @param {Real}	moveSpeed
	move_to_position_smooth = function(_targetX, _targetY, _moveSpeed){
		// This chunk of code operates the exact same way that it does in the function "camera_move_to_position".
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
		update_position((_targetX - x) * _moveSpeed, (_targetY -  y) * _moveSpeed);
	}
	
	/// @description A simple function that works identically to how "camera_move_to_position" works, but
	/// instead of a set position within the arguments it's the position of the target object, which can 
	/// change on a per-frame basis in some cases. So, it will constantly update that target position until
	/// the camera reaches the target values, and then the function is by whatever it found in the final
	/// two argument spaces.
	/// @param {Id.Instance}	objectID
	/// @param {Real}			moveSpeed
	/// @param {Real}			nextFunction
	/// @param {Array<Any>}		nextFunctionArgs
	move_to_object = function(_objectID, _moveSpeed, _nextState = NO_STATE, _nextStateArgs = array_create(0)){
		// First, get the position of the target, but default the values to the cmaera's x and y position in
		// the event of an invalid object ID being supplied. Otherwise, those failsafe values are overwritten
		// by the object's position in the room, and the camera is moved to that position.
		var _targetX = x;
		var _targetY = y;
		with(_objectID){
			_targetX = x - CAM_HALF_WIDTH;
			_targetY = y - CAM_HALF_HEIGHT;
		}
		
		// Since this works identically to the "camera_move_to_position" function, take the target position
		// values set above and plug them into that function itself. After that, a check to see if the target
		// has been hit which will then overwrite the camera's current state with the new data.
		move_to_position(_targetX, _targetY, _moveSpeed);
		if (x == _targetX && y == _targetY){
			camState = _nextState;
			camStateArgs = _nextStateArgs;
		}
	}
	
	/// @description This function is the same as the "camera_move_to_object" in the case of how it functions
	/// relative to another movement function for the camera, but it's for the *_smooth variations on that
	/// base movement function. Like above, it will constantly update the target position to whatever the
	/// followed object's position on a given frame; only this time it will be smooth camera movement instead
	/// of a linear camera movement like the non-smooth counterparts.
	/// @param {Id.Instance}	objectID
	/// @param {Real}			moveSpeed
	/// @param {Real}			nextFunction
	/// @param {Array<Any>}		nextFunctionArgs
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
/// @param {Enum.AspectRatio}	aspectRatio
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
		var _prevHalfWidth = halfWidth;
		var _prevHalfHeight = halfHeight;
		halfWidth = (curWidth / 2);
		halfHeight = (curHeight / 2);
		
		// Offset the position of the camera so that it remains centered on its view despite the new aspect
		// ratio. After that, update the dimensions of the window viewport to reflect the new aspect ratio.
		camera_set_position(CAMERA.x - (halfWidth - _prevHalfWidth), CAMERA.y - (halfHeight - _prevHalfHeight));
		window_update_dimensions(curWidth * scale, curHeight * scale);
	}
	
	// Make sure to update the values for the texel width and height of the window to match the newly set
	// aspect ratio's resolution values. Otherwise, certain post-processing effects won't work properly.
	with(EFFECT_HANDLER){
		windowTexelWidth = 1 / CAM_WIDTH;
		windowTexelHeight = 1 / CAM_HEIGHT;
	}
	
	// Update the position of the textbox on the screen so that it remains centered. Otherwise, it'd be offset
	// to the right side of the screen if the aspect ratio went from 16:9 or 16:10 to 21:9, or be offset to
	// the left side of the screen if the change was the other way around.
	with(TEXTBOX_HANDLER){
		x = CAM_HALF_WIDTH - (TEXTBOX_WIDTH / 2);
		y = TEXTBOX_TARGET_Y;
	}
	
	// Re-calculate the position of the right-aligned control information, since it will not be anchored to
	// that edge of the screen if the aspect ratio goes from 16x9 to 3x2, or vice versa.
	with(CONTROL_INFO) {calculate_control_display_positions(ALIGNMENT_RIGHT);}
}

/// @description A simple function that will instantly snap the camera to a new position; based on a few
/// factors and exceptions. If the view bounds are locked to the room's boundaries, the values will be clamped
/// as such to handle that. Otherwise, any value is possible, but any decimal values are dropped from them.
/// @param {Real}	x
/// @param {Real}	y
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
/// @param {Real}	power
/// @param {Real}	duration
function camera_set_shake(_power, _duration){
	with(CAMERA.shakeData){
		if (_initalPower >= curPower){
			initialPower = _initalPower;
			curPower = _initalPower;
			duration = _duration;
		}
	}
}

/// @description A simple function that overwrites the camera's current logic function and its arguments with
/// new data that is provided in the argument fields. The function is run in the "camera_end_step" function
/// which is processed on every available in-game frame.
/// @param {Function}	state
/// @param {Array}		arguments[]
function camera_set_state(_state, _arguments){
	with(CAMERA){
		if (_state != NO_STATE) {camState = method_get_index(_state);}
		else					{camState = NO_STATE;}
		camStateArgs = _arguments;
	}
}

/// @description 
function camera_get_width()			{return CAMERA.curWidth;}
function camera_get_height()		{return CAMERA.curHeight;}

#endregion