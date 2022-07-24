// Destroy each singleton; cleaning up all their allocated data in the form of data structures, surfaces, and so
// on. For the player, the cleanup event is automatically called by GML's "instance_destroy" function, but for
// the other struct singletons their cleanups must be called before their pointer's deletion.
with(CAMERA)			{cleanup();}	delete CAMERA;				CAMERA = noone;
with(MUSIC_HANDLER)		{cleanup();}	delete MUSIC_HANDLER;		MUSIC_HANDLER = noone;
with(EFFECT_HANDLER)	{cleanup();}	delete EFFECT_HANDLER;		EFFECT_HANDLER = noone;
with(CUTSCENE_MANAGER)	{cleanup();}	delete CUTSCENE_MANAGER;	CUTSCENE_MANAGER = noone;
with(TEXTBOX_HANDLER)	{cleanup();}	delete TEXTBOX_HANDLER;		TEXTBOX_HANDLER = noone;
with(DEPTH_SORTER)		{cleanup();}	delete DEPTH_SORTER;		DEPTH_SORTER = noone;
with(CONTROL_INFO)		{cleanup();}	delete CONTROL_INFO;		CONTROL_INFO = noone;
										delete SCREEN_FADE;			SCREEN_FADE = noone;
with(WEATHER_RAIN)		{cleanup();}	delete WEATHER_RAIN;		WEATHER_RAIN = noone;
with(WEATHER_FOG)		{cleanup();}	delete WEATHER_FOG;			WEATHER_FOG = noone;
with(DEBUGGER)			{cleanup();}	delete DEBUGGER;			DEBUGGER = noone;

// Destroy all existing menus and clean up their structs by calling each of their "menu_cleanup" functions.
// After that, delete the list that held all of the pointers to all current menus to free it from memory as well.
var _length = ds_list_size(global.menuInstances);
for (var i = 0; i < _length; i++){
	with(global.menuInstances[| i]) {cleanup();}
	delete global.menuInstances[| i];
}
ds_list_destroy(global.menuInstances);

// Destroy all of the interactable components that existed within the game's data when it was set to close
// down. After all the interact components have been freed from memory, the list is destroyed to clear it
// from memory.
_length = ds_list_size(global.interactables);
for (var i = 0; i < _length; i++) {delete global.interactables[| i];}
ds_list_destroy(global.interactables);

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

// Much like the item inventory, the world item data will have to have its memory cleared out manally by
// looping through the entire contents of the map. After that, the map and paired list are dleeted to clear
// them from memory as well.
var _key = ds_map_find_first(global.worldItemData);
while(!is_undefined(_key)){
	ds_list_destroy(global.worldItemData[? _key]);
	_key = ds_map_find_next(global.worldItemData, _key);
}
ds_map_destroy(global.worldItemData);
ds_list_destroy(global.collectedItems);

// Remove the event struct from memory and the map it contains that stores all of the event flag states
// that are currently being utilized within the game. After that, the struct itself is signalled to be
// destroyed from memory after it is cleaned up.
with(global.events) {cleanup();}
delete global.events;

// After cleaning up all the singletones and their allocated memory, clean up all of the global data structures
// and allocated memory before telling Game Maker to end the game's execution. The general order of this
// clean up doesn't really matter so long as they are all freed from memory here.
ds_map_destroy(global.fontTextures);
delete global.shaderOutline;
delete global.shaderFeathering;
delete global.audioListener;
delete global.gameState;
delete global.gameTime;
delete global.gameplay;
delete global.itemData;	// This single "delete" statement will automatically clear all contained data structures from memory.
delete global.settings;
delete global.gamepad;