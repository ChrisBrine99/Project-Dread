// 
var _keyData = ds_list_create();
ds_list_add(_keyData, 
	[HANDGUN_AMMO, "Test01"],
	[SHOTGUN_SHELLS, "Test02"]
);
set_base_door_data(_keyData, DOOR_DIR_SOUTH, NO_SOUND, NO_SOUND);

// 
var _colorData = [
	[13, 18, HEX_RED, RGB_DARK_RED],
	[49, 51, HEX_LIGHT_YELLOW, RGB_DARK_YELLOW]
];
set_locked_door_data("The door is locked, and it looks like I'll need two different keys to unlock it...", _colorData, NO_SOUND, NO_SOUND);

// 
set_warp_data(56, 56, rm_test02);
