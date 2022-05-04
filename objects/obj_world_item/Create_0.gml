#region Variable inheritance and initialization

// Call the parent object's create event, which will initialize all of the variables that are required for this
// child object to functio; all before any of the new variables specific to this child are initialized.
event_inherited();

// The three variables required for adding an item struct object to the inventory upon collection by the
// player through a valid interaction check. The name will point to the item's data in the master item data
// structure, and the quantity/durability will be set based on the values that are unique to each world item.
itemName = NO_ITEM;
itemQuantity = 0;
itemDurability = 0;

#endregion

#region Function initialization

/// @description A simple function that will populate the required data for the world item data with the 
/// name for the item, along with its set quantity and durability, respectively. These last two values will
/// be limited to whatever the maximum possible values are for the item should they ever exceed those values.
/// @param name
/// @param quantity
/// @param durability
set_item_data = function(_name, _quantity, _durability){
	// Make sure that the item provided to the function is actually one that exists within the game's data.
	// Otherwise, it will cause a crash when attempting to limit the quantity and durability values to their
	// maximum possible limits for the item, since there isn't an item to begin with.
	var _itemData = global.itemData[? KEY_ITEM_LIST][? _name];
	if (is_undefined(_itemData)) {return;}
	
	// Store the provided item's name, as well as the quantity and durability values for said item. When it
	// comes to both the quantity and durability, the values will be limited to a range of 1 and whatever
	// the maximum quantity per slot is or 0 and the maximum durability value for the item, respectively.
	itemName =			_name;
	itemQuantity =		clamp(_quantity, 1, _itemData[? ITEM_QUANTITY]);
	itemDurability =	clamp(_durability, 0, _itemData[? ITEM_DURABILITY]);
}

/// @description
add_to_world_item_data = function(){
	
}

/// @description
remove_from_world_item_data = function(){
	
}

#endregion
