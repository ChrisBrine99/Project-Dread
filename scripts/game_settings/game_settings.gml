/// @description Insert summary of this file here.

#region Initializing any macros that are useful/related to the game settings struct

// A macro to simplify the look of the code whenever the game settings struct needs to be referenced.
#macro	GAME_SETTINGS			global.gameSettings

// Stores the strings that represent each of the sections found within the game's "settings.ini" file.
#macro	SECTION_VIDEO			"VIDEO"
#macro	SECTION_AUDIO			"AUDIO"
#macro	SECTION_ACCESSIBILITY	"ACCESSIBILITY"
#macro	SECTION_KEYBOARD		"KEYBOARD"
#macro	SECTION_GAMEPAD			"GAMEPAD"

// The bits that enable/disable certain features of the game's video settings. If they are set, the effects
// will be active. If not set, none of the unset effects are applied (Bloom, aberration, etc.).
#macro	FULL_SCREEN				0
#macro	VERTICAL_SYNC			1
#macro	BLOOM_EFFECT			2
#macro	ABERRATION_EFFECT		3
#macro	FILM_GRAIN_FILTER		4
#macro	SCANLINE_FILTER			5

// The single bit for audio settings that will determine if music should be audible or not.
#macro	PLAY_MUSIC				10

// The bits that store the flags for a few of the game's accessibility settings. 
#macro	OBJECTIVE_HINTS			20
#macro	ITEM_HIGHLIGHTING		21
#macro	INTERACTION_PROMPTS		22
#macro	IS_RUN_TOGGLE			23
#macro	IS_AIM_TOGGLE			24
#macro	SWAP_MOVEMENT_STICK		25

// The bit that enables vibration for a connected gamepad (If that gamepad's vibrators can be interfaced by
// GameMaker's code).
#macro	GAMEPAD_VIBRATION		30

// The values that will tell the game settings which volume group needs to be dealt with when calling the
// "game_get_audio_group" function. The bottom three will all have their volume adjusted based on the global
// volume's current value.
#macro	GLOBAL_VOLUME			0
#macro	MUSIC_VOLUME			1
#macro	GAME_VOLUME				2
#macro	UI_VOLUME				3

// The locations of the bits that determine what combat difficulty the game has been set to; also determining
// item spawning locations for resources, as well as their rarity.
#macro	CDIFF_FORGIVING			0
#macro	CDIFF_STANDARD			1
#macro	CDIFF_PUNISHING			2
#macro	CDIFF_NIGHTMARE			3
#macro	CDIFF_ONELIFEMODE		4

// The positions for the bits that will tell the game what the current difficulty for puzzles is; also affecting
// what items spawn where for puzzles that require items, and so on.
#macro	PDIFF_FORGIVING			5
#macro	PDIFF_STANDARD			6
#macro	PDIFF_PUNISHING			7

// The locations for all the bits that toggle unique game mechanics, system, and starting items. These will
// all be set to any combination of 0 or 1 for what the desired difficulty level requires.
#macro	REGEN_HITPOINTS			10
#macro	STARTING_PISTOL			11
#macro	LIMITED_SAVES			12
#macro	ITEMS_HAVE_DURABILITY	13
#macro	ONE_LIFE_MODE			14
#macro	CHECKPOINTS				15

// The position for the bit that determines if the player will receive hints for puzzles or not.
#macro	PUZZLE_HINTS			20

// The positions within the buffer for the player's current input configuration that each of these actions' 
// respective keybindings are stored. Each is a 2-byte value storing each input's virtual key code.
#macro	KEY_GAME_RIGHT			0		// Player movement inputs
#macro	KEY_GAME_LEFT			2
#macro	KEY_GAME_UP				4
#macro	KEY_GAME_DOWN			6
#macro	KEY_RUN					8
#macro	KEY_INTERACT			10		// World interaction input
#macro	KEY_READY_WEAPON		12		// Weapon manipulation inputs
#macro	KEY_USE_WEAPON			14
#macro	KEY_AMMO_SWAP			16
#macro	KEY_RELOAD				18
#macro	KEY_FLASHLIGHT			20		// Flashlight inputs
#macro	KEY_LIGHT_SWAP			22
#macro	KEY_ITEMS				24		// Pausing/inventory shortcut inputs
#macro	KEY_MAPS				26
#macro	KEY_NOTES				28
#macro	KEY_PAUSE				30
#macro	KEY_MENU_RIGHT			32		// Menu cursor movement inputs
#macro	KEY_MENU_LEFT			34
#macro	KEY_MENU_UP				36
#macro	KEY_MENU_DOWN			38
#macro	KEY_AUX_MENU_RIGHT		40
#macro	KEY_AUX_MENU_LEFT		42
#macro	KEY_SELECT				44		// Menu option interaction inputs
#macro	KEY_RETURN				46
#macro	KEY_FILE_DELETE			48
#macro	KEY_ADVANCE				50		// Textbox inputs
#macro	KEY_LOG					52

