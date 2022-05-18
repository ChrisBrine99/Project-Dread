// Determine what functino is called when the doorway is interacted with by the player object. The default 
// state for the door will be assumed locked, so that will give it a choice between the one-sided doorway
// lock OR a standard locked door depending on the "isUniqueLock" flag's value. Otherwise, a function for a
// general unlocked door will use the function for warping the player to another room, and a broken door
// will use a unique function as well.
var _function = NO_FUNCTION;
switch(requiredKeys){
	case DOOR_UNLOCKED: // The door is unlocked, use the interaction function for opening a door.
		_function = interact_door_unlocked;
		break;
	case DOOR_BROKEN:
		_function = interact_door_broken;
		break;
	default: // The door is locked; determine how and set the appropriate function.
		var _length = ds_list_size(requiredKeys);
		if (_length == 1 && isUniqueLock)	{_function = interact_door_locked_other_side;}
		else								{_function = interact_door_locked;}
		break;
}

// Create the interaction component that is attached to each door object. The function that is set to be called
// whenever this specific door object instance is interacted with by the player. This function is determined
// by the switch statement that is found above.
object_add_interact_component(x + 8, y + 6, 10, _function);
