// Destroy each singleton; cleaning up all their allocated data in the form of data structures, surfaces, and so
// on. For the player, the cleanup event is automatically called by GML's "instance_destroy" function, but for
// the other struct singletons their cleanups must be called before their pointer's deletion.
with(CAMERA)			{cleanup();}	delete CAMERA;
with(MUSIC_HANDLER)		{cleanup();}	delete MUSIC_HANDLER;
with(EFFECT_HANDLER)	{cleanup();}	delete EFFECT_HANDLER;
with(CUTSCENE_MANAGER)	{cleanup();}	delete CUTSCENE_MANAGER;
with(TEXTBOX_HANDLER)	{cleanup();}	delete TEXTBOX_HANDLER;
with(DEPTH_SORTER)		{cleanup();}	delete DEPTH_SORTER;
with(CONTROL_INFO)		{cleanup();}	delete CONTROL_INFO;
with(SCREEN_FADE)		{}				delete SCREEN_FADE;
with(DEBUGGER)			{cleanup();}	delete DEBUGGER;

// Destroy all existing menus and clean up their structs by calling each of their "menu_cleanup" functions.
// After that, delete the list that held all of the pointers to all current menus to free it from memory as well.
var _length = ds_list_size(global.menuInstances);
for (var i = 0; i < _length; i++){
	with(global.menuInstances[| i]) {cleanup();}
	delete global.menuInstances[| i];
}
ds_list_destroy(global.menuInstances);

// After cleaning up all the singletones and their allocated memory, clean up all of the global data structures
// and allocated memory before telling Game Maker to end the game's execution. The general order of this
// clean up doesn't really matter so long as they are all freed from memory here.
ds_map_destroy(global.sInstances);
ds_map_destroy(global.fontTextures);
ds_list_destroy(global.interactables);
delete global.shaderOutline;
delete global.shaderFeathering;
delete global.audioListener;
delete global.gameState;
delete global.events;
delete global.gameTime;
delete global.gameplay;
delete global.itemData;	// This single "delete" statement will automatically clear all contained data structures from memory.
delete global.settings;
delete global.gamepad;

// Clear out any structs that were contained within the player's item inventory before the execution of the game
// can be halted. Also, remove the data structures used for both the note and map inventories as well.
_length = array_length(global.items);
for (var i = 0; i < _length; i++){
	if (is_struct(global.items[i])){
		delete global.items[i];
		global.items[i] = noone;
	}
}
ds_list_destroy(global.notes);

// 
var _key = ds_map_find_first(global.worldItemData);
while(!is_undefined(_key)){
	ds_list_destroy(global.worldItemData[? _key]);
	_key = ds_map_find_next(global.worldItemData, _key);
}
ds_map_destroy(global.worldItemData);
ds_list_destroy(global.collectedItems);

// Finally, signal to Game Maker to terminate the program's execution; only after everything has been cleaned up.
game_end();