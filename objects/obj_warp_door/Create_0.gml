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

// Constants that allow the "one-way door" to function properly. They are stored in the same space as the
// item's name that is used as the "key" for unlocking the door; the first of the two making it so the door
// can't be opened from the current side no matter what, and the second being the name that unlocks the door
// from that given side.
#macro	LOCK_OTHER_SIDE			"oSide"
#macro	LOCK_CAN_OPEN			"canOpen"

#endregion

#region Variable inheritence and initialization

// Call the parent's create event, which will initialize all the necessary variables that are required for
// a static entity, and set its collision height on the fake Z-axis. Also, disable its ability to be rendered
// since the actual object itself isn't a sprite for a door, but just a purple square.
event_inherited();
zHeight = 16;
displaySprite = false;

// 
doorDirection = -1;

// The three variables that are responsible for the door's actual warping capabilities; what position it will
// place the player at and what room it will move the game into. If the target room is currently set to
// the constant ROOM_INDEX INVALID, no actual warping will occur since no proper room was supplied to the
// warp object instance.
targetX =		0;
targetY =		0;
targetRoom =	ROOM_INDEX_INVALID;

// The flag that sets a given instance of this door warp object to being the process of warping the player
// to the target position and room data. Otherwise, no warp will be able to occur since the instance isn't
// checking for if said warp can currently occur within this flag toggled.
isWarping =		false;

// The stored sounds that will player whenever the door is opened by the player, (Occurs right during initial
// interaction with the door) and when the door is "closed" again by them. (Occurs as soon as the room change
// has occurred within the code) The length of the fade's full opacity duration is determined by how long
// the closing sound is multiplied by a factor of 0.8.
openingSound =	NO_SOUND;
closingSound =	NO_SOUND;

// The stored values for the sounds that will be played for a locked door that is interacted with, but isn't
// being opened by any keys from the interaction, and for when the door is finally unlocked by the player.
lockedSound =	NO_SOUND;
unlockSound =	NO_SOUND;

// This variable pair stores the message that will be displayed whenever the player interacts with a given
// door instance that is locked AND unable to currently be opened by the player since they don't currently
// have the proper items within their inventory.
textboxMessage = "The door is locked.";
textboxColorData = 0;

// The variable that is responsible for storing the index value of a given list of required keys in the form
// of the name of the item and the unique event flag that stores whether or not that lock has been "opened"
// or not by the player; true and false respectively. If the index value is a valid ds_list's index value, the
// door is considered locked and it will need to be opened using the provided items on the door. If the value
// stored here is set to the constant DOOR_UNLOCKED, (-10) it will not need any keys and the door will be
// considered unlocked indefinitely.
requiredKeys = -1;
// Each index in this list will be formatted as follows:
//
//			requiredKeys (ds_list) = [
//				[itemName-0, eventID-0], 
//				[itemName-1, eventID-1], 
//				... 
//				[itemName-N, eventID-N]
//			];
//

// The flag that turns the door from a standard lock to one that can only be opened from a specific side; that
// side being determined by the string value stored where the key's item name would normally be. A value of
// "oSide" means it can't be opened from the current side, and "canOpen" means the door is unlocked upon
// interaction.
isUniqueLock = false;

#endregion

#region Function initialization

/// @description Assigns the base data that is required for the door; its opening/closing sounrds, and the
/// list of locks that exist for this door along with their paired event flags that signify if said locks are
/// "open" or not. It will also check for those event flag states; unlocking the door automatically if all
/// the required locks are set to "open" already. No warp data is applied by this function, however.
/// @param requiredKeys
/// @param index
/// @param openingSound
/// @param closingSound
set_base_door_data = function(_requiredKeys, _doorDirection, _openingSound, _closingSound){
	// First, set the door's direction. This can be any of the four cardinal directions and will determine
	// where and which arror indicator will be drawn to signify there's a doorway present for the player to
	// interact with. (Only if the door isn't broken)
	doorDirection = _doorDirection;
	
	// After that, assign the door's opening and closing sounds to match the values for the given sounds that 
	// were passed into their respective argument slots. These will be required no matter if the door is 
	// locked or unlocked much like the door's direction.
	openingSound = _openingSound;
	closingSound = _closingSound;
	
	// UNIQUE CASES -- A standard unlocked door and a broken one will both take this early exit from the
	// function since they don't required any key/event data to be checked or referenced. Instead, the constant
	// values for the door being unlocked (-10) or it being broken (-13) are stored where the index for the
	// door's key data ds_list would normally be stored.
	if (_requiredKeys == DOOR_UNLOCKED || _requiredKeys == DOOR_BROKEN){
		requiredKeys = _requiredKeys;
		return;
	}
	
	// Check the length of the list that stores the key data for this door instance. If the length is one,
	// there is a possibility that the door is a one-sided lock, so the key name will be checked to see if
	// it's a value of "oSide" or "canOpen". These two unique strings will signify that the door is a unique
	// lock and should be treated as such.
	var _length = ds_list_size(_requiredKeys);
	if (_length == 1 && (_requiredKeys[| 0][DOOR_KEY_NAME] == DOOR_LOCK_CAN_OPEN || _requiredKeys[| 0][DOOR_KEY_NAME] == DOOR_LOCK_OTHER_SIDE)){
		isUniqueLock = true; // Signals that the door can only be opened from one side.
	}
	
	// Loop through the list of keys that was passed into this function to see if their paired event flags
	// have already been toggled to true. If this is the case for a given key, it will increment the local
	// variable keeping track of the sum of unlocked locks for the door by one.
	var _unlockedLocks = 0;
	for (var i = 0; i < _length; i++){
		if (EVENT_CREATE_FLAG(_requiredKeys[| i][DOOR_EVENT_ID])) {_unlockedLocks++;}
		// NOTE -- The function for creating a flag returns the state of the flag if it already exists.
	}
	
	// If the sum of unlocked locks for a given door is equal to the total amount of locks needed to open
	// the door, it will not need any further use for the list's data AND it will be set to an unlocked door.
	if (_unlockedLocks == _length){
		ds_list_destroy(_requiredKeys);
		requiredKeys = DOOR_UNLOCKED;
		return; // Exit before the new destroyed list is passed into the door's variable for storing that list of required keys.
	}
	
	// Place the index value for the list that was created and passed into the function for the door's
	// required keys and their paired event flags signifying if they've been unlocked or not.
	requiredKeys = _requiredKeys;
}

/// @description Assigns the door's unique message, that message's color data, and the sound effects for
/// when the door is locked or when it is unlocked by its required keys, respectively. As the sounds suggest,
/// this data is only ever used when the door is locked. Otherwise, it's never used or shown to the player.
/// @param message
/// @param colorData
/// @param lockedSound
/// @param unlockSound
set_locked_door_data = function(_message, _colorData, _lockedSound, _unlockSound){
	textboxMessage = _message;
	textboxColorData = _colorData;
	lockedSound = _lockedSound;
	unlockSound = _unlockSound;
}

/// @description Assigns the target position and room for the player object whenever they interact with the
/// door AND it's unlocked. However, this data will only ever be set if the room index provided actually
/// points to an existing room within the game. Otherwise, no data is set to prevent crashing.
/// @param targetX
/// @param targetY
/// @param targetRoom
set_warp_data = function(_targetX, _targetY, _targetRoom){
	if (room_exists(_targetRoom)){
		targetX = _targetX;
		targetY = _targetY;
		targetRoom = _targetRoom;
	}
}

#endregion
