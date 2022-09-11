/// @description A script file containing all the code and logic for the game's control information display.

#region Initializing any macros that are useful/related to obj_control_info

// 
#macro	ALIGNMENT_RIGHT				1001
#macro	ALIGNMENT_LEFT				1002
#macro	ALIGNMENT_UP				1003
#macro	ALIGNMENT_DOWN				1004

// Key constants for the "inputIcons" map found within obj_control_info. They point to all inputs that
// relate to the player character's movement around the game world.
#macro	INPUT_GAME_RIGHT			"input_game_right"
#macro	INPUT_GAME_LEFT				"input_game_left"
#macro	INPUT_GAME_UP				"input_game_up"
#macro	INPUT_GAME_DOWN				"input_game_down"
#macro	INPUT_RUN					"input_run"

// Key constants for the "inputIcons" map within obj_control_info. They point to all inputs that cause the
// player to make some sort of use of their currently equipped weapon.
#macro	INPUT_READY_WEAPON			"input_ready_weapon"
#macro	INPUT_USE_WEAPON			"input_use_weapon"
#macro	INPUT_RELOAD_GUN			"input_reload_gun"
#macro	INPUT_AMMO_SWAP				"input_ammo_swap"

// Key constants for the "inputIcons" map within obj_control_info. They all point to inputs that are used
// while the player is in-game, and do things like interact with the world and modifying their flashlight.
#macro	INPUT_INTERACT				"input_interact"
#macro	INPUT_FLASHLIGHT			"input_flashlight"
#macro	INPUT_LIGHT_SWAP			"input_light_swap"

// Key constants for the "inputIcons" map within obj_control_info. These four point to the inputs responsible
// for opening the player's inventory--shortcutting to a specific page of it, (Items, notes, and maps, 
// respectively) and also the input for opening/closing the game's pause menu.
#macro	INPUT_ITEMS					"input_items"
#macro	INPUT_NOTES					"input_notes"
#macro	INPUT_MAPS					"input_maps"
#macro	INPUT_PAUSE					"input_pause"

// Constants that correspond to the key/value pair for a given menu input's icon; in this case a directional 
// input for moving the cursor around the menu.
#macro	INPUT_MENU_RIGHT			"input_menu_right"
#macro	INPUT_MENU_LEFT				"input_menu_left"
#macro	INPUT_MENU_UP				"input_menu_up"
#macro	INPUT_MENU_DOWN				"input_menu_down"
#macro	INPUT_AUX_MENU_RIGHT		"input_aux_menu_right"
#macro	INPUT_AUX_MENU_LEFT			"input_aux_menu_left"

// Constants for icons that are paired with the current inputs for selecting options/elements within the menu,
// closing out the menu or unselected a currently selected option/element, and the input for deleting the
// highlighted save slot in the load game menu.
#macro	INPUT_SELECT				"input_select"
#macro	INPUT_RETURN				"input_return"
#macro	INPUT_FILE_DELETE			"input_file_delete"

// Constants for the icons paired with the inputs for advancing a dialogue box within the current textbox,
// and for opening the current textbox/cutscene dialogue log.
#macro	INPUT_ADVANCE				"input_advance"
#macro	INPUT_LOG					"input_log"

// Macros that store the unique guid value and description for a given controller. In short, all supported
// controllers will have constants located here.
#macro	XINPUT_GAMEPAD			"none,XInput STANDARD GAMEPAD"
#macro	SONY_DUALSHOCK_FOUR		"4c05cc09000000000000504944564944,Sony DualShock 4"
#macro	SONY_DUALSENSE			"4c05e60c000000000000504944564944,Wireless Controller"
#macro	SWITCH_PRO_CONTROLLER	""

#endregion

#region Initializing enumerators that are useful/related to obj_music_handler

/// @description
enum Gamepad{
	None,
	Generic,
	Xbox,
	PlayStation,
	Nintendo,
}

#endregion

#region Initializing any globals that are useful/related to obj_control_info

