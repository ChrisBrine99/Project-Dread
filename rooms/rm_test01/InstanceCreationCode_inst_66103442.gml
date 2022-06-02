// 
var _keyData = ds_list_create();
ds_list_add(_keyData, 
	[HANDGUN_AMMO, "Test01"],
	[SHOTGUN_SHELLS, "Test02"]
);
set_base_door_data(_keyData, DOOR_DIR_SOUTH, NO_SOUND, NO_SOUND);

// 
set_locked_door_data("The door is *" + RED + 
						"*locked#, and it looks like I'll need *" + YELLOW + 
						"*two# different keys to unlock it...", NO_SOUND, NO_SOUND);

// 
set_warp_data(56, 56, rm_test02);
