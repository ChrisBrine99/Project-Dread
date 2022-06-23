// First thing to initialize is enabling the GPU's alpha testing, which will flush out pixels with a value of
// 0 in their alpha channel from the rendering pipeline; speeding up the rendering process.
gpu_set_alphatestenable(true);

// Disable the automatic rendering of the game's application surface, since the various shaders and effects will need to
// overwrite that process in order to display properly.
application_surface_draw_enable(false);

// TODO -- Load in settings here 

// Create an instance of the controller object and player object since they both need to exist 100% of the time.
// However, the player is initialized and then deactivated until the actual game has commenced; (AKA the user has
// started a new game or loaded from a previous save file) activiating once the user is actually in game.
global.sInstances[? KEY_CONTROLLER] = instance_create_depth(0, 0, 30, obj_controller);
global.sInstances[? KEY_PLAYER] = instance_create_depth(0, 0, 30, obj_player);

// By default, all keyboard icons are set to keyboard. (Since this is the PC version...) This function will
// initialize the control info icons to that control method.
control_info_set_icons_keyboard();

// Finally, once all the initialization has completed, move into the first true room of the game.
room_goto(rm_test01);

/// FOR TESTING
show_debug_overlay(true);

GAME_SET_STANDARD(Difficulty.Standard);
LISTENER_SET_OBJECT(PLAYER);

inventory_item_add(BRIGHT_FLASHLIGHT, 1, 0);
inventory_item_add(HANDGUN, 12, 40);
inventory_item_add(HANDGUN_AMMO, 35, 0);
with(PLAYER){
	initialize();
	equip_item_to_player(0);
	equip_item_to_player(1);
}