// The positions within the buffer for the player's current input configuration that each of these actions'
// respective gamepad input bindings are stored. Each is a 2-byte value storing the values for Game Maker's
// constants for gamepad input bindings that match up to what the player has configured for their gamepad
// control scheme.
#macro	GPAD_GAME_RIGHT			60		// Player movement inputs 
#macro	GPAD_GAME_LEFT			62		
#macro	GPAD_GAME_UP			64		
#macro	GPAD_GAME_DOWN			66		
#macro	GPAD_RUN				68		
#macro	GPAD_INTERACT			70		// World interaction input 
#macro	GPAD_READY_WEAPON		72		// Weapon manipulation inputs 
#macro	GPAD_USE_WEAPON			74		
#macro	GPAD_AMMO_SWAP			76		
#macro	GPAD_RELOAD				78
#macro	GPAD_FLASHLIGHT			80		// Flashlight inputs 
#macro	GPAD_LIGHT_SWAP			82		
#macro	GPAD_ITEMS				84		// Pausing/inventory shortcut inputs 
#macro	GPAD_MAPS				86		
#macro	GPAD_NOTES				88		
#macro	GPAD_PAUSE				90		
#macro	GPAD_MENU_RIGHT			92		// Menu cursor movement inputs 
#macro	GPAD_MENU_LEFT			94		
#macro	GPAD_MENU_UP			96		
#macro	GPAD_MENU_DOWN			98		
#macro	GPAD_AUX_MENU_RIGHT		100		
#macro	GPAD_AUX_MENU_LEFT		102		
#macro	GPAD_SELECT				104		// Menu option interaction inputs 
#macro	GPAD_RETURN				106		
#macro	GPAD_FILE_DELETE		108		
#macro	GPAD_ADVANCE			110		// Textbox inputs 
#macro	GPAD_LOG				112

// A shorted down version that returns the volume for each of the four groups; the bottom three being influenced
// by what the current global volume is (Values all range from 0 to 1).
#macro	GET_GLOBAL_VOLUME		game_get_group_volume(GLOBAL_VOLUME)
#macro	GET_MUSIC_VOLUME		game_get_group_volume(MUSIC_VOLUME)
#macro	GET_GAME_VOLUME			game_get_group_volume(GAME_VOLUME)
#macro	GET_UI_VOLUME			game_get_group_volume(UI_VOLUME)

#endregion

#region Initializing enumerators that are useful/related to the game settings struct
#endregion

#region Initializing any globals that are useful/related to the game settings struct
#endregion

#region The main object code for the game settings struct

global.gameSettings = {
	// Each variable holds 32 unique bits that can be set to 0 or 1 to determine how the games settings are
	// constructed, as well as the game's difficulty settings. Note that not all of the bits available are
	// used by either variable.
	settingFlags :			0,
	difficultyFlags :		0,
	
	// For video settings that can't be stored as single bits, they will all have their own variables to
	// represent their current configurations. These include the current aspect ratio, resolution scale (Not
	// used when the game is in full-screen mode), and the image's gamma level.
	resolutionScale :		0,
	aspectRatio :			0,
	gamma :					0,
	
	// Much like the group of variables above, these will store setting values that can be represented by a
	// single bit, but for audio levels instead of various video setttings. Each is represented by a percentage
	// that is stored as a value between 0 and 1, determining the overall volume of the group they represent.
	globalVolume :			0,
	musicVolume :			0,
	gameVolume :			0,
	uiVolume :				0,
	
	// The input binding buffer will store the currently set inputs for each action that were set up by the
	// player (Or the defaults if they haven't altered the base controls). Each of these buffer values is a
	// 2-byte value in order to store the values for the gamepad input constants that GML uses (These are
	// values of somwhere around 32700, I believe). The last three variables will store values that can be
	// adjusted by the user so that they fit their gamepad well.
	inputBindings :			buffer_create(120, buffer_fixed, 2),
	vibrationIntensity :	0,
	stickDeadzone :			0,
	triggerThreshold :		0,
	
	// An accessibility setting that can't be stored as a single bit. It will determine how fast characters
	// appear on the screen when they use a typewriter-like effect during rendering. The higher the value,
	// the faster that effect occurs.
	textSpeed :				0,
	
	// Damage modification values for the game's difficulty that can't be represented by individual bits.
	// Instead, they are decimal values that will increased or decrease the damage output for the player or
	// an enemy based on if their modifier value is greater than or less than 1.0, respectively.
	pDamageModifier :		1.0,
	eDamageModifier :		1.0,
	
	/// @description 
	cleanup : function(){
		buffer_delete(inputBindings);
	},
	
	/// @description 
	/// @param {Real}	inputID
	/// @param {Real}	inputConstant
	set_input_binding : function(_inputID, _inputConstant){
		if (_inputID < 0 || _inputID > buffer_get_size(inputBindings)) {return;}
		buffer_poke(inputBindings, _inputID, buffer_u16, _inputConstant);
	},
	
	/// @description 
	/// @param {Real}	inputID
	get_input_binding : function(_inputID){
		if (_inputID < 0 || _inputID > buffer_get_size(inputBindings)) {return -1;}
		return buffer_peek(inputBindings, _inputID, buffer_u16);
	}
}

