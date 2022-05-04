/// @description A struct object that contains all the necessary information for a light source within the
/// game. This object can be attached to a main entity object in order for it to be used within the actual
/// game world, since they require a controller object in order to actually be utilized.

#region Initializing any macros that are useful/related to obj_light_component
#endregion

#region Initializing enumerators that are useful/related to obj_light_component
#endregion

#region Initializing any globals that are useful/related to obj_light_component
#endregion

#region The main object code for obj_light_component

/// @param x
/// @param y
/// @param radius
/// @param color
/// @param strength
/// @param fov
/// @param direction
/// @param persistent
function obj_light_component(_x, _y, _radius, _color, _strength = 1, _fov = 360, _direction = 0, _persistent = false) constructor{
	// Much like Game Maker's own object_index variable, this will store the unique ID value provided to this
	// object by Game Maker during runtime; in order to easily use it within a singleton system.
	object_index = obj_light_component;
	
	// Stores the ID for the light component, which allows it to reference itself (AKA it's pointer to its
	// space in memory) in pieces of code whenever necessary--particularly useful for checking if interactable
	// objects are close enough to be interacted with. (When no flashlight is active)
	id = noone;
	
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
	
	/// @description A very simple function that allows the position of the light to be set in a single
	/// line rather than the two it would normally required for both axes.
	/// @param x
	/// @param y
	set_position = function(_x, _y){
		x = _x;
		y = _y;
	}
	
	/// @description Another very simple function that allows the base properties of the light source to be
	/// modifieed with a single line of code; modifying the size, color, strength, and field of view for the
	/// light--allowing a light to change between a standard light and point light.
	/// @param radius
	/// @param color
	/// @param strength
	/// @param fov
	set_properties = function(_radius, _color, _strength, _fov){
		radius = _radius;
		color = _color;
		strength = _strength;
		fov = _fov;
	}
	
	/// @description 
	/// @param x
	/// @param y
	/// @param radius
	/// @param targetDistance
	compare_interactable_distance = function(_x, _y, _radius, _targetDistance){
		// 
		if (strength < -8.0) {return -1;}
		
		// 
		var _distance = point_distance(_x, _y, x, y);
		if (_distance < radius * 1.05){
			// 
			var _direction, _fovHalf;
			_direction = point_direction(x, y, _x, _y);
			_fovHalf = fov * 0.5;
			if (fov < 180 && (_direction < direction - _fovHalf - 5 || _direction > direction + _fovHalf + 5)) {return -1;}
			
			// 
			if (_targetDistance == 0 || _distance < _targetDistance) {return _distance;}
		}
		
		// 
		return -1;
	}
}

#endregion

#region Global functions related to obj_light_component

/// @description A simple function that creates a new light component struct; adding it to the ID storage
/// variable found on each entity object while also placing that same ID into the list used to render all of
/// those light sources from within "obj_effect_handler".
/// @param x
/// @param y
/// @param radius
/// @param color
/// @param strength
/// @param fov
/// @param direction
/// @param persistent
function object_add_light_component(_x, _y, _radius, _color, _strength = 1, _fov = 360, _direction = 0, _persistent = false){
	if (lightComponent == noone){
		lightComponent = new obj_light_component(_x, _y, _radius, _color, _strength, _fov, _direction, _persistent);
		lightComponent.id = lightComponent; // Stores the "ID" value for the struct
		ds_list_add(global.lightSources, lightComponent); // Add to the list of currently existing light sources
	}
}

/// @description Another light component function that removes it from memory to prevent any leaking when the
/// parent entity is deleted or the pointer is lost from the global render list without explicitly telling
/// Game Maker to delete the struct. Putting this function in the entity's "Clean Up" event will prevent that
/// from ever being an issue.
function object_remove_light_component(){
	if (lightComponent != noone && !lightComponent.isPersistent){
		var _index = ds_list_find_index(global.lightSources, lightComponent);
		if (!is_undefined(_index)) {ds_list_delete(global.lightSources, _index);}
		// Regardless if the light was part of the list for light source instances or not, it will still need
		// to be deleted from memory. Otherwise, this will cause a leak of an unchecked light struct instance.
		delete lightComponent;
		lightComponent = noone;
	}
}

#endregion