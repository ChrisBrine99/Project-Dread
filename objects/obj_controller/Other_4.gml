// Calling each singleton's room start event, which handles code and logic that is required to be refreshed on a
// per-room basis. (Ex. the camera for each room needs to be initialized otherwise it won't function)
with(CAMERA)		{room_start();}
with(DEPTH_SORTER)	{room_start();}

// Don't bother with the room initialization code below this line if the current room is the initialization
// room because there will be no layers to match the onces that get turned invisible, and there is no way
// for there to be any dynamically created items in the room.
if (room == rm_init) {return;}

// Make the two layers that shouldn't be visible to the player invisible upon the new room's startup.
layer_set_visible(layer_get_id("Collision"), false);
layer_set_visible(layer_get_id("Floor_Material"), false);

// Loop through all interactable objects to see if the player should be able to interact with them or not.
update_interactable_interact_state();

// Loop through all of the world item data and create any of the dynamically created items in the rooms
// they were placed in by the player dropped an item from the inventory, or a cutscene creating an item,
// and other scenarios like that.
var _key, _itemData, _item;
_key = ds_map_find_first(global.worldItemData);
while(!is_undefined(_key)){
	// Loop through all of the currently existing world item data, searching for the item data that has an
	// index value of at least 100000. This value is significant because it lets the code know the item at
	// this position in the map is a dynamically created item, and it must be created here if the room
	// index the player is currently in matches the index for where the item should be.
	_itemData = global.worldItemData[? _key];
	if (_key >= 100000 && _itemData[| ITEM_DATA_ROOM] == room){
		_item = instance_create_object(_itemData[| ITEM_DATA_X_POS], _itemData[| ITEM_DATA_Y_POS], obj_world_item);
		with(_item){ // Assign data from the map structure to the necessary variables in the item object.
			itemName =			_itemData[| ITEM_DATA_NAME];
			itemQuantity =		_itemData[| ITEM_DATA_QUANTITY];
			itemDurability =	_itemData[| ITEM_DATA_DURABILITY];
			index =				_key;
			
			// Add the interact component to the object. Otherwise, the player will be unable to do
			// anything with the item.
			object_add_interact_component(x, y, 8, interact_item_collect_default, "Pick Up Item");
		}
	}
	
	// Keep looking for the next key in the map until that value returns "undefined". Once that value has
	// been hit, the loop will exit as the entire list has been parsed through by the code.
	_key = ds_map_find_next(global.worldItemData, _key);
}
