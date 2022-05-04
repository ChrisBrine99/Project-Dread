// Call the parent event to clean up what is already handled in there.
event_inherited();

// Remove the structs that stored various data for the player from memory; avoiding their pointers 
// being lost and remaining allocated for the rest of the game's runtime.
delete equipSlot;
delete weaponData;
delete flashlightData;
