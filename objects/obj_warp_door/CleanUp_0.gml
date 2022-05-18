// Call the standard clean up event for the parent object for static entities since it's responsible for cleaning
// up all of the existing components that are paired to this object upon deletion.
event_inherited();

// Delete the list that stores data about the required keys that need to be used in order to allow the door to
// actually be opened and used by the player to warp to different areas. Since this can be deleted before clean
// up, the variable is checked to see if a valid list actually exists at its index value.
if (ds_exists(requiredKeys, ds_type_list)) {ds_list_destroy(requiredKeys);}