// Since the keyboard itself doesn't need to account for changing icon sprites in order to match the currently
// connected AND supported controller, all the data can just be stored inside of a map; with each key being
// the keycode constant needed to retrieve the struct containing the keyboard's icon.
global.keyboardIcons = ds_map_create();
ds_map_add(global.keyboardIcons, vk_backspace,		{iconSprite : spr_keyboard_icons_large,		imgIndex : 2}); 
ds_map_add(global.keyboardIcons, vk_tab,			{iconSprite : spr_keyboard_icons_medium,	imgIndex : 22}); 
ds_map_add(global.keyboardIcons, vk_enter,			{iconSprite : spr_keyboard_icons_large,		imgIndex : 3});
ds_map_add(global.keyboardIcons, vk_shift,			{iconSprite : spr_keyboard_icons_large,		imgIndex : 1}); 
ds_map_add(global.keyboardIcons, vk_pause,			{iconSprite : spr_keyboard_icons_small,		imgIndex : 53}); 
ds_map_add(global.keyboardIcons, vk_capslock,		{iconSprite : spr_keyboard_icons_large,		imgIndex : 4}); 
ds_map_add(global.keyboardIcons, vk_escape,			{iconSprite : spr_keyboard_icons_medium,	imgIndex : 27}); 
ds_map_add(global.keyboardIcons, vk_space,			{iconSprite : spr_keyboard_icons_large,		imgIndex : 0}); 
ds_map_add(global.keyboardIcons, vk_pageup,			{iconSprite : spr_keyboard_icons_medium,	imgIndex : 24}); 
ds_map_add(global.keyboardIcons, vk_pagedown,		{iconSprite : spr_keyboard_icons_medium,	imgIndex : 25}); 
ds_map_add(global.keyboardIcons, vk_end,			{iconSprite : spr_keyboard_icons_large,		imgIndex : 10}); 
ds_map_add(global.keyboardIcons, vk_home,			{iconSprite : spr_keyboard_icons_large,		imgIndex : 7});
ds_map_add(global.keyboardIcons, vk_left,			{iconSprite : spr_keyboard_icons_small,		imgIndex : 2});
ds_map_add(global.keyboardIcons, vk_up,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 0});
ds_map_add(global.keyboardIcons, vk_right,			{iconSprite : spr_keyboard_icons_small,		imgIndex : 3});
ds_map_add(global.keyboardIcons, vk_down,			{iconSprite : spr_keyboard_icons_small,		imgIndex : 1});
ds_map_add(global.keyboardIcons, vk_insert,			{iconSprite : spr_keyboard_icons_large,		imgIndex : 6});
ds_map_add(global.keyboardIcons, vk_delete,			{iconSprite : spr_keyboard_icons_medium,	imgIndex : 23});
ds_map_add(global.keyboardIcons, vk_0,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 52});
ds_map_add(global.keyboardIcons, vk_1,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 43});
ds_map_add(global.keyboardIcons, vk_2,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 44});
ds_map_add(global.keyboardIcons, vk_3,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 45});
ds_map_add(global.keyboardIcons, vk_4,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 46});
ds_map_add(global.keyboardIcons, vk_5,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 47});
ds_map_add(global.keyboardIcons, vk_6,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 48});
ds_map_add(global.keyboardIcons, vk_7,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 49});
ds_map_add(global.keyboardIcons, vk_8,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 50});
ds_map_add(global.keyboardIcons, vk_9,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 51});
ds_map_add(global.keyboardIcons, vk_a,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 4});
ds_map_add(global.keyboardIcons, vk_b,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 5});
ds_map_add(global.keyboardIcons, vk_c,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 6});
ds_map_add(global.keyboardIcons, vk_d,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 7});
ds_map_add(global.keyboardIcons, vk_e,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 8});
ds_map_add(global.keyboardIcons, vk_f,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 9});
ds_map_add(global.keyboardIcons, vk_g,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 10});
ds_map_add(global.keyboardIcons, vk_h,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 11});
ds_map_add(global.keyboardIcons, vk_i,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 12});
ds_map_add(global.keyboardIcons, vk_j,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 13});
ds_map_add(global.keyboardIcons, vk_k,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 14});
ds_map_add(global.keyboardIcons, vk_l,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 15});
ds_map_add(global.keyboardIcons, vk_m,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 16});
ds_map_add(global.keyboardIcons, vk_n,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 17});
ds_map_add(global.keyboardIcons, vk_o,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 18});
ds_map_add(global.keyboardIcons, vk_p,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 19});
ds_map_add(global.keyboardIcons, vk_q,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 20});
ds_map_add(global.keyboardIcons, vk_r,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 21});
ds_map_add(global.keyboardIcons, vk_s,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 22});
ds_map_add(global.keyboardIcons, vk_t,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 23});
ds_map_add(global.keyboardIcons, vk_u,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 24});
ds_map_add(global.keyboardIcons, vk_v,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 25});
ds_map_add(global.keyboardIcons, vk_w,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 26});
ds_map_add(global.keyboardIcons, vk_x,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 27});
ds_map_add(global.keyboardIcons, vk_y,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 28});
ds_map_add(global.keyboardIcons, vk_z,				{iconSprite : spr_keyboard_icons_small,		imgIndex : 29});
ds_map_add(global.keyboardIcons, vk_numpad0,		{iconSprite : spr_keyboard_icons_medium,	imgIndex : 12});
ds_map_add(global.keyboardIcons, vk_numpad1,		{iconSprite : spr_keyboard_icons_medium,	imgIndex : 13});
ds_map_add(global.keyboardIcons, vk_numpad2,		{iconSprite : spr_keyboard_icons_medium,	imgIndex : 14});
ds_map_add(global.keyboardIcons, vk_numpad3,		{iconSprite : spr_keyboard_icons_medium,	imgIndex : 15});
ds_map_add(global.keyboardIcons, vk_numpad4,		{iconSprite : spr_keyboard_icons_medium,	imgIndex : 16});
ds_map_add(global.keyboardIcons, vk_numpad5,		{iconSprite : spr_keyboard_icons_medium,	imgIndex : 17});
ds_map_add(global.keyboardIcons, vk_numpad6,		{iconSprite : spr_keyboard_icons_medium,	imgIndex : 18});
ds_map_add(global.keyboardIcons, vk_numpad7,		{iconSprite : spr_keyboard_icons_medium,	imgIndex : 19});
ds_map_add(global.keyboardIcons, vk_numpad8,		{iconSprite : spr_keyboard_icons_medium,	imgIndex : 20});
ds_map_add(global.keyboardIcons, vk_numpad9,		{iconSprite : spr_keyboard_icons_medium,	imgIndex : 21});
ds_map_add(global.keyboardIcons, vk_multiply,		{iconSprite : spr_keyboard_icons_small,		imgIndex : 41});
ds_map_add(global.keyboardIcons, vk_add,			{iconSprite : spr_keyboard_icons_small,		imgIndex : 38});
ds_map_add(global.keyboardIcons, vk_subtract,		{iconSprite : spr_keyboard_icons_small,		imgIndex : 37});
ds_map_add(global.keyboardIcons, vk_decimal,		{iconSprite : spr_keyboard_icons_small,		imgIndex : 31});
ds_map_add(global.keyboardIcons, vk_divide,			{iconSprite : spr_keyboard_icons_small,		imgIndex : 32});
ds_map_add(global.keyboardIcons, vk_f1,				{iconSprite : spr_keyboard_icons_medium,	imgIndex : 0});
ds_map_add(global.keyboardIcons, vk_f2,				{iconSprite : spr_keyboard_icons_medium,	imgIndex : 1});
ds_map_add(global.keyboardIcons, vk_f3,				{iconSprite : spr_keyboard_icons_medium,	imgIndex : 2});
ds_map_add(global.keyboardIcons, vk_f4,				{iconSprite : spr_keyboard_icons_medium,	imgIndex : 3});
ds_map_add(global.keyboardIcons, vk_f5,				{iconSprite : spr_keyboard_icons_medium,	imgIndex : 4});
ds_map_add(global.keyboardIcons, vk_f6,				{iconSprite : spr_keyboard_icons_medium,	imgIndex : 5});
ds_map_add(global.keyboardIcons, vk_f7,				{iconSprite : spr_keyboard_icons_medium,	imgIndex : 6});
ds_map_add(global.keyboardIcons, vk_f8,				{iconSprite : spr_keyboard_icons_medium,	imgIndex : 7});
ds_map_add(global.keyboardIcons, vk_f9,				{iconSprite : spr_keyboard_icons_medium,	imgIndex : 8});
ds_map_add(global.keyboardIcons, vk_f10,			{iconSprite : spr_keyboard_icons_medium,	imgIndex : 9});
ds_map_add(global.keyboardIcons, vk_f11,			{iconSprite : spr_keyboard_icons_medium,	imgIndex : 10});
ds_map_add(global.keyboardIcons, vk_f12,			{iconSprite : spr_keyboard_icons_medium,	imgIndex : 11});
ds_map_add(global.keyboardIcons, vk_numberlock,		{iconSprite : spr_keyboard_icons_large,		imgIndex : 9});
ds_map_add(global.keyboardIcons, vk_scrolllock,		{iconSprite : spr_keyboard_icons_large,		imgIndex : 10});
ds_map_add(global.keyboardIcons, vk_control,		{iconSprite : spr_keyboard_icons_large,		imgIndex : 5});
ds_map_add(global.keyboardIcons, vk_alt,			{iconSprite : spr_keyboard_icons_medium,	imgIndex : 26});
ds_map_add(global.keyboardIcons, vk_semicolon,		{iconSprite : spr_keyboard_icons_small,		imgIndex : 33});
ds_map_add(global.keyboardIcons, vk_equal,			{iconSprite : spr_keyboard_icons_small,		imgIndex : 55});
ds_map_add(global.keyboardIcons, vk_comma,			{iconSprite : spr_keyboard_icons_small,		imgIndex : 30});
ds_map_add(global.keyboardIcons, vk_underscore,		{iconSprite : spr_keyboard_icons_small,		imgIndex : 39});
ds_map_add(global.keyboardIcons, vk_period,			{iconSprite : spr_keyboard_icons_small,		imgIndex : 31});
ds_map_add(global.keyboardIcons, vk_fslash,			{iconSprite : spr_keyboard_icons_small,		imgIndex : 40});
ds_map_add(global.keyboardIcons, vk_backquote,		{iconSprite : spr_keyboard_icons_small,		imgIndex : 42});
ds_map_add(global.keyboardIcons, vk_openbracket,	{iconSprite : spr_keyboard_icons_small,		imgIndex : 34});
ds_map_add(global.keyboardIcons, vk_bslash,			{iconSprite : spr_keyboard_icons_small,		imgIndex : 36});
ds_map_add(global.keyboardIcons, vk_closebracket,	{iconSprite : spr_keyboard_icons_small,		imgIndex : 36});
ds_map_add(global.keyboardIcons, vk_quotation,		{iconSprite : spr_keyboard_icons_small,		imgIndex : 54});

