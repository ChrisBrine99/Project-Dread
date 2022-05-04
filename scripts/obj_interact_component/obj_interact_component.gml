/// @description The interaction component, which allows the player to interact with whatever object(s) have
/// this component attached to them. The result of the interaction is unique and based on the function that
/// is supplied to the component and stored within its "interactFunction" variable.

#region Initializing any macros that are useful/related to obj_interact_component
#endregion

#region Initializing enumerators that are useful/related to obj_interact_component
#endregion

#region Initializing any globals that are useful/related to obj_interact_component
#endregion

#region The main object code for obj_interact_component

/// @param x
/// @param y
/// @param radius
/// @param interactFunction
/// @param id
function obj_interact_component(_x, _y, _radius, _interactFunction, _id) constructor{
	// Much like Game Maker's own object_index variable, this will store the unique ID value provided to this
	// object by Game Maker during runtime; in order to easily use it within a singleton system.
	object_index = obj_interact_component;
	
	// 
	x = _x;
	y = _y;
	
	// 
	radius = _radius;
	interactFunction = _interactFunction;
	
	//
	parentID = _id;
	
	// 
	canInteract = false;
	
	/// @description 
	can_player_interact = function(){
		// 
		with(PLAYER){
			if (isFlashlightOn){
				other.canInteract = true;
				return; // No calculations necessary, the player will alows be able to interact with the component.
			}
		}
		
		// 
		var _x, _y, _radius, _nearestLight, _nearestDistance, _length, _tempDistance;
		_x = x;
		_y = y;
		_radius = radius;
		_nearestLight = noone;
		_nearestDistance = 0;
		_length = ds_list_size(global.lightSources);
		for (var i = 0; i < _length; i++){
			with(global.lightSources[| i]){
				_tempDistance = compare_interactable_distance(_x, _y, _radius, _nearestDistance);
				if (_tempDistance != -1){ // Overwrite the previously closest light's data with the new light's data.
					_nearestDistance = _tempDistance;
					_nearestLight = id;
				}
			}
		}
		
		// 
		canInteract = (_nearestLight != noone);
	}
}

#endregion

#region Global functions related to obj_interact_component

/// @description 
/// @param x
/// @param y
/// @param radius
/// @param interactFunction
function object_add_interact_component(_x, _y, _radius, _interactFunction){
	if (interactComponent == noone){
		interactComponent = new obj_interact_component(_x, _y, _radius, _interactFunction, id);
		interactComponent.can_player_interact(); // Performs the check for if this can be interacted with by the player.
		ds_list_add(global.interactables, interactComponent); // Add to the list of interactables.
	}
}

/// @description Another global interact component function that is responsible for clearing it out of memory.
/// It also clears the pointer's value from the interactable instance list if it also exists within that list;
/// ensuring it is removed by the garbage collector to free up memory. This should be placed in the "cleanup"
/// event of ANY objects that use an interaction component struct.
function object_remove_interact_component(){
	if (interactComponent != noone){
		var _index = ds_list_find_index(global.interactables, interactComponent);
		if (!is_undefined(_index)) {ds_list_delete(global.interactables, _index);}
		// Much like the light and audio component removal functions, the interact component's pointer must
		// be deleted from memory to signal its cleanup for the garbage collector. Otherwise, the object will
		// remain in memory without a reference to it; a big bad memory leak.
		delete interactComponent;
		interactComponent = noone;
	}
}

#endregion
