// Call the parent object's end step event, which will update the lighting/audio component positioning,
// the currently executing state function, and other general non-state related code.
event_inherited();

// 
if (GAME_STATE_CURRENT != GameState.Paused){
	update_accuracy_penalty();
	update_player_ailments();
}
