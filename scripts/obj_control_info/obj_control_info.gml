/// @description A script file containing all the code and logic for the game's control information display.

#region Initializing any macros that are useful/related to obj_control_info

// Macros that store the values for determining how an anchor's control info elements are alignment to its
// position on the screen.
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

// Stores all of the gamepad's icons in a global map, so they can be properly cleaned from memory (And also so
// any duplicate structs can be replaced by pointers in the "inputIcons" map) when the information is no
// longer needed by the control info object.
global.gamepadIcons = ds_map_create();

#endregion

#region The main object code for obj_control_info

function obj_control_info() constructor{
	// Much like Game Maker's own object_index variable, this will store the unique ID value provided to this
	// object by Game Maker during runtime; in order to easily use it within a singleton system.
	object_index = obj_control_info;
	
	// Variables that handle the current opacity of all control information being displayed on the screen.
	// The alpha value will automatically update its value by the modfier value until it equals the target
	// value. This is done in the "step" event of this object.
	alpha = 0;
	alphaTarget = 0;
	alphaModifier = 0;
	
	// Stores all of the currently used icons for the game's current input bindings and the player's currently
	// active control input method (Can be keyboard or their gamepad, if it's supported).
	inputIcons = ds_map_create();
	prevGamepad = Gamepad.None;
	
	// Stores each of the anchor points, which each have a unique position and alignment. The control data
	// that is attached to each anchor is stored in a list within said anchor struct, and the order of these
	// anchors in the map are stored in a seperate list in order to have quick processing during rendering.
	anchorPoint = ds_map_create();
	pointOrder = ds_list_create();
	
	/// @description Code that should be placed into the "Step" event of whatever object is controlling
	/// obj_control_info. In short, it updates the alpha value by its modifier value to match the current 
	/// target value.
	step = function(){
		alpha = value_set_linear(alpha, alphaTarget, alphaModifier);
	}
	
	/// @description Code that should be placed into the "Draw GUI" event of whatever object is controlling
	/// obj_control_info. In short, it will handle rendering all of the control information at the positions
	/// calculated for said information on the game's screen; above all other GUI information.
	draw_gui = function(){
		if (alpha == 0) {return;}
		var _alpha = alpha; // Store in a local variable for use in anchor info structs.
		
		// First, the icons are rendered. The local "_x" and "_y" variables are used in order to pass the anchor's
		// position into the info struct, which the calculated offset positions are then added onto to get the
		// proper positions on screen. Each anchor's info list is looped through to render all existing icons.
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
						draw_sprite_ext(_icon.iconSprite, _icon.imgIndex, _x + iconX, _y + iconY, 1, 1, 0, c_white, _alpha);
					}
				}
			}
		}
		
		// Finally, the information text that is paired with the icon data that was previously rendered is
		// drawn. It uses another loop because of the shader the is required for the text; saving time that
		// would be used constantly setting and resetting the shader in order to prevent the icon from being
		// outlined like the text is. With this method, the shader is only ever set once for the entire loop.
		shader_set_outline(font_gui_small, RGB_GRAY);
		for (var ii = 0; ii < _totalPoints; ii++){
			with(anchorPoint[? pointOrder[| ii]]){
				_x = x;
				_y = y;
				_totalInputs = ds_list_size(info);
				for (var jj = 0; jj < _totalInputs; jj++){
					with(info[| jj]) {draw_text_outline(_x + infoX, _y + infoY, info, HEX_WHITE, RGB_GRAY, _alpha);}
				}
			}
		}
		shader_reset();
	}
	
	/// @description Cleans up any systems and variables that could potentially cause memory leaks if left
	/// unhandled while the game is still running. (Game Maker cleans it all up at the end of runtime by
	/// default, so it doesn't matter as much in that case)
	cleanup = function(){
		// Clean up all the structs that were created for each supported key on a keyboard. Then, destroy the
		// map that stored all those struct to free it from memory as well.
		var _key = ds_map_find_first(global.keyboardIcons);
		while(!is_undefined(_key)){
			delete global.keyboardIcons[? _key];
			_key = ds_map_find_next(global.keyboardIcons, _key);
		}
		ds_map_destroy(global.keyboardIcons);

		// Much like above, the gamepad icon map will be cleared of any existing structs. Then, the map for
		// storing said data is destroyed to free that memory.
		clear_gamepad_icons();
		ds_map_destroy(global.gamepadIcons);

		// Destroy the map that stores all the icons that are tied to control inputs that are able to be
		// rendered if any currently active anchor has active control information to render.
		ds_map_destroy(inputIcons);
		
		// Finally, clear all anchor structs from memory before the map that stored said data is destroyed
		// from memory. Also, the list that stores the order of those anchors for quick map processing is
		// cleared from memory.
		clear_anchor_data();
		ds_map_destroy(anchorPoint);
		ds_list_destroy(pointOrder);
	}
	
	/// @description Initializes the icons that will be shown for each of the game's inputs. If a gamepad is
	/// currently active, the icon data will be pulled from the "global.gamepadIcons" ds_map, and if there
	/// isn't a gamepad active, the keyboard icons stored in the "global.keyboardIcons" will be used instead.
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
			ds_map_add(inputIcons, INPUT_GAME_RIGHT,		global.keyboardIcons[? game_get_input_binding(KEY_GAME_RIGHT)]);	// Player movement inputs
			ds_map_add(inputIcons, INPUT_GAME_LEFT,			global.keyboardIcons[? game_get_input_binding(KEY_GAME_LEFT)]);
			ds_map_add(inputIcons, INPUT_GAME_UP,			global.keyboardIcons[? game_get_input_binding(KEY_GAME_UP)]);
			ds_map_add(inputIcons, INPUT_GAME_DOWN,			global.keyboardIcons[? game_get_input_binding(KEY_GAME_DOWN)]);
			ds_map_add(inputIcons, INPUT_RUN,				global.keyboardIcons[? game_get_input_binding(KEY_RUN)]);
															
			ds_map_add(inputIcons, INPUT_READY_WEAPON,		global.keyboardIcons[? game_get_input_binding(KEY_READY_WEAPON)]);	// Weapon inputs
			ds_map_add(inputIcons, INPUT_USE_WEAPON,		global.keyboardIcons[? game_get_input_binding(KEY_USE_WEAPON)]);
			ds_map_add(inputIcons, INPUT_RELOAD_GUN,		global.keyboardIcons[? game_get_input_binding(KEY_RELOAD)]);
			ds_map_add(inputIcons, INPUT_AMMO_SWAP,			global.keyboardIcons[? game_get_input_binding(KEY_AMMO_SWAP)]);
															
			ds_map_add(inputIcons, INPUT_INTERACT,			global.keyboardIcons[? game_get_input_binding(KEY_INTERACT)]);		// Interaction input
			ds_map_add(inputIcons, INPUT_FLASHLIGHT,		global.keyboardIcons[? game_get_input_binding(KEY_FLASHLIGHT)]);	// Flashlight inputs
			ds_map_add(inputIcons, INPUT_LIGHT_SWAP,		global.keyboardIcons[? game_get_input_binding(KEY_LIGHT_SWAP)]);
															
			ds_map_add(inputIcons, INPUT_ITEMS,				global.keyboardIcons[? game_get_input_binding(KEY_ITEMS)]);			// Menu shortcut inputs
			ds_map_add(inputIcons, INPUT_NOTES,				global.keyboardIcons[? game_get_input_binding(KEY_NOTES)]);
			ds_map_add(inputIcons, INPUT_MAPS,				global.keyboardIcons[? game_get_input_binding(KEY_MAPS)]);
			ds_map_add(inputIcons, INPUT_PAUSE,				global.keyboardIcons[? game_get_input_binding(KEY_PAUSE)]);
			
			ds_map_add(inputIcons, INPUT_MENU_RIGHT,		global.keyboardIcons[? game_get_input_binding(KEY_MENU_RIGHT)]);	// Menu cursor inputs
			ds_map_add(inputIcons, INPUT_MENU_LEFT,			global.keyboardIcons[? game_get_input_binding(KEY_MENU_LEFT)]);
			ds_map_add(inputIcons, INPUT_MENU_UP,			global.keyboardIcons[? game_get_input_binding(KEY_MENU_UP)]);
			ds_map_add(inputIcons, INPUT_MENU_DOWN,			global.keyboardIcons[? game_get_input_binding(KEY_MENU_DOWN)]);
			ds_map_add(inputIcons, INPUT_AUX_MENU_RIGHT,	global.keyboardIcons[? game_get_input_binding(KEY_AUX_MENU_RIGHT)]);
			ds_map_add(inputIcons, INPUT_AUX_MENU_LEFT,		global.keyboardIcons[? game_get_input_binding(KEY_AUX_MENU_LEFT)]);
			
			ds_map_add(inputIcons, INPUT_SELECT,			global.keyboardIcons[? game_get_input_binding(KEY_SELECT)]);		// Menu interaction inputs
			ds_map_add(inputIcons, INPUT_RETURN,			global.keyboardIcons[? game_get_input_binding(KEY_RETURN)]);
			ds_map_add(inputIcons, INPUT_FILE_DELETE,		global.keyboardIcons[? game_get_input_binding(KEY_FILE_DELETE)]);
			
			ds_map_add(inputIcons, INPUT_ADVANCE,			global.keyboardIcons[? game_get_input_binding(KEY_ADVANCE)]);		// Textbox inputs
			ds_map_add(inputIcons, INPUT_LOG,				global.keyboardIcons[? game_get_input_binding(KEY_LOG)]);
		}
		
		// Once the valid input icon data have all been added to the "inputIcons" map, it will then be used to
		// determine the offset positions of all existing anchors' icon information.
		var _length = ds_list_size(pointOrder);
		for (var i = 0; i < _length; i++) {set_icon_positions(anchorPoint[? pointOrder[| i]]);}
	}
	
	/// @description Fills the "global.gamepadIcons" ds_map with control icons that match the currently 
	/// connected gamepad. The gamepad icons won't be refreshed if the same type of gamepad was connected
	/// and activated by the player.
	/// @param {String}	info
	get_gamepad_icons = function(_info){
		// Determine what sprite to use for the gamepad and what kind of gamepad it is through the use of
		// this switch statement. Unsupported controllers will simply use xbox controller icons as a default.
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
		
		// If the gamepad that is requesting its icons shakes the same icons as the previously connected
		// gamepad, no updating of icon data will be performed and the function will exit prematurely.
		if (_gamepad == prevGamepad) {return;}
		clear_gamepad_icons();
		
		// Loop through all gamepad input constants and create a struct containing the image index and sprite
		// for the gamepad that is currently connected. Store the value of the gamepad that is connected after
		// to prevent unnecessary refreshing of any data.
		var _index = 0;
		for (var i = gp_face1; i <= gp_padr; i++){
			ds_map_add(global.gamepadIcons,	i,	{iconSprite : _sprite,	imgIndex : _index});
			_index++;
		}
		prevGamepad = _gamepad;
	}
	
	/// @description Clears out all the icon structs found within the "global.gamepadIcons" variable from 
	/// memory before removing all key/value pairs from the list; leaving a now empty map to fill with new
	/// icon data whenever required.
	clear_gamepad_icons = function(){
		var _key = ds_map_find_first(global.gamepadIcons);
		while(!is_undefined(_key)){
			delete global.gamepadIcons[? _key];
			_key = ds_map_find_next(global.gamepadIcons, _key);
		}
		ds_map_clear(global.gamepadIcons);
	}
	
	/// @description Completely clears out all structs and allocated memory from all currently existing
	/// anchors. After the memory has been properly managed, the map storing the anchors and the list storing
	/// the order of said anchors are cleared of their now undefined data.
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
	
	/// @description Sets the position offsets for the currently available icons stored within the provided
	/// anchor struct. Depending on the alignment, the relevant function will be called (With the required
	/// argument settings) from the switch statement that makes up this function.
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

