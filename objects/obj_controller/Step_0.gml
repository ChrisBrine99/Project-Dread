// Call the function stored within the gamepad data struct that handles the hotswapping of the game's input
// between the currently connected controller and the keyboard depending on the most recent input(s) from both.
with(global.gamepad) {step();}

// Call the textbox handler's step event, which handles it player input functionality.
with(TEXTBOX_HANDLER) {step();}

// Loop through all of the currently existing menus and execute their step events, which handle player input,
// animations, and menu cursor movement logic.
var _length = ds_list_size(global.menuInstances);
for (var i = 0; i < _length; i++){
	with(global.menuInstances[| i]) {step();}
}