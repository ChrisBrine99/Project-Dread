#region Macros utilized by Dynamic Entities and its Children

// Macro values that are used within all entity objects when it comes to animation. The first is the difference
// in angle between the "directions" available for the sprite, (Right, up, left, and down, respectively) and
// the second macro simply refers to the timing used for the animations, which is independent of the game's
// true frame rate.
#macro	SPRITE_ANGLE_DELTA		90
#macro	ANIMATION_FPS			60

// Macro values for all of the different floor materials within the game. If required, the entity can play
// a unique sound effect for each of these different types of flooring.
#macro	FLOOR_MATERIAL_NONE		0
#macro	FLOOR_MATERIAL_WOOD		1
#macro	FLOOR_MATERIAL_TILE		2
#macro	FLOOR_MATERIAL_GRAVEL	3
#macro	FLOOR_MATERIAL_GRASS	4
#macro	FLOOR_MATERIAL_WATER	5
#macro	FLOOR_MATERIAL_MUD		6
#macro	FLOOR_MATERIAL_SNOW		7

#endregion

#region Editing default variables, initializing unique variables, and other important initializations

// Edit some of the object's default variables before any initialization of unique variables occurs.
direction = 0;
image_speed = 0;
image_index = 0;
visible = false;

// Stores pointers to the components that have been created by a given entity. Each of these components are a
// struct in order to lower the overhead of using standard objects for these optional functionalities for a
// given entity.
audioComponent = noone;
lightComponent = noone;
interactComponent = noone;

// 
audioOffsetX = 0;
audioOffsetY = 0;

// Variables that allow the light component's position to be offset by some amount relative to the entity's
// current position. This allows for things like having the player's flashlight to be placed on the sprite's
// chest rather than her feet, which is where he actual position is located.
lightOffsetX = 0;
lightOffsetY = 0;

// The state variables that allow the entity to properly swap states at the END of a given frame, while also
// storing whatever their last state was in case it needs to be referenced elsewhere in the code. The curState
// and "nextState" values are equal whenever a state switch occurs, and don't equal when a state change occurs
// since that won't take place until the end of the current frame.
curState = NO_STATE;
lastState = NO_STATE;
nextState = NO_STATE;

// Animation variables that isolate the animation logic from the game's true frame rate; allow it to function
// based off of its own "frames per second" that is stored in one of the macro values above. The animation
// speed is basically how fast it will animate relative to the sprite's animation speed that is set in the 
// editor itself. 
imageIndex = 0;
animSpeed = 0;

// These variables will grab and store information about the entity's current sprite that it is using. The
// animation speed is an editor setting that determines how many frames it should play in a given second;
// independent of the current frame rate. Meanwhile, the second is the length of the sprite in images.
spriteAnimSpeed = 0;
spriteLength = 0;

// Since each sprite in the game stores all the possible directions for that given animation, the current
// facing direction's loop start and length need to be found and stored within these variables for the
// animations to function properly.
loopOffset = 0;
loopLength = 0;

// A flag that allows entities to have their rendering toggled on and off at any given moment. Useful for objects
// that are classified as entities, but shouldn't be rendered for the player to see. (Ex. Door warp objects)
displaySprite = true;

// Variables for the fake 3D that the game contains. In short, it allows entities to be above and below each
// other relative to their "Z Height", which is how tall their collision box is on this fake Z-axis.
z = 0;
zHeight = 0;

// The current horizontal velocity and vertical velocity for the entity; excluding any delta timing that will
// cut or increase these values to make sure that every 1/60th of a second these values will be how far the
// entity has moved independent of however many frames there actually were in that time.
hspd = 0;
vspd = 0;

// Stores the maximum possible horiztonal and vertical movement speeds, respectively. When it comes to the vertical
// velocity, it usually only determines the maximum falling speed, but not the entity's upward momentum--which
// doesn't actually have a limit to it.
maxHspd = 0;
maxVspd = 0;

// Determines the factor for the real-time maximum movement speeds relative to the set maximum values stored
// within the pair of variables above. If the values go below 1, the maximum possible hspd at that given time
// will be LOWER than the stored values. Otherwise, the max values will be the same or ABOVE the maximunm speeds.
maxHspdFactor = 1;
maxVspdFactor = 1;

