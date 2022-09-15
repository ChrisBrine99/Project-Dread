/// @description A struct object that contains all the necessary information for a light source within the
/// game. This object can be attached to a main entity object in order for it to be used within the actual
/// game world, since they require a controller object in order to actually be utilized.

#region Initializing any macros that are useful/related to obj_light_component

// A macro constant that prevents the deletion of a light source due to its lifespan value being at or going
// below a value of zero. This value will completely bypass the code for the optional mechanic.
#macro	INF_LIFESPAN		-75

#endregion

#region Initializing enumerators that are useful/related to obj_light_component
#endregion

#region Initializing any globals that are useful/related to obj_light_component
#endregion

#region The main object code for obj_light_component

/// @param {Real}			x
/// @param {Real}			y
/// @param {Real}			radius
/// @param {Constant.Color}	color
/// @param {Real}			strength
/// @param {Real}			fov
/// @param {Real}			direction
/// @param {Bool}			persistent
/// @param {Bool}			trueLight
function obj_light_component(_x, _y, _radius, _color, _strength = 1, _fov = 360, _direction = 0, _persistent = false, _trueLight = true) constructor{
	// Much like Game Maker's own object_index variable, this will store the unique ID value provided to this
	// object by Game Maker during runtime; in order to easily use it within a singleton system.
	object_index = obj_light_component;
	
	// Stores the ID for the light component, which allows it to reference itself (AKA it's pointer to its
	// space in memory) in pieces of code whenever necessary--particularly useful for checking if interactable
	// objects are close enough to be interacted with. (When no flashlight is active)
	id = noone;
	
	// Stores the unique ID value for the instance that this light component is attached to. This allows
	// the component to always know exactly which instance is linked to them if the parent ever needs to
	// be referenced through the light component.
	parentID = noone;
	
	// Create two variables for the coordinates of the light within the game world, which are identical to
	// the variable pair that is built into every Game Maker object by default.
	x = _x;
	y = _y;
	
	// Much like above, create a variable that borrows its naming convention from Game Maker's default object
	// variables; providing the same functionality for this struct as it would in said default object.
	direction = _direction;
	
	// Initialize the rest of the variable for the light component, which determines how large the light
	// source is; its color; the "strength" of the light at the origin; the "field of view" for the light,
	// which allows for directional light sources; and whether or not the light ir persistent--staying in
	// existence between various rooms.
	radius = _radius;
	color = _color;
	strength = _strength;
	fov = _fov;
	isPersistent = _persistent;
	
	// A flag that lets interactable objects know that the current light instance isn't actually a light
	// that exists within the game world. (Ex. The small, faint light around the player that illuminates
	// them slightly when in complete darkness)
	trueLight = _trueLight;
	
	// The variables that manage the light component's optional flickering effect. This effect will alter
	// the radius of the light to be somewhere within the percentage range of the minimum and maximum flicker
	// values. The rate that is changes radius size to produce that "flicker" is based on the value stored in
	// the "flickerInterval" variable.
	minFlicker = 1;
	maxFlicker = 1;
	flickerInterval = 0;
	flickerTimer = 0;
	
	// Stores a copy of the radius value for when the flicker effect is applied. Otherwise, it would have to
	// be based on the previous flicker effect's change to the radius and have no actually base value to use;
	// making it eventually stray from that initial radius setting.
	baseRadius = _radius;
	
	// Stores a timer (60 units = 1 second of real-world time) that counts down until it reaches zero. Once
	// zero has been reached or surpassed, the light component will automatically be deleted.
	lifespan = INF_LIFESPAN;
	
	/// @description Code that should be placed into the "Step" event of whatever object is controlling
	/// obj_light_component. It simply updates the variables and values associated with the optional effects
	/// that can be applied to a light source: lifespan and flickering.
	step = function(){
		// Update the value for the remaining lifespan of the light source if the value isn't currently the
		// default value for a light that never deletes itself, which is a macro defined at the top of this
		// file.
		if (lifespan != INF_LIFESPAN){
			lifespan -= DELTA_TIME;
			if (lifespan <= 0){
				// Remove the light's pointer from the global struct that holds and manages all currently
				// existing light sources in the game. Otherwise, the pointer in here would remain despite
				// the light no longer technically existing.
				var _index = ds_list_find_index(global.lightSources, id);
				if (!is_undefined(_index)) {ds_list_delete(global.lightSources, _index);}
				
				// Remove the pointer from the parent object (If a parent object actually exists for the light
				// component) and then "delete" this struct by referencing its id value (This value should be
				// what is also stored in the  parent's lightComponent variable).
				with(parentID) {lightComponent = noone;}
				delete id; // Signals to GM that this struct can be removed from memory.
			}
		}
		
		// Update the flicker effect, which will alter the radius randomly whenever the tiemr goes below or
		// reaches a value of zero. After that, a new radius is determined and the timer is reset based on
		// the determined speed of the effect.
		if (minFlicker != maxFlicker){
			flickerTimer -= DELTA_TIME;
			if (flickerTimer <= 0){
				flickerTimer = flickerInterval; // Reset the timer to whatever the flicker interval is.
				radius = baseRadius * random_range(minFlicker, maxFlicker);
			}
		}
	}
	
	/// @description A very simple function that allows the position of the light to be set in a single
	/// line rather than the two it would normally required for both axes.
	/// @param {Real}	x
	/// @param {Real}	y
	set_position = function(_x, _y){
		x = _x;
		y = _y;
	}
	
	/// @description Another very simple function that allows the base properties of the light source to be
	/// modifieed with a single line of code; modifying the size, color, strength, and field of view for the
	/// light--allowing a light to change between a standard light and point light.
	/// @param {Real}	radius
	/// @param {Real}	color
	/// @param {Real}	strength
	/// @param {Real}	fov
	set_properties = function(_radius, _color, _strength, _fov){
		radius = _radius;
		baseRadius = _radius;
		color = _color;
		strength = _strength;
		fov = _fov;
	}
	
	/// @description Sets the light up to flicker. The "flicker" is achieved by randomly changing the radius of
	/// said light to be some random value within the range of the minimum and maximum flicker amount. This
	/// minimum and maximum is calculated based on the percentage they change the original radius by; a 0.95
	/// minimum and 1.05 maximum would cause the radius to change to anything within the 95% and 105% range
	/// of the original radius. The interval determines how fast the flicker occurs in-game.
	/// @param {Real}	minFlicker
	/// @param {Real}	maxFlicker
	/// @param {Real}	flickerInterval
	apply_flicker = function(_minFlicker, _maxFlicker, _flickerInterval){
		minFlicker = _minFlicker;
		maxFlicker = _maxFlicker;
		flickerInterval = _flickerInterval;
		flickerTimer = _flickerInterval;
	}
	
	/// @description A function that compares the distance (And direction in the case of point light sources)
	/// of the current light source instance to the distance of another object; (The interactable component
	/// paired with said object) seeing if that value is closer than the supplied target value. This basically
	/// determines if the light has any effect on the visibilty of the object in question.
	/// @param {Real}	x
	/// @param {Real}	y
	/// @param {Real}	radius
	/// @param {Real}	targetDistance
	compare_interactable_distance = function(_x, _y, _radius, _targetDistance){
		// The strength variable determines how bright the light is perceived in the game world. If this value
		// is too low, it will barely illuminate the area and thus the interactable isn't recieving enough
		// light for it to be "seen" without a flashlight or another light source.
		if (strength <= -8.0 || !trueLight) {return -1;}
		
		// The light is bright enough to have an effect. First, the distance between the origin point of the
		// light and origin point of the interact component is compared against the light's radius multiplied
		// by 1.05x its actual value. If this returnes true, the light is within range to be seen and the
		// light's direction is checked if the light has a low fov value. Otherwise, the distance is compared
		// to the supplied target distance to see if it's closer than that value.
		var _distance = point_distance(_x, _y, x, y);
		if (_distance < radius * 1.05){
			// If the fov is lower than a value of 180 it means the light is a point light. So, the direction
			// of the light relative to the direction of the interactable must be considered; the latter
			// value being within the range of the light's direction and that fov value, respecively. If that
			// is that case, the light has an effect on the interactable's visibility. Otherwise, a -1 is
			// returned to signify a failed check.
			if (fov < 360){
				var _direction, _fovHalf;
				_direction = point_direction(x, y, _x, _y);
				_fovHalf = fov * 0.5;
				if (_direction < direction - _fovHalf - 5 || _direction > direction + _fovHalf + 5) {return -1;}
			}
			
			// Compare the distance of the current light source instance and the interactable from each other.
			// If this value is lower than the "target distance" OR that distance target is a value of 0, the
			// function will return the value of the calculated distance so the interactable will know to
			// use this instance as its "can interact" flag toggle.
			if (_targetDistance == 0 || _distance < _targetDistance) {return _distance;}
		}
		
		// The distance between the light and the interactable was too great to have any effect on the
		// visibilty of the interactable; return -1 for a failed check so no previous data is overwritten.
		return -1;
	}
}