#endregion

#region Global functions related to the game settings struct

/// @description 
/// @param {Real}	flagID
/// @param {Real}	flagState
function game_set_setting_flag(_flagID, _flagState){
	with(GAME_SETTINGS) {settingFlags = settingFlags | (_flagState << _flagID);}
}

/// @description 
/// @param {Real}	flagID
function game_get_setting_flag(_flagID){
	with(GAME_SETTINGS) {return (settingFlags & (1 << _flagID) != 0);}
}

/// @description 
function game_load_settings(){
	with(GAME_SETTINGS){
		// Opens the settings ini file so it can be read into the game's data. Note that if no file actually
		// exists with that name, the file will be created automatically by this function; it will just be
		// completely empty.
		ini_open("settings.ini");
		
		// First, all the bit flags are grabbed from the settings are applied to the value of 0. That way, the
		// settings that were previously applied will be completely overwritten by this function loading the
		// values in from the file, since they could possibly differ.
		settingFlags = 0 | 
			(ini_read_real(SECTION_VIDEO, "fullscreen", 0) <<				FULL_SCREEN) |
			(ini_read_real(SECTION_VIDEO, "vsync", 0) <<					VERTICAL_SYNC) |
			(ini_read_real(SECTION_VIDEO, "bloom", 1) <<					BLOOM_EFFECT) |
			(ini_read_real(SECTION_VIDEO, "chromatic_aberration", 1) <<		ABERRATION_EFFECT) |
			(ini_read_real(SECTION_VIDEO, "film_grain", 1) <<				FILM_GRAIN_FILTER) |
			(ini_read_real(SECTION_VIDEO, "scanlines", 1) <<				SCANLINE_FILTER) |
			(ini_read_real(SECTION_AUDIO, "play_music", 1) <<				PLAY_MUSIC) |
			(ini_read_real(SECTION_ACCESSIBILITY, "objective_hints", 0) <<	OBJECTIVE_HINTS) |
			(ini_read_real(SECTION_ACCESSIBILITY, "item_highlights", 0) <<	ITEM_HIGHLIGHTING) |
			(ini_read_real(SECTION_ACCESSIBILITY, "interact_prompts", 1) <<	INTERACTION_PROMPTS) |
			(ini_read_real(SECTION_ACCESSIBILITY, "is_run_toggle", 0) <<	IS_RUN_TOGGLE) |
			(ini_read_real(SECTION_ACCESSIBILITY, "is_aim_toggle", 0) <<	IS_AIM_TOGGLE) |
			(ini_read_real(SECTION_ACCESSIBILITY, "swap_movement", 0) <<	SWAP_MOVEMENT_STICK);
		
		// Loading in the video settings that aren't represented by single bits in the "settingFlags" integer.
		resolutionScale =	ini_read_real(SECTION_VIDEO, "resolution_scale", 4);
		aspectRatio =		ini_read_real(SECTION_VIDEO, "aspect_ratio", AspectRatio.SixteenByNine);
		gamma =				ini_read_real(SECTION_VIDEO, "gamma", 1.0);
		
		// Loading in the volume for each of the four main groups.
		globalVolume =		ini_read_real(SECTION_AUDIO, "global_volume", 1.0);
		musicVolume =		ini_read_real(SECTION_AUDIO, "music_volume", 0.75);
		gameVolume =		ini_read_real(SECTION_AUDIO, "game_volume", 0.85);
		uiVolume =			ini_read_real(SECTION_AUDIO, "ui_volume", 0.65);
		
		// Reading in and applying all player input bindings for the keyboard. If no values exists, the defaults
		// at the end of each line will be what is set to the input's space in the "inputBindings" buffer.
		buffer_poke(inputBindings, KEY_GAME_RIGHT, buffer_u16,		ini_read_real(SECTION_KEYBOARD, "game_right",		vk_right));
		buffer_poke(inputBindings, KEY_GAME_LEFT, buffer_u16,		ini_read_real(SECTION_KEYBOARD,	"game_left",		vk_left));
		buffer_poke(inputBindings, KEY_GAME_UP, buffer_u16,			ini_read_real(SECTION_KEYBOARD, "game_up",			vk_up));
		buffer_poke(inputBindings, KEY_GAME_DOWN, buffer_u16,		ini_read_real(SECTION_KEYBOARD, "game_down",		vk_down));
		buffer_poke(inputBindings, KEY_RUN, buffer_u16,				ini_read_real(SECTION_KEYBOARD, "run",				vk_shift));
		buffer_poke(inputBindings, KEY_INTERACT, buffer_u16,		ini_read_real(SECTION_KEYBOARD, "interact",			vk_z));
		buffer_poke(inputBindings, KEY_READY_WEAPON, buffer_u16,	ini_read_real(SECTION_KEYBOARD, "ready_weapon",		vk_x));
		buffer_poke(inputBindings, KEY_USE_WEAPON, buffer_u16,		ini_read_real(SECTION_KEYBOARD, "use_weapon",		vk_z));
		buffer_poke(inputBindings, KEY_AMMO_SWAP, buffer_u16,		ini_read_real(SECTION_KEYBOARD, "ammo_swap",		vk_control));
		buffer_poke(inputBindings, KEY_RELOAD, buffer_u16,			ini_read_real(SECTION_KEYBOARD, "reload",			vk_c));
		buffer_poke(inputBindings, KEY_FLASHLIGHT, buffer_u16,		ini_read_real(SECTION_KEYBOARD, "flashlight",		vk_f));
		buffer_poke(inputBindings, KEY_LIGHT_SWAP, buffer_u16,		ini_read_real(SECTION_KEYBOARD, "light_swap",		vk_alt));
		buffer_poke(inputBindings, KEY_ITEMS, buffer_u16,			ini_read_real(SECTION_KEYBOARD, "items",			vk_tab));
		buffer_poke(inputBindings, KEY_NOTES, buffer_u16,			ini_read_real(SECTION_KEYBOARD, "notes",			vk_n));
		buffer_poke(inputBindings, KEY_MAPS, buffer_u16,			ini_read_real(SECTION_KEYBOARD, "maps",				vk_m));
		buffer_poke(inputBindings, KEY_PAUSE, buffer_u16,			ini_read_real(SECTION_KEYBOARD, "pause",			vk_escape));
		buffer_poke(inputBindings, KEY_MENU_RIGHT, buffer_u16,		ini_read_real(SECTION_KEYBOARD, "menu_right",		vk_right));
		buffer_poke(inputBindings, KEY_MENU_LEFT, buffer_u16,		ini_read_real(SECTION_KEYBOARD, "menu_left",		vk_left));
		buffer_poke(inputBindings, KEY_MENU_UP, buffer_u16,			ini_read_real(SECTION_KEYBOARD, "menu_up",			vk_up));
		buffer_poke(inputBindings, KEY_MENU_DOWN, buffer_u16,		ini_read_real(SECTION_KEYBOARD, "menu_down",		vk_down));
		buffer_poke(inputBindings, KEY_AUX_MENU_RIGHT, buffer_u16,	ini_read_real(SECTION_KEYBOARD, "aux_menu_right",	vk_v));
		buffer_poke(inputBindings, KEY_AUX_MENU_LEFT, buffer_u16,	ini_read_real(SECTION_KEYBOARD, "aux_menu_left",	vk_c));
		buffer_poke(inputBindings, KEY_SELECT, buffer_u16,			ini_read_real(SECTION_KEYBOARD, "select",			vk_z));
		buffer_poke(inputBindings, KEY_RETURN, buffer_u16,			ini_read_real(SECTION_KEYBOARD, "return",			vk_x));
		buffer_poke(inputBindings, KEY_FILE_DELETE, buffer_u16,		ini_read_real(SECTION_KEYBOARD, "file_delete",		vk_d));
		buffer_poke(inputBindings, KEY_ADVANCE, buffer_u16,			ini_read_real(SECTION_KEYBOARD, "advance",			vk_z));
		buffer_poke(inputBindings, KEY_LOG, buffer_u16,				ini_read_real(SECTION_KEYBOARD, "log",				vk_x));
		
		// Reading in and applying all player input bindings for the gamepad. If no values exists, the defaults
		// at the end of each line will be what is set to the input's space in the "inputBindings" buffer.
		buffer_poke(inputBindings, GPAD_GAME_RIGHT, buffer_u16,		ini_read_real(SECTION_GAMEPAD, "game_right",		gp_padr));
		buffer_poke(inputBindings, GPAD_GAME_LEFT, buffer_u16,		ini_read_real(SECTION_GAMEPAD,	"game_left",		gp_padl));
		buffer_poke(inputBindings, GPAD_GAME_UP, buffer_u16,		ini_read_real(SECTION_GAMEPAD, "game_up",			gp_padu));
		buffer_poke(inputBindings, GPAD_GAME_DOWN, buffer_u16,		ini_read_real(SECTION_GAMEPAD, "game_down",			gp_padd));
		buffer_poke(inputBindings, GPAD_RUN, buffer_u16,			ini_read_real(SECTION_GAMEPAD, "run",				gp_face3));
		buffer_poke(inputBindings, GPAD_INTERACT, buffer_u16,		ini_read_real(SECTION_GAMEPAD, "interact",			gp_face1));
		buffer_poke(inputBindings, GPAD_READY_WEAPON, buffer_u16,	ini_read_real(SECTION_GAMEPAD, "ready_weapon",		gp_shoulderl));
		buffer_poke(inputBindings, GPAD_USE_WEAPON, buffer_u16,		ini_read_real(SECTION_GAMEPAD, "use_weapon",		gp_face1));
		buffer_poke(inputBindings, GPAD_AMMO_SWAP, buffer_u16,		ini_read_real(SECTION_GAMEPAD, "ammo_swap",			gp_face2));
		buffer_poke(inputBindings, GPAD_RELOAD, buffer_u16,			ini_read_real(SECTION_GAMEPAD, "reload",			gp_face3));
		buffer_poke(inputBindings, GPAD_FLASHLIGHT, buffer_u16,		ini_read_real(SECTION_GAMEPAD, "flashlight",		gp_face4));
		buffer_poke(inputBindings, GPAD_LIGHT_SWAP, buffer_u16,		ini_read_real(SECTION_GAMEPAD, "light_swap",		gp_face2));
		buffer_poke(inputBindings, GPAD_ITEMS, buffer_u16,			ini_read_real(SECTION_GAMEPAD, "items",				gp_select));
		buffer_poke(inputBindings, GPAD_NOTES, buffer_u16,			ini_read_real(SECTION_GAMEPAD, "notes",				gp_shoulderlb));
		buffer_poke(inputBindings, GPAD_MAPS, buffer_u16,			ini_read_real(SECTION_GAMEPAD, "maps",				gp_shoulderrb));
		buffer_poke(inputBindings, GPAD_PAUSE, buffer_u16,			ini_read_real(SECTION_GAMEPAD, "pause",				gp_start));
		buffer_poke(inputBindings, GPAD_MENU_RIGHT, buffer_u16,		ini_read_real(SECTION_GAMEPAD, "menu_right",		gp_padr));
		buffer_poke(inputBindings, GPAD_MENU_LEFT, buffer_u16,		ini_read_real(SECTION_GAMEPAD, "menu_left",			gp_padl));
		buffer_poke(inputBindings, GPAD_MENU_UP, buffer_u16,		ini_read_real(SECTION_GAMEPAD, "menu_up",			gp_padu));
		buffer_poke(inputBindings, GPAD_MENU_DOWN, buffer_u16,		ini_read_real(SECTION_GAMEPAD, "menu_down",			gp_padd));
		buffer_poke(inputBindings, GPAD_AUX_MENU_RIGHT, buffer_u16,	ini_read_real(SECTION_GAMEPAD, "aux_menu_right",	gp_shoulderlb));
		buffer_poke(inputBindings, GPAD_AUX_MENU_LEFT, buffer_u16,	ini_read_real(SECTION_GAMEPAD, "aux_menu_left",		gp_shoulderrb));
		buffer_poke(inputBindings, GPAD_SELECT, buffer_u16,			ini_read_real(SECTION_GAMEPAD, "select",			gp_face1));
		buffer_poke(inputBindings, GPAD_RETURN, buffer_u16,			ini_read_real(SECTION_GAMEPAD, "return",			gp_face2));
		buffer_poke(inputBindings, GPAD_FILE_DELETE, buffer_u16,	ini_read_real(SECTION_GAMEPAD, "file_delete",		gp_face3));
		buffer_poke(inputBindings, GPAD_ADVANCE, buffer_u16,		ini_read_real(SECTION_GAMEPAD, "advance",			gp_face1));
		buffer_poke(inputBindings, GPAD_LOG, buffer_u16,			ini_read_real(SECTION_GAMEPAD, "log",				gp_face3));
		
		// 
		vibrationIntensity =	ini_read_real(SECTION_GAMEPAD, "vibrate_intensity", 0.5);
		stickDeadzone =			ini_read_real(SECTION_GAMEPAD, "stick_deadzone",	0.25);
		triggerThreshold =		ini_read_real(SECTION_GAMEPAD, "trigger_threshold", 0.15);
		
		// 
		textSpeed =				ini_read_real(SECTION_ACCESSIBILITY, "text_speed",	0.75);
		
		ini_close();
	}
}

