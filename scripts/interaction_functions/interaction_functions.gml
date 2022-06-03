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

/// @description 
function interact_door_locked(){
	var _doorUnlocked = false;
	with(parentID){
		// 
		var _length, _key;
		_length = ds_list_size(requiredKeys);
		repeat(_length){
			_key = requiredKeys[| 0];
			if (inventory_item_count(_key[0]) >= 1){
				textbox_add_text_data("You used the *" + YELLOW + "*" + _key[0] + "#.");
				ds_list_delete(requiredKeys, 0);
				EVENT_SET_FLAG(_key[1], true);
			}
		}
		
		// 
		_length = ds_list_size(requiredKeys);
		if (_length == 0){
			textbox_add_text_data("The door is now unlocked.");
			audio_play_sound_ext(unlockSound, 0, SOUND_VOLUME, 1, false);
			doorState = DOOR_UNLOCKED;
			_doorUnlocked = true;
		}
		// 
		else{
			textbox_add_text_data(doorInfoMessage);
			audio_play_sound_ext(lockedSound, 0, SOUND_VOLUME, 1, false);
		}
		
		// 
		textbox_begin_execution();
	}
	
	// 
	if (_doorUnlocked) {interactFunction = interact_door_unlocked;}
}

/// @description 
function interact_door_locked_other_side(){
	with(parentID){
		audio_play_sound_ext(lockedSound, 0, SOUND_VOLUME, 1, false);
		textbox_add_text_data("The door is locked from the other side.");
		textbox_begin_execution();
	}
}

/// @description 
function interact_door_locked_can_open(){
	with(parentID){
		// 
		doorState = DOOR_UNLOCKED;
		
		// 
		EVENT_SET_FLAG(requiredKeys[| 0][1], true);
		ds_list_delete(requiredKeys, 0);
		
		// 
		audio_play_sound_ext(unlockSound, 0, SOUND_VOLUME, 1, false);
		textbox_add_text_data("The door is now unlocked.");
		textbox_begin_execution();
	}
	
	// 
	interactFunction = interact_door_unlocked;
}

/// @description 
function interact_door_broken(){
	with(parentID){
		audio_play_sound_ext(lockedSound, 0, SOUND_VOLUME, 1, false);
		textbox_add_text_data(doorInfoMessage);
		textbox_begin_execution();
	}
}

#endregion