#endregion

#region Global functions related to obj_control_info

/// @description Creates and stores a new anchor object that will be able to store control information data
/// that is properly aligned on the screen relative to the alignment setting and position of the anchor. If
/// there is already an anchor that shares the same name as the one set for creation in the arguments, no new
/// anchor will be created and the function will return before processing anything.
/// @param {String}	name
/// @param {Real}	x
/// @param {Real}	y
/// @param {Real}	alignment
function control_info_create_anchor(_name, _x, _y, _alignment){
	with(CONTROL_INFO){
		if (!is_undefined(anchorPoint[? _name])) {return;}
		
		// Create the struct that will hold the position, alignment, opacity, and the input information linked 
		// to said anchor. On top of that, the two functions for calculating the positional offsets for info
		// aligned either horizontally or vertically (Relative to the alignment method used for the anchro)
		// are found within an anchor struct.
		ds_map_add(anchorPoint, _name, {
			x :				_x,
			y :				_y,
			alignment :		_alignment,
			info :			ds_list_create(),
			
			/// @description Calculates the offset positions for the elements found for an anchor that is
			/// aligned horizontally (Either using "ALIGNMENT_RIGHT" or "ALIGNMENT_LEFT", respectively).
			/// @param {Id.DsMap}	inputIcons
			/// @param {Bool}		isLeftAligned
			calculate_info_offset_horizontal : function(_isLeftAligned){
				var _emptyInfo = false;
				var _xOffset = 0;
				var _length = ds_list_size(info);
				for (var i = 0; i < _length; i++){
					with(info[| i]){
						infoY = 2;
						
						// The bool "_emptyInfo" will determine how the spacing between the control icon info
						// is calculated. If there is info text to display, the spacing in pixels will be
						// larger than if there isn't text.
						_emptyInfo = (info == "");
						if (_isLeftAligned){
							// First, determine the offset of the control icon, and then add the width of the
							// sprite to the offset, which is where the info text will be positioned.
							iconX = _xOffset;
							_xOffset += sprite_get_width(inputIcons[? input].iconSprite);
							if (!_emptyInfo) {_xOffset += 2;}
							else {_xOffset++;}
							
							// Then, set the offset for the icon after the icon position has been set. Add
							// the width of the info text if there is actual info text for the input, but don't
							// add anything, otherwise.
							infoX = _xOffset;
							if (!_emptyInfo) {_xOffset += string_width(info) + 3;}
						} else{
							// First, info text needs to be processed; unlike the left aligned info which is
							// icon -> info. So, the offset of the info text is added to the offset (If there
							// is any info text to display) and then the text's offset is set to that value.
							if (!_emptyInfo) {_xOffset -= string_width(info);}
							infoX = _xOffset;
							
							// After the info position is processed, the icon is positioned; with its offset
							// taking into account the width of the sprite. An additional 2 pixels are added
							// and then another 3 after the icon position is set are added when the info text
							// isn't an empty string. 
							_xOffset -= sprite_get_width(inputIcons[? input].iconSprite);
							if (!_emptyInfo) {_xOffset -= 2;}
							else {_xOffset += 2;}
							iconX = _xOffset;
							if (!_emptyInfo) {_xOffset -= 3;}
						}
					}
				}
			},
			
			/// @description Calculating the offsets for any vertically aligned anchor data. Unlike the 
			/// hoizontally-aligned anchors, the offsets only need to take into account the height of the icon
			/// sprite; with the info being offset by the width of said icon as well.
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
						else {_yOffset--;} // Add an addition one pixel spacing between top-aligned control info.
					}
				}
			}
		});
		ds_list_add(pointOrder, _name);
	}
}