// Since the windows OS can differentiate between both right control and left control, as well as right alt
// and left alt, there needs to be unique use cases for these keys potentially being mapped as inputs; both
// as the default keyboard layout AND through player key rebindings. So, these map indexes are added to
// compensate for that on all Windows PCs.
if (os_type == os_windows){
	ds_map_add(global.keyboardIcons, vk_rcontrol,	{iconSprite : spr_keyboard_icons_xlarge,	imgIndex : 0});
	ds_map_add(global.keyboardIcons, vk_lcontrol,	{iconSprite : spr_keyboard_icons_xlarge,	imgIndex : 1});
	ds_map_add(global.keyboardIcons, vk_ralt,		{iconSprite : spr_keyboard_icons_large,		imgIndex : 12});
	ds_map_add(global.keyboardIcons, vk_lalt,		{iconSprite : spr_keyboard_icons_large,		imgIndex : 13});
}

// 
global.gamepadIcons = ds_map_create();

#endregion


function obj_control_info() constructor{
	// 
	object_index = obj_control_info;
	
	// 
	inputIcons = ds_map_create();
	prevGamepad = Gamepad.None;
	
	// 
	anchorPoint = ds_map_create();
	pointOrder = ds_list_create();
	
	/// @description 
	draw_gui = function(){
		//
		var _x = 0;
		var _y = 0;
		var _icon = -1;
		var _totalInputs = 0;
		var _totalPoints = ds_list_size(pointOrder);
		for (var i = 0; i < _totalPoints; i++){
			with(anchorPoint[? pointOrder[| i]]){
				_x = x;
				_y = y;
				_totalInputs = ds_list_size(info);
				for (var j = 0; j < _totalInputs; j++){
					with(info[| j]){
						_icon = inputIcons[? input];
						draw_sprite_ext(_icon.iconSprite, _icon.imgIndex, _x + iconX, _y + iconY, 1, 1, 0, c_white, 1);
					}
				}
			}
		}
		
		// 
		shader_set_outline(RGB_GRAY, font_gui_small);
		for (var ii = 0; ii < _totalPoints; ii++){
			with(anchorPoint[? pointOrder[| ii]]){
				_x = x;
				_y = y;
				_totalInputs = ds_list_size(info);
				for (var jj = 0; jj < _totalInputs; jj++){
					with(info[| jj]) {draw_text_outline(_x + infoX, _y + infoY, info, HEX_WHITE, RGB_GRAY, 1);}
				}
			}
		}
		shader_reset();
	}
	
	/// @description 
	cleanup = function(){
		//
		var _key = ds_map_find_first(global.keyboardIcons);
		while(!is_undefined(_key)){
			delete global.keyboardIcons[? _key];
			_key = ds_map_find_next(global.keyboardIcons, _key);
		}
		ds_map_destroy(global.keyboardIcons);

		// 
		clear_gamepad_icons();
		ds_map_destroy(global.gamepadIcons);

		// 
		ds_map_destroy(inputIcons);
		
		// 
		clear_anchor_data();
		ds_map_destroy(anchorPoint);
		ds_list_destroy(pointOrder);
	}
	
	/// @description 
	initialize_input_icons = function(){
		if (GAMEPAD_IS_ACTIVE){ // Assigning icons that match the currently active gamepad.
			var _gamepad = GAMEPAD_DEVICE_ID;
			get_gamepad_icons(gamepad_get_description(_gamepad));
			
			ds_map_clear(inputIcons);
			ds_map_add(inputIcons, INPUT_GAME_RIGHT,		global.gamepadIcons[? PAD_GAME_RIGHT]);		// Player movement inputs
			ds_map_add(inputIcons, INPUT_GAME_LEFT,			global.gamepadIcons[? PAD_GAME_LEFT]);
			ds_map_add(inputIcons, INPUT_GAME_UP,			global.gamepadIcons[? PAD_GAME_UP]);
			ds_map_add(inputIcons, INPUT_GAME_DOWN,			global.gamepadIcons[? PAD_GAME_DOWN]);
			ds_map_add(inputIcons, INPUT_RUN,				global.gamepadIcons[? PAD_RUN]);
			
			ds_map_add(inputIcons, INPUT_READY_WEAPON,		global.gamepadIcons[? PAD_READY_WEAPON]);	// Weapon inputs
			ds_map_add(inputIcons, INPUT_USE_WEAPON,		global.gamepadIcons[? PAD_USE_WEAPON]);
			ds_map_add(inputIcons, INPUT_RELOAD_GUN,		global.gamepadIcons[? PAD_RELOAD_GUN]);
			ds_map_add(inputIcons, INPUT_AMMO_SWAP,			global.gamepadIcons[? PAD_AMMO_SWAP]);
			
			ds_map_add(inputIcons, INPUT_INTERACT,			global.gamepadIcons[? PAD_INTERACT]);		// Interaction input
			ds_map_add(inputIcons, INPUT_FLASHLIGHT,		global.gamepadIcons[? PAD_FLASHLIGHT]);		// Flashlight inputs
			ds_map_add(inputIcons, INPUT_LIGHT_SWAP,		global.gamepadIcons[? PAD_LIGHT_SWAP]);
			
			ds_map_add(inputIcons, INPUT_ITEMS,				global.gamepadIcons[? PAD_ITEMS]);			// Menu shortcut inputs
			ds_map_add(inputIcons, INPUT_NOTES,				global.gamepadIcons[? PAD_NOTES]);
			ds_map_add(inputIcons, INPUT_MAPS,				global.gamepadIcons[? PAD_MAPS]);
			ds_map_add(inputIcons, INPUT_PAUSE,				global.gamepadIcons[? PAD_PAUSE]);
			
			ds_map_add(inputIcons, INPUT_MENU_RIGHT,		global.gamepadIcons[? PAD_MENU_RIGHT]);		// Menu cursor inputs
			ds_map_add(inputIcons, INPUT_MENU_LEFT,			global.gamepadIcons[? PAD_MENU_LEFT]);
			ds_map_add(inputIcons, INPUT_MENU_UP,			global.gamepadIcons[? PAD_MENU_UP]);
			ds_map_add(inputIcons, INPUT_MENU_DOWN,			global.gamepadIcons[? PAD_MENU_DOWN]);
			ds_map_add(inputIcons, INPUT_AUX_MENU_RIGHT,	global.gamepadIcons[? PAD_AUX_MENU_RIGHT]);
			ds_map_add(inputIcons, INPUT_AUX_MENU_LEFT,		global.gamepadIcons[? PAD_AUX_MENU_LEFT]);
			
			ds_map_add(inputIcons, INPUT_SELECT,			global.gamepadIcons[? PAD_SELECT]);			// Menu interaction inputs
			ds_map_add(inputIcons, INPUT_RETURN,			global.gamepadIcons[? PAD_RETURN]);
			ds_map_add(inputIcons, INPUT_FILE_DELETE,		global.gamepadIcons[? PAD_FILE_DELETE]);
			
			ds_map_add(inputIcons, INPUT_ADVANCE,			global.gamepadIcons[? PAD_ADVANCE]);		// Textbox inputs
			ds_map_add(inputIcons, INPUT_LOG,				global.gamepadIcons[? PAD_LOG]);
		} else{ // Assigning icons for the default input device: the keyboard.
			ds_map_clear(inputIcons); // Clear out the old struct pointers.
			ds_map_add(inputIcons, INPUT_GAME_RIGHT,		global.keyboardIcons[? KEY_GAME_RIGHT]);	// Player movement inputs
			ds_map_add(inputIcons, INPUT_GAME_LEFT,			global.keyboardIcons[? KEY_GAME_LEFT]);
			ds_map_add(inputIcons, INPUT_GAME_UP,			global.keyboardIcons[? KEY_GAME_UP]);
			ds_map_add(inputIcons, INPUT_GAME_DOWN,			global.keyboardIcons[? KEY_GAME_DOWN]);
			ds_map_add(inputIcons, INPUT_RUN,				global.keyboardIcons[? KEY_RUN]);
															
			ds_map_add(inputIcons, INPUT_READY_WEAPON,		global.keyboardIcons[? KEY_READY_WEAPON]);	// Weapon inputs
			ds_map_add(inputIcons, INPUT_USE_WEAPON,		global.keyboardIcons[? KEY_USE_WEAPON]);
			ds_map_add(inputIcons, INPUT_RELOAD_GUN,		global.keyboardIcons[? KEY_RELOAD_GUN]);
			ds_map_add(inputIcons, INPUT_AMMO_SWAP,			global.keyboardIcons[? KEY_AMMO_SWAP]);
															
			ds_map_add(inputIcons, INPUT_INTERACT,			global.keyboardIcons[? KEY_INTERACT]);		// Interaction input
			ds_map_add(inputIcons, INPUT_FLASHLIGHT,		global.keyboardIcons[? KEY_FLASHLIGHT]);	// Flashlight inputs
			ds_map_add(inputIcons, INPUT_LIGHT_SWAP,		global.keyboardIcons[? KEY_LIGHT_SWAP]);
															
			ds_map_add(inputIcons, INPUT_ITEMS,				global.keyboardIcons[? KEY_ITEMS]);			// Menu shortcut inputs
			ds_map_add(inputIcons, INPUT_NOTES,				global.keyboardIcons[? KEY_NOTES]);
			ds_map_add(inputIcons, INPUT_MAPS,				global.keyboardIcons[? KEY_MAPS]);
			ds_map_add(inputIcons, INPUT_PAUSE,				global.keyboardIcons[? KEY_PAUSE]);
			
			ds_map_add(inputIcons, INPUT_MENU_RIGHT,		global.keyboardIcons[? KEY_MENU_RIGHT]);	// Menu cursor inputs
			ds_map_add(inputIcons, INPUT_MENU_LEFT,			global.keyboardIcons[? KEY_MENU_LEFT]);
			ds_map_add(inputIcons, INPUT_MENU_UP,			global.keyboardIcons[? KEY_MENU_UP]);
			ds_map_add(inputIcons, INPUT_MENU_DOWN,			global.keyboardIcons[? KEY_MENU_DOWN]);
			ds_map_add(inputIcons, INPUT_AUX_MENU_RIGHT,	global.keyboardIcons[? KEY_AUX_MENU_RIGHT]);
			ds_map_add(inputIcons, INPUT_AUX_MENU_LEFT,		global.keyboardIcons[? KEY_AUX_MENU_LEFT]);
			
			ds_map_add(inputIcons, INPUT_SELECT,			global.keyboardIcons[? KEY_SELECT]);		// Menu interaction inputs
			ds_map_add(inputIcons, INPUT_RETURN,			global.keyboardIcons[? KEY_RETURN]);
			ds_map_add(inputIcons, INPUT_FILE_DELETE,		global.keyboardIcons[? KEY_FILE_DELETE]);
			
			ds_map_add(inputIcons, INPUT_ADVANCE,			global.keyboardIcons[? KEY_ADVANCE]);		// Textbox inputs
			ds_map_add(inputIcons, INPUT_LOG,				global.keyboardIcons[? KEY_LOG]);
		}
		
		// 
		var _length = ds_list_size(pointOrder);
		for (var i = 0; i < _length; i++) {set_icon_positions(anchorPoint[? pointOrder[| i]]);}
	}
	
	/// @description 
	/// @param {String}	info
	get_gamepad_icons = function(_info){
		// 
		var _sprite = NO_SPRITE;
		var _gamepad = Gamepad.None;
		switch(_info){
			case XINPUT_GAMEPAD:
				_sprite = spr_xbox_gamepad_icons;
				_gamepad = Gamepad.Xbox;
				break;
			case SONY_DUALSHOCK_FOUR:
			case SONY_DUALSENSE:
				_sprite = spr_dualshock_four_icons;
				_gamepad = Gamepad.PlayStation;
				break;
			default:
				_sprite = spr_xbox_gamepad_icons;
				_gamepad = Gamepad.Generic;
				break;
		}
		
		// 
		if (_gamepad == prevGamepad) {return;}
		clear_gamepad_icons();
		
		// 
		var _index = 0;
		for (var i = gp_face1; i <= gp_padr; i++){
			ds_map_add(global.gamepadIcons,	i,	{iconSprite : _sprite,	imgIndex : _index});
			_index++;
		}
		prevGamepad = _gamepad;
	}
	
	/// @description 
	clear_gamepad_icons = function(){
		var _key = ds_map_find_first(global.gamepadIcons);
		while(!is_undefined(_key)){
			delete global.gamepadIcons[? _key];
			_key = ds_map_find_next(global.gamepadIcons, _key);
		}
		ds_map_clear(global.gamepadIcons);
	}
	
	/// @description
	clear_anchor_data = function(){
		var _totalInputs = 0;
		var _totalPoints = ds_list_size(pointOrder);
		for (var i = 0; i < _totalPoints; i++){
			with(anchorPoint[? pointOrder[| i]]){
				_totalInputs = ds_list_size(info);
				for (var j = 0; j < _totalInputs; j++) {delete info[| i];}
				ds_list_destroy(info);
			}
			delete anchorPoint[? pointOrder[| i]];
		}
		ds_map_clear(anchorPoint);
		ds_list_clear(pointOrder);
	}
	
	/// @description
	/// @param {Struct} anchor
	set_icon_positions = function(_anchor){
		draw_set_font(font_gui_small);
		with(_anchor){
			switch(alignment){
				case ALIGNMENT_LEFT:	calculate_info_offset_horizontal(true);		break;
				case ALIGNMENT_RIGHT:	calculate_info_offset_horizontal(false);	break;
				case ALIGNMENT_UP:		calculate_info_offset_vertical(true);		break;
				case ALIGNMENT_DOWN:	calculate_info_offset_vertical(false);		break;
			}
		}
	}
}


