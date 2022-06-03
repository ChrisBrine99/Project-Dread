// Call the standard clean up event for the parent object for static entities since it's responsible for cleaning
// up all of the existing components that are paired to this object upon deletion.
event_inherited();

// 
ds_list_destroy(requiredKeys);