#endregion

#region Global functions related to obj_light_component

/// @description A simple function that creates a new light component struct; adding it to the ID storage
/// variable found on each entity object while also placing that same ID into the list used to render all of
/// those light sources from within "obj_effect_handler".
/// @param {Real}			x
/// @param {Real}			y
/// @param {Real}			offsetX
/// @param {Real}			offsetY
/// @param {Real}			radius
/// @param {Constant.Color}	color
/// @param {Real}			strength
/// @param {Real}			fov
/// @param {Real}			direction
/// @param {Bool}			persistent
/// @param {Bool}			trueLight
function object_add_light_component(_x, _y, _offsetX, _offsetY, _radius, _color, _strength = 1, _fov = 360, _direction = 0, _persistent = false, _trueLight = true){
	if (lightComponent == noone){
		// Create the light component and store its unique pointer within the entity's struct for keeping
		// track of and manipulating said component after it's created. Add it to the global list of light
		// sources as well for rendering.
		lightComponent = new obj_light_component(_x, _y, _radius, _color, _strength, _fov, _direction, _persistent, _trueLight);
		lightComponent.id = lightComponent; // Stores the "ID" value for the struct
		lightComponent.parentID = id; // Stores the object ID that is managing this light component
		ds_list_add(global.lightSources, lightComponent);
	
		// Make sure the supplied offsets relative to the entity's actual position are stored within the
		// necessary variables that keep that offset preserved even if the entity's position changes.
		lightOffsetX = _offsetX;
		lightOffsetY = _offsetY;
	}
}

/// @description Another light component function that removes it from memory to prevent any leaking when the
/// parent entity is deleted or the pointer is lost from the global render list without explicitly telling
/// Game Maker to delete the struct. Putting this function in the entity's "Clean Up" event will prevent that
/// from ever being an issue.
/// @param {Bool}	removePersistent
function object_remove_light_component(_removePersistent = false){
	if (lightComponent != noone && (!lightComponent.isPersistent || _removePersistent) && ds_exists(global.lightSources, ds_type_list)){
		var _index = ds_list_find_index(global.lightSources, lightComponent);
		if (!is_undefined(_index)) {ds_list_delete(global.lightSources, _index);}
		// Regardless if the light was part of the list for light source instances or not, it will still need
		// to be deleted from memory. Otherwise, this will cause a leak of an unchecked light struct instance.
		delete lightComponent;
		lightComponent = noone;
	}
}

#endregion