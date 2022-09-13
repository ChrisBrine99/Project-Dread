/// @description Stores the functions that are called whenever an object's interaction component has been
/// "interacted" with by the player. (Meaning they pressed their currently binded interact input when they
/// are within the range of an object's interaction component's radius) This includes items, maps, notes,
/// doors, and general environmental objects that are scattered throughout the game world.

#region Item interaction functions

/// @description The default item collection interaction function, which will attempt to add the collected
/// item to the inventory. As a result, there are three possible outcomes for this function: the player's
/// item inventory is full and the item couldn't be collected; only a partial amount of the quantity found
/// in the world item object instance could be collected at the moment; or the item was collected without
/// any issues from the item inventory. Each one provides a different outcome to let the player know what
/// has occurred from the interaction.
function interact_item_collect_default(){
	// First, grab the item data from the parent object that this interaction component is currently attached
	// to. Putting "with(obj_world_item)" would only return the item data from LAST CREATED INSTANCE of that 
	// object, so a parentID variable storing the paired instance is used instead.
	var _itemName, _itemQuantity, _itemDurability, _pickupSound, _index;
	with(parentID){
		_itemName = itemName;
		_itemQuantity = itemQuantity;
		_itemDurability = itemDurability;
		_pickupSound = pickupSound;
		_index = index;
	}
	if (is_undefined(_itemName)) {return;}
	
	// Perform the attempt of adding the item to the inventory relative to the provided quantity from the
	// world item object's data. Then, see if the item was successfully collected, (The variable "_leftover"
	// is 0 in that case) or if it was only partially collected.
	var _leftover = inventory_item_add(_itemName, _itemQuantity, _itemDurability);
	if (_leftover == 0){ // Removes the item object from the world and clear out its data from the world item data structure.
		with(parentID){
			instance_destroy_object(self);
			remove_item_data();
		}
	} else if (_leftover < _itemQuantity){ // Update the stored quantity values since only a partial amount was collected.
		itemQuantity = _leftover;
		global.worldItemData[? _index][| ITEM_DATA_QUANTITY] = _leftover;
	}
	
	// If the player happens to have picked up some ammunition, it will be checked against the ammunition
	// found within the currently equipped weapon. If the ammo matches what's in said weapon, the value
	// stored in the struct for the remaining ammo in the inventory is updated to match this new addition
	// to the inventory.
	if (global.itemData[? KEY_ITEM_LIST][? _itemName][? ITEM_TYPE] == TYPE_AMMO){
		with(PLAYER){
			if (equipSlot.weapon != noone && weaponData.ammoTypes[| curAmmoType] == _itemName){
				weaponData.ammoRemaining += _itemQuantity - _leftover;
			}
		}
	}
	
	// Display a different textbox configuration for each of the three leftover quantity possibilities when 
	// an item is picked up by the player: no quantity being picked up, only a portion being picked up, and 
	// all of the quantity picked up.
	if (_leftover == _itemQuantity){ // Item couldn't be picked up; let the user know this was the case.
		textbox_add_text("Your item inventory has no free space...");
	} else if (_leftover > 0){ // Only a portion of the item's sum could be picked up.
		textbox_add_text("Only *" + RED + "*" + string(_itemQuantity - _leftover) + "# of the *" + RED + "*" + string(_itemQuantity) + "# *" + YELLOW + "*" + _itemName + "# could be picked up and added to the inventory. The rest just couldn't fit...");
		textbox_add_sound_effect(_pickupSound); // Add the pickup sound to be played by the textbox.
	} else{ // The complete quantity of the item was picked up, 
		// Depending on the type of item that was collected--and how much of an item can fit within a single
		// inventory slot--a different textbox message will appear when the item is collected. In short, the
		// quantity is shown for items that aren't weapons and can fit multiple of themselves in a single 
		// slot. Otherwise, only the item's name is shown.
		var _itemData = global.itemData[? KEY_ITEM_LIST][? _itemName];
		if (_itemData[? ITEM_QUANTITY] == 1 || _itemData[? ITEM_TYPE] == TYPE_WEAPON){ // A single item was picked up; don't display quantity.
			textbox_add_text("Picked up *" + YELLOW + "*" + _itemName + "#.");
		} else{ // An item that can hold multiple in a single slot was picked up; display the quantity alongside the item.
			textbox_add_text("Picked up *" + RED + "*" + string(_itemQuantity) + "# *" + YELLOW + "*" + _itemName + "#.");
		}
		textbox_add_sound_effect(_pickupSound); // Add the pickup sound to be played by the textbox.
	}
	
	// Since all outcomes for this interaction script create a textbox in some way, the function that sets
	// the textbox up for executing on the added text information will always run at the end of this function.
	textbox_activate();
}

