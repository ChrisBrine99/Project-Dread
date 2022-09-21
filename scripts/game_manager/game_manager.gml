/// @description The game manager, which is responsible for handling the current global game state. That state
/// will affect all objects' current functionalities, as well as what the player is able to do (The player
/// cannot move the in-game player character during cutscenes, for example). On top of that, the manager will
/// calculate the delta time for the current frame, and also the total playtime.

#region Initializing any macros that are useful/related to the game manager

// 
#macro	GAME_CURRENT_STATE		global.gameManager.curState
#macro	GAME_PREVIOUS_STATE		global.gameManager.lastState

// 
#macro	DELTA_TIME				global.gameManager.deltaTime

// 
#macro	GSTATE_NONE				0
#macro	GSTATE_NORMAL			1
#macro	GSTATE_MENU				2
#macro	GSTATE_CUTSCENE			3
#macro	GAME_PAUSED				10

#endregion

#region Initializing enumerators that are useful/related to the game manager
#endregion

#region Initializing any globals that are useful/related to the game manager
#endregion

#region The main struct code for the game manager

global.gameManager = {
	// 
	curState :			GSTATE_NONE,
	lastState :			GSTATE_NONE,
	
	// 
	deltaTime :			0,
	targetFPS :			60,
	
	// 
	curPlaytime :		0,
	playtimeMillis :	0.0,
	isTimerActive :		false,
	
	/// @description 
	end_step : function(){
		deltaTime = (delta_time / 1000000) * targetFPS;
		
		// Update the current playtime if the timer hasn't been disabled by the current game state (The timer
		// will always be paused when the game is in a cutscene or completely paused).
		if (!isTimerActive) {return;}
		playtimeMillis += deltaTime;
		if (playtimeMillis >= 1.0){ // 1000 milliseconds have passed; add one second to the overall playtime.
			curPlaytime++;
			playtimeMillis -= 1.0;
		}
	}
}

#endregion

#region Global functions related to the game manager

/// @description 
/// @param {Real}	state			The new state value. If it is a lower value than the current state, no change will occur.
/// @param {Bool}	highPriority	A value of "true" will overwrite the current state regardless of the new state's value.
function game_set_state(_state, _highPriority = false){
	with(global.gameManager){
		if ((!_highPriority && _state > curState) || _highPriority){ 
			lastState = curState;
			curState = _state;
			isTimerActive = (curState < GSTATE_CUTSCENE);
		}
	}
}

/// @description Returns the current amount of playtime the player has accumulated over the course of their
/// gameplay. It is a value that is unique to each save file.
/// @param {Bool} includeMillis		Include the current milliseconds as the decimal value alongside the whole number for seconds.
function game_get_playtime(_includeMillis){
	with(global.gameManager) {return (_includeMillis ? (curPlaytime + millisTimer) : curPlaytime);}
	return 0;
}

#endregion