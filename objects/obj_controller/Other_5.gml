// Unloads all of the non-persistent light sources from memory before moving onto the next room.
effect_unload_room_lighting();

// Also, clear out the list of interactable pointer values from memory since a new room has been entered, which will
// fill the list with new pointers to the interact components that exist within the current room.
ds_list_clear(global.interactables);