/// @description Adds control information for the provided input to the desired anchor. This information will
/// store the positional offsets for both the input icon and its accompanying information, as well as the index
/// for the control info's "inputIcons" ds_list for quick access during rendering.
/// @param {String}	anchor
/// @param {Real}	input
/// @param {String}	info
function control_info_add_data(_anchor, _input, _info){
	with(CONTROL_INFO){
		var _data = anchorPoint[? _anchor];
		if (is_undefined(_data)) {return;}

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

/// @description Assigns new input data to replace another input. It will search through the anchor provided
/// to find the input, so if the input is found on another anchor, the function won't be able to find the it.
/// @param {String}	anchor
/// @param {Real}	input
/// @param {Real}	newInput
/// @param {String}	newInfo
function control_info_edit_data(_anchor, _input, _newInput, _newInfo){
	with(CONTROL_INFO){
		var _data = anchorPoint[? _anchor];
		if (is_undefined(_data)) {return;}
	
		// Jump into scope of the supplied anchor in order to search for and replace the input data with the 
		// newly with what was previously found inside the struct (If that input can be found). Then, calculate 
		// the position offsets to reflect the new change in input and info.
		with(_data){
			var _length = ds_list_size(info);
			for (var i = 0; i < _length; i++){
				if (info[| i].input == _input){
					info[| i].input = _newInput;
					info[| i].info = _newInfo;
					break;
				}
			}
		}
		set_icon_positions(_data)
	}
}

/// @description Removes an input from the currently displayed control information. It doesn't require knowing 
/// the exact index in the list that said info is stored at; just the input that should be deleted and the 
/// anchor to search through.
/// @param {String}	anchor
/// @param {Real}	input
function control_info_remove_data(_anchor, _input){
	with(CONTROL_INFO){
		var _data = anchorPoint[? _anchor];
		if (is_undefined(_anchor)) {return;}
		
		// Jump into scope of the anchor specified in order to search through the icon data found in the 
		// anchor struct. If the input is found, it will delete the data from the list and then update the 
		// icon positions of other information accordingly.
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

/// @description Initializes the positional offsets of the icon's and their respective info text for the 
/// anchor specified by the paramater in the function call.
/// @param {String}	anchor
function control_info_initialize_anchor(_anchor){
	with(CONTROL_INFO){
		var _data = anchorPoint[? _anchor];
		if (!is_undefined(_data)) {set_icon_positions(_data);}
	}
}

/// @description 
/// @param anchor
function control_info_clear_anchor(_anchor){
	with(CONTROL_INFO.anchorPoint[? _anchor]){
		var _length = ds_list_size(info);
		for (var i = 0; i < _length; i++) {delete info[| i];}
		ds_list_clear(info);
	}
}

/// @description Clears out all of the anchor data from the control info object.
function control_info_clear_data(){
	with(CONTROL_INFO){
		if (ds_map_size(anchorPoint) > 0) {clear_anchor_data();}
	}
}

/// @description Assigns a new target value for the control info's alpha level. The speed at which this target 
/// value is reached can also be set through this function.
/// @param {Real}	target
/// @param {Real}	modifier
function control_info_set_alpha_target(_target, _modifier){
	with(CONTROL_INFO){
		alphaTarget = _target;
		alphaModifier = _modifier;
	}
}

/// @description Resets all the alpha variables to their default values of zero. Useful for preventing the 
/// alpha from adjusting to an old target value that wasn't cleared.
function control_info_reset_alpha(){
	with(CONTROL_INFO){
		alpha = 0;
		alphaTarget = 0;
		alphaModifier = 0;
	}
}

#endregion