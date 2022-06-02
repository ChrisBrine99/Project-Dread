/// @description Insert summary of this file here.

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
	var _itemName, _itemQuantity, _itemDurability, _index;
	with(parentID){
		_itemName = itemName;
		_itemQuantity = itemQuantity;
		_itemDurability = itemDurability;
		_index = index;
	}
	
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
	
	// Display a different textbox configuration for each of the three leftover quantity possibilities when 
	// an item is picked up by the player: no quantity being picked up, only a portion being picked up, and 
	// all of the quantity picked up.
	if (_leftover == _itemQuantity){ // Item couldn't be picked up; let the user know this was the case.
		textbox_add_text_data("Your item inventory has no free space...");
	} else if (_leftover > 0){ // Only a portion of the item's sum could be picked up.
		textbox_add_text_data("Only *" + RED + "*" + string(_itemQuantity - _leftover) + "# of the *" + RED + "*" + string(_itemQuantity) + "# *" + YELLOW + "*" + _itemName + "# could be picked up and added to the inventory. The rest just couldn't fit...");
	} else{ // The complete quantity of the item was picked up, 
		// Depending on the type of item that was collected--and how much of an item can fit within a single
		// inventory slot--a different textbox message will appear when the item is collected. In short, the
		// quantity is shown for items that aren't weapons and can fit multiple of themselves in a single 
		// slot. Otherwise, only the item's name is shown.
		var _itemData = global.itemData[? KEY_ITEM_LIST][? _itemName];
		if (_itemData[? ITEM_QUANTITY] == 1 || _itemData[? ITEM_TYPE] == TYPE_WEAPON){ // A single item was picked up; don't display quantity.
			textbox_add_text_data("Picked up *" + YELLOW + "*" + _itemName + "#.");
		} else{ // An item that can hold multiple in a single slot was picked up; display the quantity alongside the item.
			textbox_add_text_data("Picked up *" + RED + "*" + string(_itemQuantity) + "# *" + YELLOW + "*" + _itemName + "#.");
		}
	}
	
	// Since all outcomes for this interaction script create a textbox in some way, the function that sets
	// the textbox up for executing on the added text information will always run at the end of this function.
	textbox_begin_execution();
}

/// @description A variation on the interaction for collecting an instance of "obj_world_item" wihtin the
/// game world. The difference here is that this will instantly cause the inventory to expand by two slots
/// since it's a specific interaction function for an "Item Pouch". It isn't added to the inventory at all
/// and simply increases the inventory before clearing itself out from the world item data structure.
function interact_item_collect_pouch(){
	// Perform the functionality for the item pouch; expanding the size of the inventory by two slots if
	// the currently difficulty setting allows the item inventory to still be increased in size.
	if (global.curItemInvSize < global.gameplay.maximumItemInvSize) {global.curItemInvSize += 2;}
	
	// Set up a single textbox that informs the player that they've collected an item inventory expansion.
	textbox_add_text_data("*" + YELLOW + "*Item Pouch# acquired! The amount of space to carry items has been permanently increased by *" + RED + "*two# slots!");
	textbox_begin_execution();
	
	// Finally, destroy the instance of the world itme object that the player interacted with, and remove
	// its data from the world item data structure so that it doesn't ever spawn again in the game world.
	with(parentID){
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
		isWarping = true; // Door enters its warping state, which perforsm the room switch.
	}
}

