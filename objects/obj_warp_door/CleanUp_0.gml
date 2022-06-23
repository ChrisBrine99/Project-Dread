// Call the standard clean up event for the parent object for static entities since it's responsible for cleaning
// up all of the existing components that are paired to this object upon deletion.
event_inherited();

// Remove the allocated memory for the list that stores the necessary keys required in order for the player to
// open a given door. Otherwise, a leak will occur since the pointer was lost before deallocation.
ds_list_destroy(requiredKeys);