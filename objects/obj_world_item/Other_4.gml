// Setting the interaction function for the world item, which always defaults to the standard item collection
// function. However, if the item is an "Item Pouch" which doesn't technically exist within the context of a
// standard item in the game, its interaction function will be switched to one specifically for the item pouch.
var _function = interact_item_collect_default;
if (itemName == ITEM_POUCH) {_function = interact_item_collect_pouch;}

// After determining the interaction function to use with the component, initialize it to be located at the
// origin point of the entity (This is at the exact center of the sprite in this case) and set its radius to
// be half of the sprite's width/height.
object_add_interact_component(x, y, 8, _function);