/// @description The function that is called whenever the player interacts with a warp object that is a door
/// AND is also locked with a variable number of keys needed to open it. It will check through the list of
/// those keys to see if the event flags for them have been toggled "true" or if the player has the key within
/// their item inventory, which will set the paired flag's value to "true". If all the required flags are
/// true, the door will be changed to an open door. Otherwise, the door's given message for its locked state
/// is shown to the player and the door will remain locked.
function interact_door_locked(){
	with(parentID){
		// First, the required keys list will be looped through; checking if the player has already used the
		// keys on the door or if they have the keys they haven't used within their item inventory at the
		// time the interaction occurred.
		var _keysUsed, _length, _keyData;
		_keysUsed = 0;
		_length = ds_list_size(requiredKeys);
		for (var i = 0; i < _length; i++){
			_keyData = requiredKeys[| i];
			// If the door is still locked, but one of the keys was already used by the player to unlock that
			// given lock for the door, it will be checked for here and simply skip the item removal and flag
			// setting code; incrementing the number of keys used by one and moving onto the next required key.
			if (EVENT_GET_FLAG(_keyData[DOOR_EVENT_ID])){
				_keysUsed++;
				continue;
			}
			
			// Check through the inventory to see if the player has at least one of the item that is required
			// to open the current lock for the door. Otherwise, the door will remain locked until they have
			// said key item.
			if (inventory_item_count(_keyData[DOOR_KEY_NAME]) >= 1){
				// Sicne the current key was found within the inventory, it will be used and removed from the
				// item inventory; setting its paired flag's value to true to signify this door now no longer
				// needs this key in order to be unlocked.
				EVENT_SET_FLAG(_keyData[DOOR_EVENT_ID], true);
				inventory_item_remove_amount(_keyData[DOOR_KEY_NAME], 1);
				
				// Add text data that tells the player they've automatically used the key stored within their
				// inventory by interacting with the locked door. The item's name will be colored yellow to
				// make it stick out against the rest of the text.
				textbox_add_text_data("Used the *" + YELLOW + "*" + _keyData[DOOR_KEY_NAME] + "#.");

				// Increment the number of keys used since a key was used successfully by the player.
				_keysUsed++;
			}
		}
		
		// If the amount of keys used for the door is equal to the length of required keys for said door, the
		// door will switch over to being unlocked. This requires starting the textbox's execution since the
		// function exits early and also swapping the warp object's interactFunction variable to point to the
		// unlocked variant of the interaction, which will warp the player to the room and the positions set
		// for the warp object's warp data.
		if (_keysUsed == _length){
			textbox_begin_execution();
			other.interactFunction = interact_door_unlocked;
			return; // Exit the script before the warp's general "locked" text can be added to the textbox queue.
		}
		
		// The door is still locked after the check, so the general textbox message for this door is shown
		// to the player so they know the door is currently locked. This message can be unique to each door
		// instance in the game; telling the number of keys needed, and so on.
		textbox_add_text_data(textboxMessage);
		
		// Finally, begin the textbox's execution once the message and its reqpective color data have been
		// added into the textbox's text data for rendering.
		textbox_begin_execution();
	}
}

/// @description A variation on the standard locked and unlocked door interaction functions that is unique 
/// to the "one-way locked door". This is a door that can only be opened from one side, and that side is
/// determined by the key's name; "oSide" for if the lock is on the other side, and "canOpen" for the side
/// that will unlock the door upon interaction. These strings are stored as constants for ease of use.
function interact_door_locked_other_side(){
	with(parentID){
		var _keyData = requiredKeys[| 0];
		// The door is locked, but the method of unlocking the door is on the OTHER SIDE of said doorway.
		// So, a textbox will pop up letting the player know that information, and the door's locked sound
		// will play; the door remaining locked afterward.
		if (_keyData[DOOR_KEY_NAME] == DOOR_LOCK_OTHER_SIDE){
			textbox_add_text_data("The door is locked from the other side.");
			audio_play_sound_ext(lockedSound, 0, SOUND_VOLUME, 1, false);
		}
		// The door is locked, and the way to unlock it is on the side the player is currently on. So, the
		// door's unlock sound will play, the event for the door lock being "open" is set to true, and the
		// interaction component's function will be set to the proper function for door warping to occur.
		else if (_keyData[DOOR_KEY_NAME] == DOOR_LOCK_CAN_OPEN){
			textbox_add_text_data("You unlocked the door.");
			audio_play_sound_ext(unlockSound, 0, SOUND_VOLUME, 1, false);
			EVENT_SET_FLAG(_keyData[DOOR_EVENT_ID], true);
			other.interactFunction = interact_door_unlocked;
		}
		
		// Since both outcomes will create a textbox of some kind, place the begin execution function at the
		// end of this interaction function to save on overall code.
		textbox_begin_execution();
	}
}

/// @description 
function interact_door_broken(){
	with(parentID){
		audio_play_sound_ext(lockedSound, 0, SOUND_VOLUME, 1, false);
		textbox_add_text_data(textboxMessage);
		textbox_begin_execution();
	}
}

#endregion