/// @description 
/// @param {String}	name
/// @param {Real}	x
/// @param {Real}	y
/// @param {Real}	alignment
function control_info_create_anchor(_name, _x, _y, _alignment){
	with(CONTROL_INFO){
		if (!is_undefined(anchorPoint[? _name])) {return;}
		
		// 
		ds_map_add(anchorPoint, _name, {
			x :				_x,
			y :				_y,
			alignment :		_alignment,
			info :			ds_list_create(),
			alpha :			0,
			
			/// @description 
			/// @param {Id.DsMap}	inputIcons
			/// @param {Bool}		isLeftAligned
			calculate_info_offset_horizontal : function(_isLeftAligned){
				var _emptyInfo = false;
				var _xOffset = 0;
				var _length = ds_list_size(info);
				for (var i = 0; i < _length; i++){
					with(info[| i]){
						infoY = 2;
						
						// 
						_emptyInfo = (info == "");
						if (_isLeftAligned){
							// 
							iconX = _xOffset;
							_xOffset += sprite_get_width(inputIcons[? input].iconSprite);
							if (!_emptyInfo) {_xOffset += 2;}
							else {_xOffset++;}
							
							// 
							infoX = _xOffset;
							if (!_emptyInfo) {_xOffset += string_width(info) + 3;}
						} else{
							// 
							if (!_emptyInfo) {_xOffset -= string_width(info);}
							infoX = _xOffset;
							_xOffset -= sprite_get_width(inputIcons[? input].iconSprite);
							if (!_emptyInfo) {_xOffset -= 2;}
							else {_xOffset += 2;}
							
							// 
							iconX = _xOffset;
							if (!_emptyInfo) {_xOffset -= 3;}
						}
					}
				}
			},
			
			/// @description 
			/// @param {Id.DsMap}	inputIcons
			/// @param {Bool}		isTopAligned
			calculate_info_offset_vertical : function(_isTopAligned){
				var _yOffset = 0;
				var _length = ds_list_size(info);
				for (var i = 0; i < _length; i++){
					with(info[| i]){
						if (_isTopAligned) {_yOffset -= sprite_get_height(spr_keyboard_icons_small);}
						iconY = _yOffset;
						infoX = sprite_get_width(inputIcons[? input].iconSprite) + 2;
						infoY = iconY + 2;
						if (!_isTopAligned) {_yOffset += sprite_get_height(spr_keyboard_icons_small) + 1;}
						else {_yOffset--;} // Add an addition one pixel spacing between top aligned control info
					}
				}
			}
		});
		ds_list_add(pointOrder, _name);
	}
}

