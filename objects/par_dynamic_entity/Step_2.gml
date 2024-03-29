// Overwrite the current state the value contained in the "nextState" variable only if the value contained
// within said variable is a valid index for a script/method value generated by Game Maker.
if (curState != nextState && script_exists(nextState)){
	curState = nextState;
}

// Updating the position of the entity's light component to match the position of the entity at the end of
// each game frame; accounting for any movement that may have taken place as well as the light's offset relative
// to the entity's actual position in the room.
if (lightComponent != noone){
	var _x, _y; // Store position as local variables, since Game Maker prefers these when jumping between objects.
	_x = x + lightOffsetX;
	_y = y + lightOffsetY + z;
	with(lightComponent) {set_position(_x, _y);}
}

// 
if (audioComponent != noone){
	// TODO -- Add audio component position updating here
}