/// @description 
function game_save_settings(){
	with(GAME_SETTINGS){
		// 
		ini_open("settings.ini");
		
		// 
		ini_write_real(SECTION_VIDEO, "resolution_scale",		resolutionScale);
		ini_write_real(SECTION_VIDEO, "aspect_ratio",			aspectRatio);
		ini_write_real(SECTION_VIDEO, "fullscreen",				(settingFlags & (1 << FULL_SCREEN)) != 0);
		ini_write_real(SECTION_VIDEO, "vsync",					(settingFlags & (1 << VERTICAL_SYNC)) != 0);
		ini_write_real(SECTION_VIDEO, "gamma",					gamma);
		ini_write_real(SECTION_VIDEO, "bloom",					(settingFlags & (1 << BLOOM_EFFECT)) != 0);
		ini_write_real(SECTION_VIDEO, "chromatic_aberration",	(settingFlags & (1 << ABERRATION_EFFECT)) != 0);
		ini_write_real(SECTION_VIDEO, "film_grain",				(settingFlags & (1 << FILM_GRAIN_FILTER)) != 0);
		ini_write_real(SECTION_VIDEO, "scanlines",				(settingFlags & (1 << SCANLINE_FILTER)) != 0);
		
		// 
		ini_write_real(SECTION_AUDIO, "global_volume",			globalVolume);
		ini_write_real(SECTION_AUDIO, "music_volume",			musicVolume);
		ini_write_real(SECTION_AUDIO, "play_music",				(settingFlags & (1 << PLAY_MUSIC)) != 0);
		ini_write_real(SECTION_AUDIO, "game_volume",			gameVolume);
		ini_write_real(SECTION_AUDIO, "ui_volume",				uiVolume);
		
		// 
		ini_write_real(SECTION_KEYBOARD, "game_right",			buffer_peek(inputBindings, KEY_GAME_RIGHT, buffer_u16));
		ini_write_real(SECTION_KEYBOARD, "game_left",			buffer_peek(inputBindings, KEY_GAME_LEFT, buffer_u16));
		ini_write_real(SECTION_KEYBOARD, "game_up",				buffer_peek(inputBindings, KEY_GAME_UP, buffer_u16));
		ini_write_real(SECTION_KEYBOARD, "game_down",			buffer_peek(inputBindings, KEY_GAME_DOWN, buffer_u16));
		ini_write_real(SECTION_KEYBOARD, "run",					buffer_peek(inputBindings, KEY_RUN, buffer_u16));
		ini_write_real(SECTION_KEYBOARD, "interact",			buffer_peek(inputBindings, KEY_INTERACT, buffer_u16));
		
		
		/*

		(ini_read_real(SECTION_ACCESSIBILITY, "objective_hints", 0) <<	OBJECTIVE_HINTS) |
		(ini_read_real(SECTION_ACCESSIBILITY, "item_highlights", 0) <<	ITEM_HIGHLIGHTING) |
		(ini_read_real(SECTION_ACCESSIBILITY, "interact_prompts", 1) <<	INTERACTION_PROMPTS) |
		(ini_read_real(SECTION_ACCESSIBILITY, "is_run_toggle", 0) <<	IS_RUN_TOGGLE) |
		(ini_read_real(SECTION_ACCESSIBILITY, "is_aim_toggle", 0) <<	IS_AIM_TOGGLE) |
		(ini_read_real(SECTION_ACCESSIBILITY, "swap_movement", 0) <<	SWAP_MOVEMENT_STICK);
		
		*/
		
		ini_close();
	}
}