// Determines the acceleration of the entity on both the x and y axis. For most entities in this game, the hAccel
// will be there "movement" acceleration, while the second variable will be their gravity; pulling them downward
// at that speed increasing their velocity per second until they are no longer airbourne.
hAccel = 0;
vAccel = 0;

// In order for entities to move with integer values while also using delta timing to unlock the game's frame
// rate, there needs to be a pair of variables that store the fractional movement values until they can have
// whole numbers parsed from them to actually process an entity's movement. These variables will store those
// decimal hspd and vspd values.
hspdFraction = 0;
vspdFraction = 0;

// These three variables will handle the entity's hitpoints, which is a value that represents how much damage
// they can take before being defeated. However, if the entity is flagged as invincible they will be unable
// to be destroyed once their hitpoints drop to zero or below. Finally, the last variable is the modification
// to whatever the current maximum hitpoints is for the entity. For example, if they have 25 hitpoints and
// their modifier is set to -8, the true maximum hitpoints for them will be 17.
hitpoints = 0;
maxHitpoints = 0;
maxHitpointModifier = 0;
maxHitpointFactor = 1;

// 
invulnerableTimer = 0;

// Some flags that are states an entity can be in that aren't normal "states" in terms of a state machine.
// Instead, they are general flags that can allows the states themselves to function differently based on what
// their values are set to. The first determines if the entity in "on the ground" AKA they are colliding in
// the z-axis with some object below them, and the next two determine if the entity is destroyed OR if the
// entity can be deleted to begin with. Finally, the last flag determines if the entity is currently in their
// invulnerable state or not after they take damage.
isGrounded = true;
isDestroyed = false;
isInvincible = false;
isHit = false;

// 
shadowOffsetX = 0;
shadowOffsetY = 0;
shadowRadius = 0;

// 
displayShadow = false;

// Three variables that handle how an entity's footsteps will sound relative to the material that exists
// below them at that given moment. (This is any tile found on the tilemap/layer stored within the first 
// variable at the entity's position) The next two variables are when in the animation of the entity that 
// the right and left feet hit the ground, respectively.
footstepTilemap = -1;
rightStepIndex = -1;
leftStepIndex = -1;

// Two variables that speed up the execution of the entity's footstep sound effect logic. The first is a 
// variable that stores the index pointing to the current footstep sound effect used for the entity's 
// footsteps. The second variable stores the last index of floor material that was collided with; updating
// the sound effect whenever the tile index changes.
curFootstepSound = -1;
lastTileIndex = -1;

// This flag will prevent the footstep sound from being played on EVERY in-game frame that the current 
// animation frame equal to one of the two footstep index variable values whenever it is flagged to false.
// The only way it will turn true again is when the animation frame is no longer equal to a footstep frame.
canPlayFootstep = false;

// Variables that are required for the built-in "state_cutscene_move" function that all dynamic entities
// have for use. They will track the target position that is required for that state to be considered
// fulfilled; the move speed being a multiplier for their base maximum horizontal and vertical movement
// speed that is exclusively used for said function.
targetX = 0;
targetY = 0;
moveSpeed = 1;

// Adds the entity to the depth sorter's global grid by expanding itself by one; making room for this entity's
// information for the depth sorting logic.
depth_sorter_add_entity();

#endregion

#region Functions for use in all children of the dynamic entity object

/// @description Getters for some of the "maximum" values contained within an entity object that can have
/// their actual max values changed by a respective modifier/factor variable. Below are the getters for the
/// entity's current maximum hitpoints, as well as their maximum horizontal and vertical movement speeds.
get_max_hitpoints = function()	{return max(1, floor((maxHitpoints + maxHitpointModifier) * maxHitpointFactor));}
get_max_hspd = function()		{return max(0, maxHspd * maxHspdFactor);}
get_max_vspd = function()		{return max(0, maxVspd * maxVspdFactor);}

