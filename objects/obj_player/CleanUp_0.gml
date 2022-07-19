// Call the parent event to clean up what is already handled in there.
event_inherited();

// Clean up the data structures that are required for the player's effect system to function properly. All it
// needs to do is look through the list of available keys and use those to delete the structs stored in the
// map at each of those keys. Then, the map and list have their memory freed.
if (ds_exists(effectKeys, ds_type_list)){
	var _length = ds_list_size(effectKeys);
	for (var i = 0; i < _length; i++) {delete additionalEffects[? effectKeys[| i]];}
	ds_map_destroy(additionalEffects);
	ds_list_destroy(effectKeys);
}

// Remove the structs that stored various data for the player from memory; avoiding their pointers 
// being lost and remaining allocated for the rest of the game's runtime.
delete equipSlot;
delete weaponData;
delete flashlightData;