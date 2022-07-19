/// @description Holds additional data that is used by or relevant to the "obj_controller" object.

#region Initializing any macros that are useful/related to obj_controller

// Constants that store the key values for the singleton instance ds_map that keeps track of all the required
// objects like the camera, music/effect handlers, and even the player character itself.
#macro	KEY_CAMERA					"camera"
#macro	KEY_MUSIC_HANDLER			"music_handler"
#macro	KEY_EFFECT_HANDLER			"effect_handler"
#macro	KEY_CUTSCENE_MANAGER		"cutscene_manager"
#macro	KEY_TEXTBOX_HANDLER			"textbox_handler"
#macro	KEY_DEPTH_SORTER			"depth_sorter"
#macro	KEY_CONTROL_INFO			"control_icon"
#macro	KEY_SCREEN_FADE				"screen_fade"
#macro	KEY_WEATHER_RAIN			"weather_rain"
#macro	KEY_WEATHER_FOG				"weather_fog"
#macro	KEY_CONTROLLER				"controller"
#macro	KEY_PLAYER					"player"
#macro	KEY_DEBUGGER				"debugger"
								
// Constants that shrink down the typing needed and overall clutter caused by having to reference any of the
// game's singleton objects. If any of these objects are destroyed, the game should close in order to prevent
// crashes or oddities from occuring.
#macro	CAMERA						global.sInstances[? KEY_CAMERA]
#macro	MUSIC_HANDLER				global.sInstances[? KEY_MUSIC_HANDLER]
#macro	EFFECT_HANDLER				global.sInstances[? KEY_EFFECT_HANDLER]
#macro	CUTSCENE_MANAGER			global.sInstances[? KEY_CUTSCENE_MANAGER]
#macro	TEXTBOX_HANDLER				global.sInstances[? KEY_TEXTBOX_HANDLER]
#macro	DEPTH_SORTER				global.sInstances[? KEY_DEPTH_SORTER]
#macro	CONTROL_INFO				global.sInstances[? KEY_CONTROL_INFO]
#macro	SCREEN_FADE					global.sInstances[? KEY_SCREEN_FADE]
#macro	WEATHER_RAIN				global.sInstances[? KEY_WEATHER_RAIN]
#macro	WEATHER_FOG					global.sInstances[? KEY_WEATHER_FOG]
#macro	CONTROLLER					global.sInstances[? KEY_CONTROLLER]
#macro	PLAYER						global.sInstances[? KEY_PLAYER]
#macro	DEBUGGER					global.sInstances[? KEY_DEBUGGER]

#endregion

#region Initializing enumerators that are useful/related to obj_controller
#endregion

#region Initializing any globals that are useful/related to obj_controller

// A map containing the instance ID values and pointers for all the global structs and objects within the 
// game. The structs are all created right after the map is initialized, and they aren't removed from memory
// until the game closes. In the "rm_init" function, the controller and player objects are instantiated and
// added to this map as well; as they are also both singletons.
global.sInstances = ds_map_create();
ds_map_add(global.sInstances, KEY_CAMERA,			new obj_camera());
ds_map_add(global.sInstances, KEY_MUSIC_HANDLER,	new obj_music_handler());
ds_map_add(global.sInstances, KEY_EFFECT_HANDLER,	new obj_effect_handler());
ds_map_add(global.sInstances, KEY_CUTSCENE_MANAGER,	new obj_cutscene_manager());
ds_map_add(global.sInstances, KEY_TEXTBOX_HANDLER,	new obj_textbox_handler());
ds_map_add(global.sInstances, KEY_DEPTH_SORTER,		new obj_depth_sorter());
ds_map_add(global.sInstances, KEY_CONTROL_INFO,		new obj_control_info());
ds_map_add(global.sInstances, KEY_SCREEN_FADE,		noone); // Doesn't start occupied like other singletons.
ds_map_add(global.sInstances, KEY_WEATHER_RAIN,		noone); // Doesn't start occupied like other singletons.
ds_map_add(global.sInstances, KEY_WEATHER_FOG,		noone); // Doesn't start occupied like other singletons.
ds_map_add(global.sInstances, KEY_DEBUGGER,			new obj_debugger());	// FOR TESTING

