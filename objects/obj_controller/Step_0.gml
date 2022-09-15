// Call the function stored within the gamepad data struct that handles the hotswapping of the game's input
// between the currently connected controller and the keyboard depending on the most recent input(s) from both.
with(global.gamepad)	{step();}

// Updating all of the singleton structs that contain a step function within their code.
with(EFFECT_HANDLER)	{step();}
with(CUTSCENE_MANAGER)	{step();}
with(TEXTBOX_HANDLER)	{step();}
with(CONTROL_INFO)		{step();}
with(SCREEN_FADE)		{step();}
with(WEATHER_RAIN)		{step();}
with(WEATHER_FOG)		{step();}

// Update all of the existing light sources to handle their optional functionalities of lifespans and flicker.
var _length = ds_list_size(global.lightSources);
for (var l = 0; l < _length; l++){
	with(global.lightSources[| l]) {step();}
}

// Loop through all of the currently existing menus and execute their step events, which handle player input,
// animations, and menu cursor movement logic.
_length = ds_list_size(global.menuInstances);
for (var i = 0; i < _length; i++){
	with(global.menuInstances[| i]) {step();}
}