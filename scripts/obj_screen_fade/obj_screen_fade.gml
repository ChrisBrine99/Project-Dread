/// @description A simple struct that handles and manages a visual effect that causes the screen to fade in
/// and out of a given color; hading that color completely fill the screen for a set number of in-game frames
/// (One "frame" is equal to 1/60th of a second--doesn't represent an actual in game frame because of delta
/// timing being implemented) before fading back out. All objects will be paused during this process.

#region Initializing any macros that are useful/related to obj_screen_fade

// 
#macro	FADE_PAUSE_FOR_TOGGLE	   -250

#endregion

#region Initializing enumerators that are useful/related to obj_screen_fade
#endregion

#region Initializing any globals that are useful/related to obj_screen_fade
#endregion

#region The main object code for obj_screen_fade

/// @param fadeColor
/// @param fadeSpeed
/// @param fadeDuration
function obj_screen_fade(_fadeColor, _fadeSpeed, _fadeDuration) constructor{
	// Much like Game Maker's own object_index variable, this will store the unique ID value provided to this
	// object by Game Maker during runtime; in order to easily use it within a singleton system.
	object_index = obj_depth_sorter;
	
	// The main variables that effect how the fade looks on the screen when it's executing its effect. The
	// first value will determine the color of the fade, the second will determine how fast the fade will
	// reach complete opacity and reach full transparency again, and the third will determine how long in
	// frames (1/60th of a real-world second) the effect will be fully opaque for.
	fadeColor =		_fadeColor;
	fadeSpeed =		_fadeSpeed;
	fadeDuration =	_fadeDuration;
	// NOTE -- The "fadeDuration" value can be set to "FADE_PAUSE_FOR_TOGGLE" which will prevent the effect
	// from fading out until it is signaled to by overwriting this value. Useful for things like loading 
	// screens where the length of loading time isn't known.
	
	// The variables that determine the current opacity of the screen fade, and the value it is trying to
	// move towards given its current state. (This value is either 0 or 1)
	alpha = 0;
	alphaTarget = 1;

	/// @description 
	step = function(){
		alpha = value_set_linear(alpha, alphaTarget, fadeSpeed);
		if (fadeDuration != FADE_PAUSE_FOR_TOGGLE && alpha == 1 && alphaTarget == 1){ // Count down the duration until the fade out can begin.
			fadeDuration -= global.deltaTime;
			if (fadeDuration <= 0) {alphaTarget = 0;}
		} else if (alpha == 0 && alphaTarget == 0){ // The fade has completed; clear its pointer from the singleton map.
			GAME_SET_STATE(GAME_STATE_PREVIOUS, true);
			delete SCREEN_FADE;
			SCREEN_FADE = noone;
		}
	}
}

#endregion

#region Global functions related to obj_screen_fade

/// @description 
/// @param fadeColor
/// @param fadeSpeed
/// @param fadeDuration
function effect_create_screen_fade(_fadeColor, _fadeSpeed, _fadeDuration){
	// 
	if (SCREEN_FADE != noone) {return;}
	
	// 
	SCREEN_FADE = new obj_screen_fade(_fadeColor, _fadeSpeed, _fadeDuration);
	GAME_SET_STATE(GameState.Paused, true);
}

#endregion