// Stores all the unique ID values for all of the menu structs that have been created and currently exist
// within memory simultaneously; updating, drawing, and processing all other general events that exist within
// each menu--in order from the oldest existing menu instance to the newest, respectively.
global.menuInstances = ds_list_create();

#endregion

#region Global functions related to obj_controller

/// SINGLETON MAP FUNCTIONS /////////////////////////////////////////////////////////////////////////////////

/// @description A simple function that checks the object provided (Its GML-generated index) against a list
/// of valid signleton objects. If it finds the matching object index, the singleton's key is returned.
/// Otherwise, the value "undefined" is returned to signify the object provided isn't a singleton.
/// @param object
function get_singleton_object_key(_object){
	switch(_object){
		case obj_camera:			return KEY_CAMERA;
		case obj_music_handler:		return KEY_MUSIC_HANDLER;
		case obj_effect_handler:	return KEY_EFFECT_HANDLER;
		case obj_cutscene_manager:	return KEY_CUTSCENE_MANAGER;
		case obj_textbox_handler:	return KEY_TEXTBOX_HANDLER;
		case obj_control_info:		return KEY_CONTROL_INFO;
		case obj_screen_fade:		return KEY_SCREEN_FADE;
		case obj_weather_rain:		return KEY_WEATHER_RAIN;
		case obj_weather_fog:		return KEY_WEATHER_FOG;
		case obj_controller:		return KEY_CONTROLLER;
		case obj_player:			return KEY_PLAYER;
		case obj_debugger:			return KEY_DEBUGGER;	// FOR TESTING
		default:					return undefined;
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////

/// MENU MANAGEMENT FUNCTIONS ///////////////////////////////////////////////////////////////////////////////

/// @description A simple function that createds an instance of a menu, but only a single instance of that
/// menu at any given time to prevent accidental duplication. It initializes the newly created menu, adds it
/// to the list of existing menu structs, and the returns the new struct's ID for any use that is required
/// after this function is called by whatever had called it.
/// @param struct
function instance_create_menu_struct(_struct){
	// Prevent the menu from being created if it already exists in the menu instance list OR if the struct
	// provided to the function isn't a valid menu struct.
	if (get_menu_struct(_struct) != undefined || !is_menu_struct(_struct)) {return noone;}
	
	// First, store the struct that will be created into an ID variable to allow the code to then reference
	// the menu's default initialization function. Then, add the newly initialized menu to the list that 
	// manages and handles all the currently created menu that are in the game at the moment.
	ds_list_add(global.menuInstances, instance_create_struct(_struct));
	
	
	// Finally, return the ID of the newly created menu in order to allow the code that called this function
	// to manipulate the newly menu struct's data if the need arises.
	return global.menuInstances[| (ds_list_size(global.menuInstances) - 1)];
}

/// @description A simple function that destroys a menu struct; clearing it from memory and also removing its
/// instance ID from the menu management list. However, it will only perform these actions if the supplied
/// struct was found within that list to begin with.
/// @param struct
function instance_destroy_menu_struct(_struct){
	var _structIndex = get_menu_struct(_struct);
	if (_structIndex != undefined){
		instance_destroy_struct(global.menuInstances[| _structIndex]);
		ds_list_delete(global.menuInstances, _structIndex);
	}
}

/// @description A simple function that will search through the menu struct list to see if the provided
/// struct index doesn't already currently exist. This is done by linearly going through said list to see
/// if one of the menu object's object_index variable matches up with the provided struct's index. If so,
/// the function returns true. Otherwise, it will return false.
/// @param struct
function get_menu_struct(_struct){
	var _length = ds_list_size(global.menuInstances);
	for (var i = 0; i < _length; i++){
		if (global.menuInstances[| i].object_index == _struct) {return i;}
	}
	return undefined;
}

/// @description A simple function that checks to see if the struct being referenced is a menu struct; 
/// meaning that it inherits from the "par_menu" constructor. OR actually is that "par_menu" struct. In 
/// short, if it is  found in the switch/case statement, the function will return true, and by default it 
/// will return false.
/// @param struct
function is_menu_struct(_struct){
	switch(_struct){
		case par_menu:				return true;
		case obj_main_menu:			return true;
		default:					return false;
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////

#endregion