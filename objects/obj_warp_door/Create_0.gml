#region Door macro initialization

//
#macro	DOOR_DIR_NORTH			0
#macro	DOOR_DIR_WEST			1
#macro	DOOR_DIR_SOUTH			2
#macro	DOOR_DIR_EAST			3

// Macros that explain what their respective value are within the require key list's two index arrays that
// it stores for each required key. The first is the name of the key so it can be found and referenced in 
// the item inventory, and the second is the unique event ID for this key's lock.
#macro	DOOR_KEY_NAME			0
#macro	DOOR_EVENT_ID			1

// Unique constants for what state the door is currently in; it's unlocked and warps the player when they
// interact with the door; it can't be opened at all and only displays a message stating that the door is
// broken; it's locked, but can only be opened from the other side; finally, it's locked and can be opened
// from the current side.
#macro	DOOR_UNLOCKED		   -10
#macro	DOOR_BROKEN			   -11
#macro	DOOR_LOCK_OTHER_SIDE   -12
#macro	DOOR_LOCK_CAN_OPEN	   -13
#macro	DOOR_LOCKED_KEY		   -14

#endregion

#region Variable inheritence and initialization

// Call the parent's create event, which will initialize all the necessary variables that are required for
// a static entity, and set its collision height on the fake Z-axis. Also, disable its ability to be rendered
// since the actual object itself isn't a sprite for a door, but just a purple square.
event_inherited();
zHeight = 16;
displaySprite = false;

// 
doorState = DOOR_UNLOCKED;
doorDirection = -1;

// The three variables that are responsible for the door's actual warping capabilities; what position it will
// place the player at and what room it will move the game into. If the target room is currently set to
// the constant ROOM_INDEX INVALID, no actual warping will occur since no proper room was supplied to the
// warp object instance.
targetX = 0;
targetY = 0;
targetRoom = ROOM_INDEX_INVALID;

// The flag that sets a given instance of this door warp object to being the process of warping the player
// to the target position and room data. Otherwise, no warp will be able to occur since the instance isn't
// checking for if said warp can currently occur within this flag toggled.
isWarping =	false;

// The stored sounds that will player whenever the door is opened by the player, (Occurs right during initial
// interaction with the door) and when the door is "closed" again by them. (Occurs as soon as the room change
// has occurred within the code) The length of the fade's full opacity duration is determined by how long
// the closing sound is multiplied by a factor of 0.8.
openingSound = NO_SOUND;
closingSound = NO_SOUND;

// The stored values for the sounds that will be played for a locked door that is interacted with, but isn't
// being opened by any keys from the interaction, and for when the door is finally unlocked by the player.
lockedSound = NO_SOUND;
unlockSound = NO_SOUND;

// 
doorInfoMessage = "";

// The variable that is responsible for storing the index value of a given list of required keys in the form
// of the name of the item and the unique event flag that stores whether or not that lock has been "opened"
// or not by the player; true and false respectively. If the index value is a valid ds_list's index value, the
// door is considered locked and it will need to be opened using the provided items on the door. If the value
// stored here is set to the constant DOOR_UNLOCKED, (-10) it will not need any keys and the door will be
// considered unlocked indefinitely.
requiredKeys = ds_list_create();
// Each index in this list will be formatted as follows:
//
//			requiredKeys (ds_list) = [
//				[itemName-0, eventID-0], 
//				[itemName-1, eventID-1], 
//				... 
//				[itemName-N, eventID-N]
//			];
//

#endregion

#region Function initialization

/// @description 
/// @param targetRoom
/// @param targetX
/// @param targetY
/// @param openingSound
/// @param closingSound
/// @param doorState
/// @param doorDirection
/// @param lockedSound
/// @param unlockSound
initialize_door_data = function(_targetRoom, _targetX, _targetY, _openingSound, _closingSound, _doorState = DOOR_UNLOCKED, _doorDirection = DOOR_DIR_NORTH,  _lockedSound = NO_SOUND, _unlockSound = NO_SOUND){
	// 
	if (room_exists(_targetRoom)){
		targetRoom =		_targetRoom;
		targetX =			_targetX;
		targetY =			_targetY;
	}
	
	// 
	doorState =		_doorState;
	doorDirection =	_doorDirection;
	
	// 
	openingSound =	_openingSound;
	closingSound =	_closingSound;
	lockedSound =	_lockedSound;
	unlockSound =	_unlockSound;
}

/// @description 
/// @param itemName
/// @param eventID
add_required_key = function(_itemName, _eventID){
	if (is_undefined(global.itemData[? KEY_ITEM_LIST][? _itemName])) {return;}
	if (!EVENT_CREATE_FLAG(_eventID)){
		ds_list_add(requiredKeys, [_itemName, _eventID]);
		doorState = DOOR_LOCKED_KEY;
	}
}

#endregion