/// @description A simple function that sets the current value of the entity's hitpoints relative to the
/// value that is supplied to the function's "_valueToAdd" argument. If their hitpoints after the value is
/// added to the function is less than zero, a non invincible entity will be flagged to be destroyed.
/// Otherwise, it is capped at whatever the current hitpoint maximum currently is.
/// @param {Real}	valueToAdd
set_hitpoints = function(_valueToAdd){
	hitpoints += _valueToAdd;
	if (hitpoints < 0 && !isInvincible)			{isDestroyed = true;}
	else if (hitpoints > get_max_hitpoints())	{hitpoints = get_max_hitpoints();}
}

/// @description A simple function that adjusts the value of the variable that stores the additive bonuses to
/// a given entity's maximum hitpoint value. Optionally, the same additive value can be added or subtracted
/// to the current hitpoint value to keep the gap between them consistent.
/// @param {Real}	valueToAdd
/// @param {Bool}	updateHitpointValue
set_max_hitpoint_modifier = function(_valueToAdd, _updateHitpointValue){
	maxHitpointModifier += _valueToAdd;
	if (_updateHitpointValue)	{set_hitpoints(_valueToAdd);}
	else						{set_hitpoints(0);} // This line prevents hitpoints from going above their new maximum.
}

/// @description A simple function that allows the adjustment of an entity's maximum hitpoint factor, which is
/// a value that is multiplied against the base max hitpoints and whatever the current modifier value is in
/// order to scale the maximum by a percentage relative to the sum other two values. Optionally, this function
/// can adjust the current hitpoints by the same factor that the max hitpoint value was changed by.
/// @param {Real}	valueToAdd
/// @param {Bool}	updateHitpointValue
set_max_hitpoint_factor = function(_valueToAdd, _updateHitpointValue){
	var _prevMaxHitpoints = get_max_hitpoints();
	maxHitpointFactor = max(0, maxHitpointFactor + _valueToAdd);
	if (_updateHitpointValue)	{set_hitpoints(get_max_hitpoints() - _prevMaxHitpoints);}
	else						{set_hitpoints(0);} // This line prevents hitpoints from going above their new maximum.
}

/// @description A function that updates an entity's position using pixel-perfect movement; storing any
/// fractional values until a whole value can be parsed out of them. Preventing sub-pixel movement is 
/// important in allowing pixel-perfect collision to occur while also using delta timing.
/// @param {Bool}	destroyOnCollide
update_position = function(_destroyOnCollide){
	// First, the true horizontal and vertical speed need to be calculated for the current frame. This means
	// taking whatever the hspd and vspd values are and multiplying them by the current value for delta time.
	var _deltaHspd, _deltaVspd;
	_deltaHspd = hspd * DELTA_TIME;
	_deltaVspd = vspd * DELTA_TIME;
	
	// Remove any fractional value from the calculated horizontal speed for the current frame. First, the
	// previous fraction is applied to the delta value before it's removed again; adding the new fraction
	// to that previous fraction as a result.
	_deltaHspd += hspdFraction;
	hspdFraction = _deltaHspd - (floor(abs(_deltaHspd)) * sign(_deltaHspd));
	_deltaHspd -= hspdFraction;
	
	// Doing the same thing as above, but for the entity's vertical movement values instead.
	_deltaVspd += vspdFraction;
	vspdFraction = _deltaVspd - (floor(abs(_deltaVspd)) * sign(_deltaVspd));
	_deltaVspd -= vspdFraction;
	
	// Finally, once the fractional values have been removed from the movement variables, and they have a
	// value greater than 0 within them, (Handling collision while both delta values are 0 is just a waste of
	// time) call the entity's collision function with the world's colliders.
	if (_deltaHspd != 0 || _deltaVspd != 0) {world_collision(_deltaHspd, _deltaVspd, _destroyOnCollide);}
}

