// If the door was set to be locked, (Either from the other side or by a certain number of keys) but the
// player has already met the conditions needed to unlock the doorway, make sure that is reflected in the
// actual code for the door so that it's still open despite factors like the room changing, the game being
// closed and opened again, or something along those lines.
if ((doorState == DOOR_LOCKED_KEY || doorState == DOOR_LOCK_CAN_OPEN) && ds_list_size(requiredKeys) == 0){
	doorState = DOOR_UNLOCKED;
}

// Determine how interaction with the door should function based on the "state" it's currently found in. There
// are five unique varieties for a doorway's state: it's unlocked and interacting will cause a warp to occur
// to the target room and position; the door is broken and cannot be opened; it's locked, but can be opened
// from the other side of the doorway; the door is locked and can be opened from the current side of the door;
// and the door is locked, but requires a specific key or multiple keys to unlock it.
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
object_add_interact_component(x + 8, y + 6, 10, _function, "Open Door");
