// Call the parent object's end step event, which will update the lighting/audio component positioning,
// the currently executing state function, and other general non-state related code.
event_inherited();

// 
var _gameState = GAME_STATE_CURRENT; // Store locally for quicker reference
if (_gameState != GameState.Paused){
	check_collision_interactable();
	update_accuracy_penalty();
	//update_effect_timers();
}

// 
if (_gameState < GameState.Cutscene){
	check_collision_cutscene_trigger();
	update_player_ailments();
}