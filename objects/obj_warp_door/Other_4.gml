// 
if ((doorState == DOOR_LOCKED_KEY || doorState == DOOR_LOCK_CAN_OPEN) && ds_list_size(requiredKeys) == 0){
	doorState = DOOR_UNLOCKED;
}

// 
var _function = NO_FUNCTION;
switch(doorState){
	case DOOR_UNLOCKED:				_function = interact_door_unlocked;				break;
	case DOOR_BROKEN:				_function = interact_door_broken;				break;
	case DOOR_LOCK_OTHER_SIDE:		_function = interact_door_locked_other_side;	break;
	case DOOR_LOCK_CAN_OPEN:		_function = interact_door_locked_can_open;		break;
	case DOOR_LOCKED_KEY:			_function = interact_door_locked;				break;
}

// Create the interaction component that is attached to each door object. The function that is set to be called
// whenever this specific door object instance is interacted with by the player. This function is determined
// by the switch statement that is found above.
object_add_interact_component(x + 8, y + 6, 10, _function);