/// @description A variation on the interaction for collecting an instance of "obj_world_item" wihtin the
/// game world. The difference here is that this will instantly cause the inventory to expand by two slots
/// since it's a specific interaction function for an "Item Pouch". It isn't added to the inventory at all
/// and simply increases the inventory before clearing itself out from the world item data structure.
function interact_item_collect_pouch(){
	// Perform the functionality for the item pouch; expanding the size of the inventory by two slots if
	// the currently difficulty setting allows the item inventory to still be increased in size.
	if (global.curItemInvSize < MAXIMUM_INVENTORY_SIZE) {global.curItemInvSize += 2;}
	
	// Jump into scope of the parent of the current interaction component in order to reference its sound
	// effect for the pickup; destroying the parent instance and subsequently removing its data from the
	// global item data structure to signify the item can no longer be picked up.
	with(parentID){
		// Initialize the textbox to display information about what picking up the item pouch does for
		// them, while also assigning the textbox to play the sound effect for the item pouch being picked
		// up in the first place.
		textbox_add_text("*" + YELLOW + "*Item Pouch# acquired! The amount of space to carry items has been permanently increased by *" + RED + "*two# slots!");
		textbox_add_sound_effect(pickupSound, 10);
		textbox_activate();
		
		// Finally, destroy this instance and remove its data from the world item data structure.
		instance_destroy_object(self);
		remove_item_data();
	}
}

#endregion

#region Note interaction functions



#endregion

#region Door interaction functions

/// @description The function that begins the door's room warp code. All it does upon interaction is create
/// the screen effect that will fade in and cover the room and player position change from being seen. Also,
/// the opening sound for the current door is played; along with the closing sound after the warp has occurred.
function interact_door_unlocked(){
	effect_create_screen_fade(HEX_BLACK, 0.075, FADE_PAUSE_FOR_TOGGLE);
	with(parentID){
		audio_play_sound_ext(openingSound, 0, SOUND_VOLUME, 1, false);
		isWarping = true; // Door enters its warping state, which performs the room switch logic.
	}
}

/// @description Interacting with a door, but it is currently locked; requiring a certain amount of keys.
/// These "keys" are simply just items that exist within the game's data, so anything wihtin the master
/// "Item List" can be used as one. This function will check if the door's required keys are stored in the
/// player's item inventory at the moment of interaction. If they are, they will be consumed by the door;
/// removing them from the inventory if their "quantity" reaches zero. (Quantity in this case is used to
/// track the total number of doors a given key can open) If all the required keys are used on the door, it
/// will unlock. Otherwise, the door will remain in this locked state until that condition is fulfilled.
function interact_door_locked(){
	var _doorUnlocked = false;
	with(parentID){
		// First, loop through all of the required keys for the current door, and check if they can be used
		// to remove that lock from the door. Each key will have its paired flag in the event data set to
		// true to signify that this lock 's state is persistent within the game. After that, the key's
		// data is cleared from the door's required key list.
		var _key = -1;
		var _length = ds_list_size(requiredKeys);
		repeat(_length){
			_key = requiredKeys[| 0];
			if (inventory_item_count(_key[DOOR_KEY_NAME]) >= 1){
				textbox_add_text("You used the *" + YELLOW + "*" + _key[DOOR_KEY_NAME] + "#.");
				textbox_add_sound_effect(unlockSound);
				ds_list_delete(requiredKeys, 0);
				EVENT_SET_FLAG(_key[DOOR_EVENT_ID], true);
			}
		}
		
		// After looping through the required key data, the length of that data structure is grabbed to 
		// see what happens next for the door. If the length is 0, the list is empty and the door should
		// now be treated as an unlocked door, since no more locks exist for it. As a resuilt, the door's
		// state will switch to an "unlocked" state and interacting with it will treat it like an unlocked
		// door now.
		_length = ds_list_size(requiredKeys);
		if (_length == 0){
			textbox_add_text("The door is now unlocked.");
			doorState = DOOR_UNLOCKED;
			_doorUnlocked = true;
		}
		// If the length for the door currently isn't a value of zero, it means there are still a certain
		// number of keys required to full unlock the doorway. So, the door's info message is shown through
		// the textbox and its locked sound will be played; letting the player know they still can't access
		// this doorway.
		else{
			textbox_add_text(doorInfoMessage);
			textbox_add_sound_effect(lockedSound);
		}
		
		// Since both outcomes above require the textbox in some way, the function to begin the execution
		// of textbox data is always called at the end of this code.
		textbox_activate();
	}
	
	// Since the function that determines how an object is interacted with is stored witin the interact
	// component struct itself, (That's where it's called from during an interaction event) it must be
	// updated within scope of the component, and not the object attached to the component. It will update
	// the function to be the standard unlocked door interaction function IF the door was unlocked by the
	// player. Otherwise, nothing will change.
	if (_doorUnlocked) {interactFunction = interact_door_unlocked;}
}