/// @description 
/// @param {String}	anchor
/// @param {Real}	input
/// @param {String}	info
function control_info_add_data(_anchor, _input, _info){
	with(CONTROL_INFO){
		var _data = anchorPoint[? _anchor];
		if (is_undefined(_data)) {return;}
		
		// 
		var _inputIcons = inputIcons;
		ds_list_add(_data.info, {
			inputIcons :	_inputIcons,
			input :			_input,
			iconX :			0,
			iconY :			0,
			info :			_info,
			infoX :			0,
			infoY :			0,
		});
	}
}

/// @description
/// @param {String}	anchor
/// @param {Real}	input
function control_info_remove_data(_anchor, _input){
	with(CONTROL_INFO){
		var _data = anchorPoint[? _anchor];
		if (is_undefined(_anchor)) {return;}
		
		// 
		with(_data){
			var _length = ds_list_size(info);
			for (var i = 0; i < _length; i++){
				if (info[| i].input == _input){
					ds_list_delete(info, i);
					break;
				}
			}
		}
		set_icon_positions(_data);
	}
}

/// @description
/// @param {String} anchor
function control_info_initialize_anchor(_anchor){
	with(CONTROL_INFO){
		var _data = anchorPoint[? _anchor];
		if (!is_undefined(_data)) {set_icon_positions(_data);}
	}
}

/// @description 
function control_info_clear_data(){
	with(CONTROL_INFO){
		if (ds_map_size(anchorPoint) > 0) {clear_anchor_data();}
	}
}