/// @description A function that will provide collision detection between an entity and the world's colliders.
/// It will first move and check for collisions on the horizontal axis; followed by the vertical axis check
/// right after that. Opationally, the entity can be destroyed upon a collision with the world.
/// @param {Real}	deltaHspd
/// @param {Real}	deltaVspd
/// @param {Bool}	destroyOnCollide
world_collision = function(_deltaHspd, _deltaVspd, _destroyOnCollide){
	// Handling horizontal collision with the world.
	if (place_meeting_3d(x + _deltaHspd, y, z, obj_collider)){
		// Move the entity pixel-by-pixel horizontally until they finally collide with the wall perfectly.
		var _hspd = sign(hspd);
		while(!place_meeting_3d(x + _hspd, y, z, obj_collider)) {x += _hspd;}
		
		// Once a collision has occurred, two things need to happen. First, the flag for the entity to be
		// destroyed will be set relative to the argument's value, and the delta value for horizontal movement
		// will be set to 0; preventing any further movement on that axis.
		isDestroyed = _destroyOnCollide;
		_deltaHspd = 0;
	}
	x += _deltaHspd;
	
	// Handling vertical collision with the world.
	if (place_meeting_3d(x, y + _deltaVspd, z, obj_collider)){
		// Move the entity pixel-by-pixel vertically until they finally collide with the wall perfectly.
		var _vspd = sign(vspd);
		while(!place_meeting_3d(x, y + _vspd, z, obj_collider)) {y += _vspd;}
		
		// Once a collision has occurred, two things need to happen. First, the flag for the entity to be
		// destroyed will be set relative to the argument's value, and the delta value for vertical movement
		// will be set to 0; preventing any further movement on the axis.
		isDestroyed = _destroyOnCollide;
		_deltaVspd = 0;
	}
	y += _deltaVspd;
}

/// @description A function that updates the sprite currently being used by the entity. When switching the
/// sprite it will update the necessary data to match the new sprite's properties. Otherwise, the function
/// will simply update the animation speed modifier on every call--allowing for on-the-fly control of the
/// animation's overall speed.
/// @param {Asset.GMSprite}	spriteIndex
/// @param imageIndex
/// @param animationSpeed
set_sprite = function(_spriteIndex, _imageIndex = 0, _animationSpeed = 1){
	// Only update the sprite variables when a sprite change has occurred. Otherwise, grabbing these values
	// on every function call (These sprite changes should occur within state functions, which run every step)
	// will waste time since the values don't change.
	if (sprite_index != _spriteIndex){
		sprite_index = _spriteIndex;
		imageIndex = loopOffset + _imageIndex;
		spriteAnimSpeed = sprite_get_speed(sprite_index);
		spriteLength = sprite_get_number(sprite_index);
		loopLength = spriteLength / 4; // Each sprite contains 4 unique directional animations. (Up, down, right, and left)
	}
	
	// Whenever the animation speed for a given entity sprite is updated, ensure that the image index is
	// updated alongside it UNLESS the value for image index argument is -1; only then will the animation
	// resume or freeze on whatever frame the entity was at prior to this animation speed change.
	if (animSpeed != _animationSpeed){
		if (_imageIndex != -1){
			loopOffset = (loopLength * round(direction / SPRITE_ANGLE_DELTA)) % spriteLength;
			imageIndex = loopOffset + _imageIndex;
		}
		animSpeed = _animationSpeed;
	}
}

/// @description 
/// @param {Real}	damage
/// @param {Real}	invulnerablyTime
damage_entity = function(_damage, _invulnerableTime){
	// 
	if (isHit) {return;}
	set_hitpoints(-_damage);
	
	//
	if (_invulnerableTime > 0){
		object_set_next_state(state_stun_locked);
		invulnerableTimer = _invulnerableTime;
		isHit = true;
	}
}

#endregion

#region States for use in all children objects of par_dynamic_entity

/// @description
state_stun_locked = function(){
	// 
	invulnerableTimer -= DELTA_TIME;
	if (invulnerableTimer <= 0){
		object_set_next_state(lastState);
		invulnerableTimer = 0;
		isHit = false;
	}
	
	// 
	set_sprite(sprite_index, 0);
}

/// @description 
state_cutscene_move = function(){
	// 
	var _direction = point_direction(x, y, targetX, targetY);
	hspd = lengthdir_x(get_max_hspd() * moveSpeed, _direction);
	vspd = lengthdir_y(get_max_vspd() * moveSpeed, _direction);
	update_position(false);
	
	// 
	if (x == targetX && y == targetY) {object_set_next_state(NO_STATE);}
}

#endregion