/// @description 
/// @param {Real}	inputID
/// @param {Real}	inputConstant
function game_set_input_binding(_inputID, _inputConstant){
	with(GAME_SETTINGS) {set_input_binding(_inputID, _inputConstant);}
}

/// @description 
/// @param {Real}	inputID
function game_get_input_binding(_inputID){
	with(GAME_SETTINGS) {get_input_binding(_inputID);}
}

/// @description 
/// @param {Real}	volumeGroup
function game_get_group_volume(_volumeGroup){
	with(GAME_SETTINGS){
		switch(_volumeGroup){
			case GLOBAL_VOLUME:		return globalVolume;
			case MUSIC_VOLUME:		return (settingFlags & (1 << PLAY_MUSIC)) ? (globalVolume * musicVolume) : 0;
			case GAME_VOLUME:		return (globalVolume * gameVolume);
			case UI_VOLUME:			return (globalVolume * uiVolume);
			default:				return 0;
		}
	}
}

/// @description 
/// @param {Real}	difficultyFlag
function game_set_combat_difficulty(_difficultyFlag){
	with(GAME_SETTINGS){
		switch(_difficultyFlag){
			case CDIFF_FORGIVING:	// Flag states for the easiest combat experience.
				difficultyFlags = difficultyFlags & // Compiles to "& ~28702"
				  ~((1 << CDIFF_STANDARD) |			// Clearing unused bits in case they've been set.
					(1 << CDIFF_PUNISHING) |
					(1 << CDIFF_NIGHTMARE) |
					(1 << CDIFF_ONELIFEMODE) |
					(1 << LIMITED_SAVES) |
					(1 << ITEMS_HAVE_DURABILITY) |
					(1 << ONE_LIFE_MODE));
				difficultyFlags = difficultyFlags |	// Compiles to "| 35841"
					(1 << CDIFF_FORGIVING) |		// Setting required bits for difficulty configuration.
					(1 << REGEN_HITPOINTS) |
					(1 << STARTING_PISTOL) |
					(1 << CHECKPOINTS);
				pDamageModifier = 1.4;	// Player given a 40% boost to their damage; enemies have their
				eDamageModifier = 0.5;	// damage output cut in half.
				break;
			case CDIFF_STANDARD:	// Flag states for the standard combat experience.
				difficultyFlags = difficultyFlags &	// Compiles to "& ~31773"
				  ~((1 << CDIFF_FORGIVING) |		// Clearing unused bits in case they've been set.
					(1 << CDIFF_PUNISHING) |
					(1 << CDIFF_NIGHTMARE) |
					(1 << CDIFF_ONELIFEMODE) |
					(1 << REGEN_HITPOINTS) |
					(1 << STARTING_PISTOL) |
					(1 << LIMITED_SAVES) |
					(1 << ITEMS_HAVE_DURABILITY) |
					(1 << ONE_LIFE_MODE));
				difficultyFlags = difficultyFlags | // Compiles to "| 32770"
					(1 << CDIFF_STANDARD) |			// Setting required bits for difficulty configuration.
					(1 << CHECKPOINTS);
				pDamageModifier = 1.0;	// No modification to player or enemy damage numbers.
				eDamageModifier = 1.0;
				break;
			case CDIFF_PUNISHING:	// Flag states for the first difficulty above the standard configuration.
				difficultyFlags = difficultyFlags & // Compiles to "& ~27675"
				  ~((1 << CDIFF_FORGIVING) |		// Clearing unused bits in case they've been set.
					(1 << CDIFF_STANDARD) |
					(1 << CDIFF_NIGHTMARE) |
					(1 << CDIFF_ONELIFEMODE) |
					(1 << REGEN_HITPOINTS) |
					(1 << STARTING_PISTOL) |
					(1 << ITEMS_HAVE_DURABILITY) |
					(1 << ONE_LIFE_MODE));
				difficultyFlags = difficultyFlags |	// Compiles to "| 36868"
					(1 << CDIFF_PUNISHING) |		// Setting required bits for difficulty configuration.
					(1 << LIMITED_SAVES) |
					(1 << CHECKPOINTS);
				pDamageModifier = 0.8;	// Player reveives a 20% cut to their damage output; enemies
				eDamageModifier = 1.2;	// see an increase in damage output of 20%.
				break;
			case CDIFF_NIGHTMARE:	// Flag states for the second difficulty above the standard configuration.
				difficultyFlags = difficultyFlags &	// Compiles to "& ~52253"
				  ~((1 << CDIFF_FORGIVING) |		// Clearing unused bits in case they've been set
					(1 << CDIFF_STANDARD) |
					(1 << CDIFF_PUNISHING) |
					(1 << CDIFF_ONELIFEMODE) |
					(1 << REGEN_HITPOINTS) |
					(1 << STARTING_PISTOL) |
					(1 << ONE_LIFE_MODE) |
					(1 << CHECKPOINTS));
				difficultyFlags = difficultyFlags &	// Compiles to "| 12288"
					(1 << CDIFF_NIGHTMARE) |		// Setting required bits for difficulty configuration.
					(1 << LIMITED_SAVES) |
					(1 << ITEMS_HAVE_DURABILITY);
				pDamageModifier = 0.7;	// Player takes a 30% cut in damage output; enemies see a damage
				eDamageModifier = 1.4;	// output increase of 40%.
				break;
			case CDIFF_ONELIFEMODE:	// Flag states for the final difficulty above the standard configuration.
				difficultyFlags = difficultyFlags & // Compiles to "& ~39951"
				  ~((1 << CDIFF_FORGIVING) |		// Clearing unused bits in case they've been set.
					(1 << CDIFF_STANDARD) |
					(1 << CDIFF_PUNISHING) |
					(1 << CDIFF_NIGHTMARE) |
					(1 << REGEN_HITPOINTS) |
					(1 << STARTING_PISTOL) |
					(1 << LIMITED_SAVES) |
					(1 << CHECKPOINTS));
				difficultyFlags = difficultyFlags | // Compiles to "| 24592"
					(1 << CDIFF_ONELIFEMODE) |		// Setting required bits for difficulty configuration.
					(1 << ITEMS_HAVE_DURABILITY) |
					(1 << ONE_LIFE_MODE);
				pDamageModifier = 0.6;
				eDamageModifier = 1.6;
				break;
		}
	}
}