/*#region The main object code for obj_control_info

function obj_control_info() constructor{
	// Much like Game Maker's own object_index variable, this will store the unique ID value provided to this
	// object by Game Maker during runtime; in order to easily use it within a singleton system.
	object_index = obj_control_info;
	
	// Stores either a pointer to the keyboard icon master list, which is initialized in the MASSIVE block of
	// code above OR it stores a map containing image data for all of the input bindings for the currently
	// connected controller. Then, the data within is referenced by the "displayedIcons" list created below
	// and rendered to the screen using said information.
	inputIcons = ds_map_create();
	
	// A list of arrays containing information about what input to display, the optional string to accompany
	// the icon--briefly telling the user what it does, the alignment of the info on the screen, (Either left
	// of right side alignment on the bottom of the screen) and finally the offset positions of the icon and
	// text relative to the alignment setting.
	displayedIcons = ds_list_create();
	// Stores information within the array as follows:
	//			0	=	Input's keycode
	//			1	=	Control's in-game function (As a string to show player next to its icon)
	//			2	=	Alignment
	//			3	=	Icon's x offset
	//			4	=	Info string's x offset
	// NOTE -- The x offset indexes for both the icon and string are automatically filled in when 
	// obj_control_info is set to update the positions for all the control information.
	
	// Variables that are useful for controlling the current alpha level of the control info whenever it is
	// rendered onto the screen. The first variable is simply the current alpha value to use in the rendering
	// process, and the second variable is the current object/struct that is controlling that alpha level.
	alpha = 0;
	curController = noone;
	
	/// @description Code that should be placed into the "Draw GUI" event of whatever object is controlling
	/// obj_control_info. In short, it handles displaying the icons and icon description for each of the
	/// input data found within the "displayedIcons" list.
	draw_gui = function(){
		// Check to make sure there is actually information to be displayed within the event. Otherwise, 
		// don't waste computation time attempting to render nothing/invisible graphics.
		var _length = ds_list_size(displayedIcons);
		if (_length == 0 || alpha == 0) {return;}
		
		// First, all the input icons are displayed, which are the 0th index in each displayed icon data array.
		// Also, since all control information is rendered at the bottom of the screen, the y position for
		// the data is stored in a local variable for use during the text rendering.
		var _yPosition, _spriteInfo;
		_yPosition = CAM_HEIGHT - 12;
		for (var i = 0; i < _length; i++){
			_spriteInfo = inputIcons[? displayedIcons[| i][0]];
			draw_sprite_ext(_spriteInfo.iconSprite, _spriteInfo.imgIndex, displayedIcons[| i][3], _yPosition, 1, 1, 0, c_white, alpha); 
		}
		
		// Finally, set the game to begin rendering with the outline shader, and render all the information
		// text for the icons at the pre-calculated positions. The information string is found at the 1st
		// index of each displayed icon data array.
		shader_set_outline(RGB_GRAY, font_gui_small, true, true);
		for (var j = 0; j < _length; j++){
			draw_text_outline(displayedIcons[| j][4], _yPosition + 1, displayedIcons[| j][1], HEX_WHITE, RGB_GRAY, alpha);
		}
		shader_reset();
	}
	
	/// @description Code that should be placed into the "Cleanup" event of whatever object is controlling
	/// obj_control_info. In short, it will cleanup any data that needs to be freed from memory that isn't 
	/// collected by Game Maker's built-in garbage collection handler.
	cleanup = function(){
		// First, clean up the data containing the sprite index and image index data for all keyboard binding
		// icons. After that, destroy the map they were stored within.
		var _key = ds_map_find_first(global.keyboardIcons);
		while(!is_undefined(_key)){
			delete global.keyboardIcons[? _key];
			_key = ds_map_find_next(global.keyboardIcons, _key);
		}
		ds_map_destroy(global.keyboardIcons);
		
		// Next, clean up all data structures found within the obj_control_info object.
		clear_control_icons();
		ds_map_destroy(inputIcons);
		
		// Finally, delete the map that stores keys pointing to indexes in the "inputIconInfo" map in order
		// to properly display all gamepad icons to the screen.
		ds_list_destroy(displayedIcons);
	}
	
	/// @description A simple function that clears the input icon pointer data from the map storing said info.
	/// After all pointers have been properly disposed of the map will be cleared; returning it to a 0 size
	/// data structure.
	clear_control_icons = function(){
		var _deleteStructs, _key;
		_deleteStructs = global.gamepad.isActive;
		_key = ds_map_find_first(inputIcons);
		while(!is_undefined(_key)){ // Loop through all available control icon data and remove their structs from memory
			if (_deleteStructs) {delete inputIcons[? _key];}
			_key = ds_map_find_next(inputIcons, _key);
		}
		// Finally, clear out all the key/value pairs in the map to fully reset the data structure.
		ds_map_clear(inputIcons);
	}
	
	/// @description A simple function that is responsible for retrieving the correct icon from the correct
	/// sprite for a given support controller that is currently connected and in use by the player. If the
	/// controller is unsupported the function will simply exit with a -1 error state.
	/// @param gamepadInfo
	/// @param button
	get_gamepad_icon = function(_gamepadInfo, _button){
		// First, figure out which sprite group to pull the input icons from depending on what gamepad is
		// currently connected given its guid and gamepad description string.
		var _iconSprite = -1;
		switch(_gamepadInfo){
			case XINPUT_GAMEPAD:		_iconSprite = spr_xbox_gamepad_icons;	break;
			case SONY_DUALSHOCK_FOUR:	_iconSprite = spr_dualshock_four_icons;	break;
			case SONY_DUALSENSE:		_iconSprite = spr_dualshock_four_icons;	break;
			default:					return -1; // Invalid gamepad; return nothing
		}
		
		// After retrieving the correct sprite, loop through all the gamepad input constants to find the
		// matching image within the sprite. A separate counter for the image index needs to be created and
		// incremented manually due to the fact that GML's gamepad constants are ridiculously high values
		// for some reason. Once the button has been found, that image index is stored in that struct's image
		// index variable.
		var _imageIndex = 0;
		for (var i = gp_face1; i <= gp_padr; i++){
			if (i == _button) {return { iconSprite : _iconSprite, imgIndex : _imageIndex};}
			_imageIndex++;
		}
		
		// In the case of an error that could occur by no button being found on the gamepad for the value
		// provided in the "_button" argument space, the error code -1 will be returned instead of the normal
		// struct pointer like in the for loop above.
		return -1;
	}
	
	/// @description A function that automatically calculates the positional offsets for all input icons that
	/// are currently being displayed on the screen at the moment; split into two possible anchor offsets of
	/// the bottom left side and bottom right side of the screen. Optionally, an alightment target can be
	/// sepcified that makes the calculations only occur for icon data that shares the same alignment as the
	/// target provided; speeding up the function when only one anchor group needs to be adjusted.
	/// @param targetAlignment
	calculate_control_display_positions = function(_targetAlignment = -1){
		// Store the previous font before onverwriting it so that it can be restored in the event that the
		// font needed to perform the calculations in the code below is different from the one currently being
		// used to render some text to the screen. Otherwise, the texel sizes for the outline shader may be
		// inaccurate and cause rendering issues.
		var _previousFont = draw_get_font();
		draw_set_font(font_gui_small);
		
		// Set up the local variables used throughout the loop externally in oredr to speed up the execution
		// of the actual loop itself. 
		var _xOffsetRight, _xOffsetLeft, _spriteInfo, _spriteWidth, _stringWidth, _length;
		_xOffsetRight = CAM_WIDTH - 5;
		_xOffsetLeft = 5;
		_length = ds_list_size(displayedIcons);
		for (var i = 0; i < _length; i++){
			// In the event of a specific alignment being targeted for something like a recalculation because
			// a control's info was removed from that specific anchor point, the for loop will be set to
			// ignore any info that is attached to the opposite anchor.
			if (_targetAlignment != -1 && displayedIcons[| i][2] != _targetAlignment) {continue;}
		
			// Grab the pointer to the sprite's information and also store its width which is used in calculating
			// both the positions of the next to-be-rendered right aligned control and also the current offset
			// values for both alignments' next control icons.
			_spriteInfo = inputIcons[? displayedIcons[| i][0]];
			_spriteWidth = sprite_get_width(_spriteInfo.iconSprite);
			if (displayedIcons[| i][2] == ALIGNMENT_RIGHT){ // Right aligned control info needs to have its own width applied to its position in order to preserve left-aligned drawing.
				_stringWidth = displayedIcons[| i][1] == "" ? -2 : string_width(displayedIcons[| i][1]) + 4;
				displayedIcons[| i][3] = _xOffsetRight - _spriteWidth;
				displayedIcons[| i][4] = _xOffsetRight - _spriteWidth - _stringWidth + 2;
				_xOffsetRight -= _spriteWidth + _stringWidth + 2;
			} else{ // Left aligned control info simply needs to be based off the currently offset value; no additional things need to be accounted for, unlike above.
				_stringWidth = displayedIcons[| i][1] == "" ? 1 : string_width(displayedIcons[| i][1]) + 5;
				displayedIcons[| i][3] = _xOffsetLeft;
				displayedIcons[| i][4] = _xOffsetLeft + _spriteWidth + 3;
				_xOffsetLeft += _spriteWidth + _stringWidth + 1;
			}
		}
		// After exiting the loop, reset the font back to what it was before this function was called. This
		// prevents any errors specifically with the outline shader, since changing fonts without updating the
		// current texel size could cause rendering errors.
		draw_set_font(_previousFont);
	}
}

#endregion

#region Global functions related to obj_control_info

/// @description A simple, but very ugly, complex and tedious looking function that initializes all the game's
/// inputs to have icon data for use in all GUI-based areas of the game. (Ex. when the textbox is visible,
/// inside of a menu, etc.)
function control_info_set_icons_keyboard(){
	with(CONTROL_INFO){
		// First, make sure to clear out whatever pointer or data was previous found within the "inputIcons"
		// variable. Otherwise, it will turn into a massive memory leaks of pointers to structs being
		// overwritten before they could be properly cleaned up within the code.
		clear_control_icons();
		
		// First, add in the icons for the inputs that allow the user to move the main character around the
		// game world. The final of the five inputs isn't a movement input, but an input that allows them to
		// begin running/jogging instead of walking.
		ds_map_add(inputIcons, INPUT_GAME_RIGHT,		ds_map_find_value(global.keyboardIcons, global.settings.keyGameRight));
		ds_map_add(inputIcons, INPUT_GAME_LEFT,			ds_map_find_value(global.keyboardIcons, global.settings.keyGameLeft));
		ds_map_add(inputIcons, INPUT_GAME_UP,			ds_map_find_value(global.keyboardIcons, global.settings.keyGameUp));
		ds_map_add(inputIcons, INPUT_GAME_DOWN,			ds_map_find_value(global.keyboardIcons, global.settings.keyGameDown));
		ds_map_add(inputIcons, INPUT_RUN,				ds_map_find_value(global.keyboardIcons, global.settings.keyRun));
	
		// Add in icon data for the user's inputs that allow them to utilize their equipped weapon; readying
		// if for use, actually using it, reloading it when it consumes ammunition, and finally swapping 
		// between the gun's available ammunition types.
		ds_map_add(inputIcons, INPUT_READY_WEAPON,		ds_map_find_value(global.keyboardIcons, global.settings.keyReadyWeapon));
		ds_map_add(inputIcons, INPUT_USE_WEAPON,		ds_map_find_value(global.keyboardIcons, global.settings.keyUseWeapon));
		ds_map_add(inputIcons, INPUT_RELOAD_GUN,		ds_map_find_value(global.keyboardIcons, global.settings.keyReloadGun));
		ds_map_add(inputIcons, INPUT_AMMO_SWAP,			ds_map_find_value(global.keyboardIcons, global.settings.keyAmmoSwap));
	
		// Add in the icon data for the user's inputs that allow them to interact with objects in the world,
		// toggle their flashlight on and off, and swap their current light being used by the flashlight.
		ds_map_add(inputIcons, INPUT_INTERACT,			ds_map_find_value(global.keyboardIcons, global.settings.keyInteract));
		ds_map_add(inputIcons, INPUT_FLASHLIGHT,		ds_map_find_value(global.keyboardIcons, global.settings.keyFlashlight));
		ds_map_add(inputIcons, INPUT_LIGHT_SWAP,		ds_map_find_value(global.keyboardIcons, global.settings.keyLightSwap));
		
		// Add in the icon data for the user's desired input bindings for opening their inventory's item
		// section, as well as their note and map sections; with the game's pause menu being the last
		// icon to be added in the group.
		ds_map_add(inputIcons, INPUT_ITEMS,				ds_map_find_value(global.keyboardIcons, global.settings.keyItems));
		ds_map_add(inputIcons, INPUT_NOTES,				ds_map_find_value(global.keyboardIcons, global.settings.keyNotes));
		ds_map_add(inputIcons, INPUT_MAPS,				ds_map_find_value(global.keyboardIcons, global.settings.keyMaps));
		ds_map_add(inputIcons, INPUT_PAUSE,				ds_map_find_value(global.keyboardIcons, global.settings.keyPause));
		
		// Add in the icon data for all the current menu cursor input bindings; allowing the user to see
		// how they'll be able to navigate up, down, left, and right through a given menu. The auxiliary
		// inputs for left and right are also added below that.
		ds_map_add(inputIcons, INPUT_MENU_RIGHT,		ds_map_find_value(global.keyboardIcons, global.settings.keyMenuRight));
		ds_map_add(inputIcons, INPUT_MENU_LEFT,			ds_map_find_value(global.keyboardIcons, global.settings.keyMenuLeft));
		ds_map_add(inputIcons, INPUT_MENU_UP,			ds_map_find_value(global.keyboardIcons, global.settings.keyMenuUp));
		ds_map_add(inputIcons, INPUT_MENU_DOWN,			ds_map_find_value(global.keyboardIcons, global.settings.keyMenuDown));
		ds_map_add(inputIcons, INPUT_AUX_MENU_RIGHT,	ds_map_find_value(global.keyboardIcons, global.settings.keyAuxMenuRight));
		ds_map_add(inputIcons, INPUT_AUX_MENU_LEFT,		ds_map_find_value(global.keyboardIcons, global.settings.keyAuxMenuLeft));
		
		// Add in the icon data for the menu's selection/confirmation input, the deselect/denial input, and 
		// the unique "obj_load_game_menu" input for deleting an existing save file from a given save slot.
		ds_map_add(inputIcons, INPUT_SELECT,			ds_map_find_value(global.keyboardIcons, global.settings.keySelect));
		ds_map_add(inputIcons, INPUT_RETURN,			ds_map_find_value(global.keyboardIcons, global.settings.keyReturn));
		ds_map_add(inputIcons, INPUT_FILE_DELETE,		ds_map_find_value(global.keyboardIcons, global.settings.keyFileDelete));
		
		// Finally, add in the icon data for the "advance" and "log" inputs that are unique to 
		// "obj_textbox_handler" for advancing the textbox and checking the log of current dialogue,
		// respectively.
		ds_map_add(inputIcons, INPUT_ADVANCE,			ds_map_find_value(global.keyboardIcons, global.settings.keyAdvance));
		ds_map_add(inputIcons, INPUT_LOG,				ds_map_find_value(global.keyboardIcons, global.settings.keyLog));
		
		// In case there is already visible icons on the screen, they'll need to be updated in order to match
		// the keyboard's icons and their differing possible dimensions. (They can be a width of 10, 16, 20, 
		// and 22, respectively) Otherwise, there will be overlap between the icons and text.
		if (ds_list_size(displayedIcons) > 0) {calculate_control_display_positions();}
	}
}

/// @description This function works exactly like how the one above for the keyboard icons does, but with
/// the currently connected controller's icons instead of the keyboard icons. These icons all serve the same
/// purpose and functions as the keyboard icons.
/// @param info
function control_info_set_icons_gamepad(_info){
	with(CONTROL_INFO){
		// First, make sure to clear out whatever pointer or data was previous found within the "inputIcons"
		// variable. Otherwise, it will turn into a massive memory leaks of pointers to structs being
		// overwritten before they could be properly cleaned up within the code.
		clear_control_icons();
		
		// First, add in the icons for the inputs that allow the user to move the main character around the
		// game world. The final of the five inputs isn't a movement input, but an input that allows them to
		// begin running/jogging instead of walking.
		ds_map_add(inputIcons, INPUT_GAME_RIGHT,		get_gamepad_icon(_info, global.settings.gpadGameRight));
		ds_map_add(inputIcons, INPUT_GAME_LEFT,			get_gamepad_icon(_info, global.settings.gpadGameLeft));
		ds_map_add(inputIcons, INPUT_GAME_UP,			get_gamepad_icon(_info, global.settings.gpadGameUp));
		ds_map_add(inputIcons, INPUT_GAME_DOWN,			get_gamepad_icon(_info, global.settings.gpadGameDown));
		ds_map_add(inputIcons, INPUT_RUN,				get_gamepad_icon(_info, global.settings.gpadRun));
	
		// Add in icon data for the user's inputs that allow them to utilize their equipped weapon; readying
		// if for use, actually using it, reloading it when it consumes ammunition, and finally swapping 
		// between the gun's available ammunition types.
		ds_map_add(inputIcons, INPUT_READY_WEAPON,		get_gamepad_icon(_info, global.settings.gpadReadyWeapon));
		ds_map_add(inputIcons, INPUT_USE_WEAPON,		get_gamepad_icon(_info, global.settings.gpadUseWeapon));
		ds_map_add(inputIcons, INPUT_RELOAD_GUN,		get_gamepad_icon(_info, global.settings.gpadReloadGun));
		ds_map_add(inputIcons, INPUT_AMMO_SWAP,			get_gamepad_icon(_info, global.settings.gpadAmmoSwap));
	
		// Add in the icon data for the user's inputs that allow them to interact with objects in the world,
		// toggle their flashlight on and off, and swap their current light being used by the flashlight.
		ds_map_add(inputIcons, INPUT_INTERACT,			get_gamepad_icon(_info, global.settings.gpadInteract));
		ds_map_add(inputIcons, INPUT_FLASHLIGHT,		get_gamepad_icon(_info, global.settings.gpadFlashlight));
		ds_map_add(inputIcons, INPUT_LIGHT_SWAP,		get_gamepad_icon(_info, global.settings.gpadLightSwap));
		
		// Add in the icon data for the user's desired input bindings for opening their inventory's item
		// section, as well as their note and map sections; with the game's pause menu being the last
		// icon to be added in the group.
		ds_map_add(inputIcons, INPUT_ITEMS,				get_gamepad_icon(_info, global.settings.gpadItems));
		ds_map_add(inputIcons, INPUT_NOTES,				get_gamepad_icon(_info, global.settings.gpadNotes));
		ds_map_add(inputIcons, INPUT_MAPS,				get_gamepad_icon(_info, global.settings.gpadMaps));
		ds_map_add(inputIcons, INPUT_PAUSE,				get_gamepad_icon(_info, global.settings.gpadPause));
		
		// Add in the icon data for all the current menu cursor input bindings; allowing the user to see
		// how they'll be able to navigate up, down, left, and right through a given menu. The auxiliary
		// inputs for left and right are also added below that.
		ds_map_add(inputIcons, INPUT_MENU_RIGHT,		get_gamepad_icon(_info, global.settings.gpadMenuRight));
		ds_map_add(inputIcons, INPUT_MENU_LEFT,			get_gamepad_icon(_info, global.settings.gpadMenuLeft));
		ds_map_add(inputIcons, INPUT_MENU_UP,			get_gamepad_icon(_info, global.settings.gpadMenuUp));
		ds_map_add(inputIcons, INPUT_MENU_DOWN,			get_gamepad_icon(_info, global.settings.gpadMenuDown));
		ds_map_add(inputIcons, INPUT_AUX_MENU_RIGHT,	get_gamepad_icon(_info, global.settings.gpadAuxMenuRight));
		ds_map_add(inputIcons, INPUT_AUX_MENU_LEFT,		get_gamepad_icon(_info, global.settings.gpadAuxMenuLeft));
		
		// Add in the icon data for the menu's selection/confirmation input, the deselect/denial input, and 
		// the unique "obj_load_game_menu" input for deleting an existing save file from a given save slot.
		ds_map_add(inputIcons, INPUT_SELECT,			get_gamepad_icon(_info, global.settings.gpadSelect));
		ds_map_add(inputIcons, INPUT_RETURN,			get_gamepad_icon(_info, global.settings.gpadReturn));
		ds_map_add(inputIcons, INPUT_FILE_DELETE,		get_gamepad_icon(_info, global.settings.gpadFileDelete));
		
		// Finally, add in the icon data for the "advance" and "log" inputs that are unique to 
		// "obj_textbox_handler" for advancing the textbox and checking the log of current dialogue,
		// respectively.
		ds_map_add(inputIcons, INPUT_ADVANCE,			get_gamepad_icon(_info, global.settings.gpadAdvance));
		ds_map_add(inputIcons, INPUT_LOG,				get_gamepad_icon(_info, global.settings.gpadLog));
	
		// Much like how the offset positions for all control information is updated for keyboard icons being
		// initialized, the controller icons need to do the same, but only because the icons for controllers
		// are all 11 by 11 and that doesn't match up with any of the keyboard icon image widths.
		if (ds_list_size(displayedIcons) > 0) {calculate_control_display_positions();}
	}
}

/// @description A simple function that adds new displayable control information to the list of rendered
/// control input information. Depending on if a gamepad is connected or not, the icons will be set to the
/// correct images for said input (Ex. keyboard will be key icons, xbox controller will be xbox buttons, etc.)
/// @param input
/// @param infoString
/// @param alignment
function control_info_add_displayed_icon(_input, _infoString, _alignment, _calculatePositions = false){
	with(CONTROL_INFO){
		if (ds_map_find_value(inputIcons, _input) != undefined && is_string(_infoString)){ // Only add valid icons to the display
			ds_list_add(displayedIcons, [_input, _infoString, _alignment, 0, 0]);
			// If the final argument is set to true, (Should only be the case for the last icon in the
			// list that sets it to true for efficiency purposes) the positioning for all the control
			// information will be calculated automatically by the function.
			if (_calculatePositions) {calculate_control_display_positions();}
		}
	}
}

/// @description Edits the information stored within the given index of the currently displayed icons list.
/// Allows for easy swapping of data without having to keep track of where other indexes are translated to
/// if this index had to be deleted instead of having this function to simply alter the data without any
/// deletion occuring for the list.
/// @param index
/// @param input
/// @param infoString
/// @param alignment
function control_info_edit_displayed_icon(_index, _input, _infoString, _alignment){
	with(CONTROL_INFO){
		// First, make sure that the index provided is within the valid range of indexes for the list of
		// displayed icons. If not, the function will not perform any logic. However, if a value less 
		// than 0 is provided to the function's index parameter, the function will use the most recently 
		// added icon data and place the provided information there; replacing whatever was stored there
		// previously.
		if (_index >= ds_list_size(displayedIcons)) {return;}
		else if (_index < 0) {_index = ds_list_size(displayedIcons) - 1;}
		
		// Edit the information found at each of the three indexes of the array stored in the list at the
		// given list index value only if values of "-1" weren't placed in any of the argument parameters.
		// Otherwise, the piece of data will be skipped over in this editing process.
		if (_input != -1 && ds_map_find_value(inputIcons, _input) != undefined)	{displayedIcons[| _index][0] = _input;}
		if (_infoString != -1 && is_string(_infoString))						{displayedIcons[| _index][1] = _infoString;}
		if (_alignment != -1)													{displayedIcons[| _index][2] = _alignment;}
		
		// Finally, recalculate the display positions of all the displayed control information in case the
		// input's icon is a different width, the string is a different width, or the icon's alignment was
		// altered.
		calculate_control_display_positions();
	}
}

/// @description A simple function that deletes a displayed icon and its information from the displayedIcons
/// list; removing it from the rendering pipeline when this struct has its Draw GUI called. It automatically
/// repositions any icons and information that sat further from their respective anchor than the deleted icon.
/// @param index
function control_info_remove_displayed_icon(_index){
	with(CONTROL_INFO){
		// First, check to see if the index that was provided it out of the valid boundaries of the list. Also,
		// don't let the code delete an index from the list that doesn't actually exist. (AKA the size is 0)
		var _length = ds_list_size(displayedIcons);
		if (_length == 0 || _index < 0 || _index >= _length) {return;}
		
		// If a valid index was provided, store the alignment that the control information was locked onto,
		// and recalculate any control icons that succede the deleted index.
		var _alignment = displayedIcons[| _index][2];
		ds_list_delete(displayedIcons, _index);
		calculate_control_display_positions(_alignment);
	}
}

/// @description A simple function that clears out the current list of displayed icon data and all of its
/// information within the array. Otherwise, there wouldn't be an easy way of cleaning old information out
/// of the object when changing menus, or vice versa.
function control_info_clear_displayed_icons(){
	with(CONTROL_INFO) {ds_list_clear(displayedIcons);}
}

#endregion