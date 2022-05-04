// Call the parent object's end step event, which will update the lighting/audio component positioning,
// the currently executing state function, and other general non-state related code.
event_inherited();

// Update the value for the player's accuracy penalty here since it doesn't rely on whatever state the
// player object is currently assigned to. So, it will be reduced here by calling the function.
update_accuracy_penalty();
