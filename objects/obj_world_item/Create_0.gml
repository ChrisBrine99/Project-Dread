#region Variable inheritance and initialization

// Call the parent object's create event, which will initialize all of the variables that are required for this
// child object to functio; all before any of the new variables specific to this child are initialized.
event_inherited();

// Set the item object to display a shadow below itself; with the radius being half the width of the sprite
// used to show the items within the game world.
object_set_shadow(true, 8, -1, 0);

// The three variables required for adding an item struct object to the inventory upon collection by the
// player through a valid interaction check. The name will point to the item's data in the master item data
// structure, and the quantity/durability will be set based on the values that are unique to each world item.
itemName = NO_ITEM;
itemQuantity = 0;
itemDurability = 0;

// Stores the index value for this item's data, which is then stored within the world item map using this
// index's value as the key to said ds_list of data. This allows for persistence of items that have been
// collected without having to use Game Maker's built-in persistence flags.
index = noone;

#endregion

#region Function initialization

/// @description The function that assigns the instance of "obj_world_item" with item information that is
/// provided in the creation code of said instance; the item's name, its quantity, the durability, and the
/// unique index that is assigned to the item for use with the world item data structure that stores said
/// data for the item collection persistence system.
/// @param name
/// @param quantity
/// @param durability
/// @param index
set_item_data = function(_name, _quantity, _durability, _index){
	// First, check if the item's unique index value is found within the list for tracking all the items
	// that have been collected during the player's current playthrough. If a matching index value is found
	// within the list, the item has been collected, so the object is destroy; preventing the player from
	// collecting it again.
	if (ds_list_find_index(global.collectedItems, _index) != -1){
		instance_destroy(self);
		return; // Exit early since the object was destroyed.
	}
	
	// If the item hasn't been collected yet; the next thing to do is see if the item already has information
	// stored within the world item data map structure. If this is the case, the item has been initialized
	// previously and all that needs to be done is grab that stored information for the instance to use.
	var _itemData = global.worldItemData[? _index];
	if (!is_undefined(_itemData)){
		itemName =			_name;
		itemQuantity =		global.worldItemData[? _index][| ITEM_DATA_QUANTITY];
		itemDurability =	global.worldItemData[? _index][| ITEM_DATA_DURABILITY];
		index =				_index;
		return; // Exit early since the proper item information has already been grabbed.
	}
	
	// Make sure that the item provided to the function is actually one that exists within the game's data.
	// Otherwise, it will cause a crash when attempting to limit the quantity and durability values to their
	// maximum possible limits for the item, since there isn't an item to begin with.
	_itemData = global.itemData[? KEY_ITEM_LIST][? _name];
	if (is_undefined(_itemData)) {return;}
	
	// Store the provided item's name, as well as the quantity and durability values for said item. When it
	// comes to both the quantity and durability, the values will be limited to a range of 1 and whatever
	// the maximum quantity per slot is or 0 and the maximum durability value for the item, respectively.
	itemName =			_name;
	itemQuantity =		clamp(_quantity, 1, _itemData[? ITEM_QUANTITY]);
	itemDurability =	clamp(_durability, 0, _itemData[? ITEM_DURABILITY]);
	
	// Finally, create the data structure within the world data map structure for this index value by calling
	// the function that is responsible for assigning the index value to a variable and also creating the
	// data within said map structure if it doesn't exist at the moment.
	assign_item_index(_index);
}

/// @description A variation on the standard function for setting item data that is used for assigning an
/// "Item Pouch" to the object. This is a unique item that is consumed as soon as its interacted with by the
/// player; expanding their inventory by two slots. So, it uses this function since the "Item Pouch" isn't
/// found within the global item data; it isn't an actual item in that sense and has no data for itself
/// within that ds_map. This function allows the object to bypass any check for the item data map having
/// valid data for the item, which is what the default function is required to do.
/// @param index
set_to_item_pouch = function(_index){
	// Much like the default function for setting item information for the object; this one will first check
	// if the item has been collected by searching through a list of collected item indexes for the supplied
	// index value. If the value is found, the object is deleted so it can't be collected again.
	if (ds_list_find_index(global.collectedItems, _index) != -1){
		instance_destroy(self);
		return;
	}
	
	// The "Item Pouch" is unique in that it doesn't require a quantity or durability to be set; just the name
	// and index value for storing the "data" within the map structure. (This data is just two 0 values, but 
	// it's required for the item persistence system)
	itemName = ITEM_POUCH;
	assign_item_index(_index);
}

/// @description A simple function that assigns the index value for the item to the variable "index"; also
/// check if that index doesn't have a valid data structure stored within the world map data structure. If
/// it doesn't the function will create a new list storing the item's quantity and durability; placing that
/// into the map with the index value serving as the key to access that data.
/// @param index
assign_item_index = function(_index){
	index = _index;
	if (is_undefined(global.worldItemData[? _index])){
		var _data = ds_list_create(); // No need to delete this list since it's being placed into a map.
		ds_list_add(_data, itemQuantity, itemDurability);
		ds_map_add(global.worldItemData, _index, _data);
	}
}

/// @description Clears out a given item's data from the world item data ds_map; adding its index value to
/// the global ds_list that tracks collected item indexes. This list prevents the item from ever spawning
/// again since the player has already collected the item.
remove_item_data = function(){
	ds_list_destroy(global.worldItemData[? index]);
	ds_map_delete(global.worldItemData, index);
	ds_list_add(global.collectedItems, index);
}

#endregion