/// @description 
/// @param puzzleDifficulty
function game_set_puzzle_difficulty(_difficultyFlag){
	with(GAME_SETTINGS){
		switch(_difficultyFlag){
			case PDIFF_FORGIVING:	// Flag states for the easiest puzzle configurations.
				difficultyFlags = difficultyFlags & // Compiles to "& ~192"
				  ~((1 << PDIFF_STANDARD) |			// Clearing unused bits in case they've been set.
					(1 << PDIFF_PUNISHING));
				difficultyFlags = difficultyFlags | // Compiles to "| 1048608"
					(1 << PDIFF_FORGIVING) |		// Setting required bits for difficulty configuration.
					(1 << PUZZLE_HINTS);
				break;
			case PDIFF_STANDARD:	// Flag states for the standard puzzle difficulty.
				difficultyFlags = difficultyFlags & // Compiles to "& ~1048736"
				  ~((1 << PDIFF_FORGIVING) |		// Clearing unused bits in case they've been set.
					(1 << PDIFF_PUNISHING) |
					(1 << PUZZLE_HINTS));
				difficultyFlags = difficultyFlags | // Compiles to "| 64"
					(1 << PDIFF_STANDARD);			// Setting required bits for difficulty configuration.
				break;
			case PDIFF_PUNISHING:	// Flag states for the difficulty above the standard puzzles.
				difficultyFlags = difficultyFlags & // Compiles to "& ~1048672"
				  ~((1 << PDIFF_FORGIVING) |		// Clearing unused bits in case they've been set.
				  	(1 << PDIFF_STANDARD) |
				  	(1 << PUZZLE_HINTS));
				difficultyFlags = difficultyFlags | // Compiles to "| 128"
					(1 << PDIFF_PUNISHING);			// Setting required bits for difficulty configuration.
		}
	}
}

#endregion