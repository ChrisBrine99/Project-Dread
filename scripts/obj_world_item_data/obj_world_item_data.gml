/// @description Holds additional data that is used by or relevant to the "obj_world_item" object.

#region Initializing any macros that are useful/related to obj_world_item

// Macro constants that correspond to the index inside of the ds_list that each piece of data is found within
// the world item data map. The final four indexes are only ever utilized by items that were dynamically
// created during the game's runtime. (Ex. Being dropped by the player, a crafting output not being able to
// fit within the inventory, etc.)
#macro	ITEM_DATA_QUANTITY		0
#macro	ITEM_DATA_DURABILITY	1
#macro	ITEM_DATA_NAME			2
#macro	ITEM_DATA_X_POS			3
#macro	ITEM_DATA_Y_POS			4
#macro	ITEM_DATA_ROOM			5

#endregion

#region Initializing enumerators that are useful/related to obj_world_item
#endregion

#region Initializing any globals that are useful/related to obj_world_item

// The two data structures that are responsible for storing item data for any items that exist as physical
// object within the game world for the player to interact with. The map will store information about a
// given item's quantity, durability, and even its position, room, and name in certain circumstances. The
// list simply stores the index values for all items that have been completely collected by the player.
global.worldItemData = ds_map_create();
global.collectedItems = ds_list_create();

// The stored index value that is assigned to a dynamically created world item object. After being used by
// an instance that was created for whatever reason, the value will be incremented by one so that the item
// data is never overwritten by another dynamically created item.
global.dynamicItemID = 100000; // Starts at 100000 because GML uses that for instance ids and the like, so why not?

#endregion

#region Global functions related to obj_world_item

/// @description Spawns an instance of "obj_world_item" at the given cordinates in the current room; storing
/// the item's name, quantity, and durability within the matching variables in the object itself. On top of
/// that, the item's data is added to and stored within the world item data list since it is a newly spawned
/// item that will remain on the floor until collected by the player. In order to do this, addition data is
/// stored in the item's list structure found at its index in the world item map structure. (The added data
/// is the position of the object in the room, the item's name, and the room the object was placed in)
/// @param x
/// @param y
/// @param itemName
/// @param quantity
/// @param durability
function object_create_world_item(_x, _y, _itemName, _quantity, _durability){
	// First, create a new instance of the world item object and store its ID in a local variable. This is
	// so the required variables for the item can be set to the argument data for the item's name, quantity,
	// and durability. Otherwise, the item won't have any of that data OR the interact component attached
	// to it after it's created.
	var _item = instance_create_object(_x, _y, obj_world_item);
	with(_item){ // Jump into scope for the current instance of the world item object to set it up.
		itemName =			_itemName;
		itemQuantity =		_quantity;
		itemDurability =	_durability;
		index =				global.dynamicItemID;
		
		// Make sure that the interact component it added to the instance. This is necessary because the
		// interact component for this object is only ever set in the "Room Start" event, and these instances
		// are created after that event has been executed.
		object_add_interact_component(x, y, 8, interact_item_collect_default, "Pick Up Item");
	}
	
	// After creating and setting up the world item object, make sure its data is added to the global data
	// structure for all the uncollected items currently existing within the game world. Additional data for
	// the item's name, its x and y position within the room, and the room's index are all stored within the
	// list so that the item remains persistent despite being dynamically created in the game.
	var _list = ds_list_create();
	ds_list_add(_list, _quantity, _durability, _itemName, _x, _y, room);
	ds_map_add(global.worldItemData, global.dynamicItemID, _list);
	
	// Increment the automatic index value so that the item data that was just added to the world item data
	/// structure isn't overwritten once another world item object is created by this function.
	global.dynamicItemID++;
}

#endregion
