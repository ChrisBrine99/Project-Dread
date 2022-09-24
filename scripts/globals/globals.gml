/// @description Initializes all global variables that aren't bound to any specific object, but are instead 
/// used all throughout the code for various different tasks and reasons.

// 
global.itemData = encrypted_json_load("item_data.json", "");
// TODO -- Loading in the note data JSON file here

// Data structures that store the player's inventory. They are split into three unique catagories: general
// items, documents/notes, and maps of the game's various levels/areas. The items are stored in a standard
// array of a defined length; the current inventory size being a separate variable that limits how much of
// the array the player can access. The other two are data structures that are unique to Game Maker; a list
// for the notes, and a map for the maps, respectively.
global.items = array_create(24, noone);
global.notes = ds_list_create();
global.maps = noone;

// This value is responsible for limiting how much of the inventory the player has access to at any given
// time. This allows a single array to be initialized at the beginning of the game and remain unchanged in
// size; only this variable "changing" the size until the array's limit.
global.curItemInvSize = 0;

// A global list that stores pointers to all the currently existing interact components within the current
// room. This allows all of them to easily be iterated through and processed for when there is an interact
// check performed by the player object.
global.interactables = ds_list_create();