/// @description An interaction for a unique type of door that is locked, but from its other side instead
/// of by a given key item or set of key items. In this case, the door will simply display a textbox letting
/// the player know they are on the wrong side of the door when it comes to unlocking it, and will play
/// the given sound effect for this door's "locked sound".
function interact_door_locked_other_side(){
	with(parentID){
		audio_play_sound_ext(lockedSound, 0, SOUND_VOLUME, 1, false);
		textbox_add_text("The door is locked from the other side.");
		textbox_activate();
	}
}

/// @description An interaction with a unique type of locked door. In this case, the player will be on the
/// side that can be used to unlock the door; allowing access through it from both directions once this
/// interaction function has completed its execution. The event tied to this door will have its state set
/// to true, so that the door being unlocked remains persistent.
function interact_door_locked_can_open(){
	with(parentID){
		// No keys are required, so the door's state will instantly be set to "unlocked" and treated as
		// such until its event flag is set to "false" again.
		doorState = DOOR_UNLOCKED;
		
		// The event flag is updated to true in order to reflect that the door has been unlocked by the
		// player, and the data for that "key" is removed from the data structure of key data within the
		// door object.
		EVENT_SET_FLAG(requiredKeys[| 0][DOOR_EVENT_ID], true);
		ds_list_delete(requiredKeys, 0);
		
		// Finally, the door's unlocking sound effect is played, and the textbox is used to inform the
		// player that they've opened this once locked door.
		audio_play_sound_ext(unlockSound, 0, SOUND_VOLUME, 1, false);
		textbox_add_text("The door is now unlocked.");
		textbox_activate();
	}
	
	// Update the interact component's function to match the door's now unlocked state; meaning that any
	// interactions with this door will now play out like they would for an unlocked door.
	interactFunction = interact_door_unlocked;
}

/// @description A unique door that cannot be accessed through any means by the player. It will simply play
/// its "locked" sound effect and display a message using the textbox. This message will just be a variation
/// on letting the player know they can't access this door as it's broken.
function interact_door_broken(){
	with(parentID){
		audio_play_sound_ext(lockedSound, 0, SOUND_VOLUME, 1, false);
		textbox_add_text(doorInfoMessage);
		textbox_activate();
	}
}

#endregion

#region Key item interaction functions

/// @description Gives the player the key they need to exit the first test room.
function interact_bookshelf_key(){
	textbox_add_text("Hmm... There's something between two of the books on the shelf.", 1, 1, Actor.Claire, 0);
	textbox_add_text("It's a *" + YELLOW + "*grimy key#.", 1, 1, Actor.Claire, 0);
	textbox_add_text("Hopefully it'll open my only way out of here...", 1, 1, Actor.Claire, 1);
	textbox_activate();
	
	inventory_item_add(RIFLE_ROUNDS, 1, 0, true);
	interactFunction = interact_bookshelf_key_collected;
	EVENT_SET_FLAG("FirstKey", true);
}

/// @description
function interact_bookshelf_key_collected(){
	textbox_add_text("There's nothing else of importance on the bookshelf.", 1, 1, Actor.Claire, 0);
	textbox_activate();
}

#endregion

#region Generic interaction functions

/// @description Inspecting a bookshelf that has nothing of note for the player to find.
function inspect_bookshelf(){
	textbox_add_text("Just a regular old bookshelf.");
	textbox_activate();
}

#endregion