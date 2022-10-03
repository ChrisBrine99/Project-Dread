/// @description Contains all the data that is used to assign, manipulate, store, and utilize all of
/// the player's desired settings given their current configuration. This includes audio, video,
/// input, and accessibility settings, as well as the difficulty configuration for the current game.

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

// 
#macro	AR_SIXTEEN_BY_NINE		800
#macro	AR_SIXTEEN_BY_TEN		801
#macro	AR_THREE_BY_TWO			802
#macro	AR_SEVEN_BY_THREE		803

// The values that will tell the game settings which volume group needs to be dealt with when calling the
// "game_get_audio_group" function. The bottom three will all have their volume adjusted based on the global
// volume's current value.
#macro	GLOBAL_VOLUME			0
#macro	MUSIC_VOLUME			1
#macro	SOUND_VOLUME			2
#macro	FOOTSTEP_VOLUME			3
#macro	AMBIENCE_VOLUME			4
#macro	UI_VOLUME				5

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

// Macros to simply the typing required to check each respective input binding for the keyboard whenever
// player input needs to be processed in the code.
#macro	KEYCODE_GAME_RIGHT		game_get_input_binding(KEY_GAME_RIGHT)		// Player movement inputs 
#macro	KEYCODE_GAME_LEFT		game_get_input_binding(KEY_GAME_LEFT)
#macro	KEYCODE_GAME_UP			game_get_input_binding(KEY_GAME_UP)
#macro	KEYCODE_GAME_DOWN		game_get_input_binding(KEY_GAME_DOWN)
#macro	KEYCODE_RUN				game_get_input_binding(KEY_RUN)
#macro	KEYCODE_INTERACT		game_get_input_binding(KEY_INTERACT)		// World interaction input
#macro	KEYCODE_READY_WEAPON	game_get_input_binding(KEY_READY_WEAPON)	// Weapon manipulation inputs 
#macro	KEYCODE_USE_WEAPON		game_get_input_binding(KEY_USE_WEAPON)
#macro	KEYCODE_AMMO_SWAP		game_get_input_binding(KEY_INTERACT)
#macro	KEYCODE_RELOAD			game_get_input_binding(KEY_RELOAD)
#macro	KEYCODE_FLASHLIGHT		game_get_input_binding(KEY_FLASHLIGHT)		// Flashlight inputs
#macro	KEYCODE_LIGHT_SWAP		game_get_input_binding(KEY_LIGHT_SWAP)
#macro	KEYCODE_ITEMS			game_get_input_binding(KEY_ITEMS)			// Pausing/inventory shortcut inputs
#macro	KEYCODE_MAPS			game_get_input_binding(KEY_MAPS)
#macro	KEYCODE_NOTES			game_get_input_binding(KEY_NOTES)
#macro	KEYCODE_PAUSE			game_get_input_binding(KEY_PAUSE)
#macro	KEYCODE_MENU_RIGHT		game_get_input_binding(KEY_MENU_RIGHT)		// Menu cursor movement inputs 
#macro	KEYCODE_MENU_LEFT		game_get_input_binding(KEY_MENU_LEFT)
#macro	KEYCODE_MENU_UP			game_get_input_binding(KEY_MENU_UP)
#macro	KEYCODE_MENU_DOWN		game_get_input_binding(KEY_MENU_DOWN)
#macro	KEYCODE_AUX_MENU_RIGHT	game_get_input_binding(KEY_AUX_MENU_RIGHT)
#macro	KEYCODE_AUX_MENU_LEFT	game_get_input_binding(KEY_AUX_MENU_LEFT)
#macro	KEYCODE_SELECT			game_get_input_binding(KEY_SELECT)			// Menu option interaction inputs 
#macro	KEYCODE_RETURN			game_get_input_binding(KEY_RETURN)
#macro	KEYCODE_FILE_DELETE		game_get_input_binding(KEY_FILE_DELETE)
#macro	KEYCODE_ADVANCE			game_get_input_binding(KEY_ADVANCE)			// Textbox inputs 
#macro	KEYCODE_LOG				game_get_input_binding(KEY_LOG)

// The positions within the buffer for the player's current input configuration that each of these actions'
// respective gamepad input bindings are stored. Each is a 2-byte value storing the values for Game Maker's
// constants for gamepad input bindings that match up to what the player has configured for their gamepad
// control scheme.
#macro	PAD_GAME_RIGHT			60		// Player movement inputs 
#macro	PAD_GAME_LEFT			62		
#macro	PAD_GAME_UP				64		
#macro	PAD_GAME_DOWN			66		
#macro	PAD_RUN					68		
#macro	PAD_INTERACT			70		// World interaction input 
#macro	PAD_READY_WEAPON		72		// Weapon manipulation inputs 
#macro	PAD_USE_WEAPON			74		
#macro	PAD_AMMO_SWAP			76		
#macro	PAD_RELOAD				78
#macro	PAD_FLASHLIGHT			80		// Flashlight inputs 
#macro	PAD_LIGHT_SWAP			82		
#macro	PAD_ITEMS				84		// Pausing/inventory shortcut inputs 
#macro	PAD_MAPS				86		
#macro	PAD_NOTES				88		
#macro	PAD_PAUSE				90		
#macro	PAD_MENU_RIGHT			92		// Menu cursor movement inputs 
#macro	PAD_MENU_LEFT			94		
#macro	PAD_MENU_UP				96		
#macro	PAD_MENU_DOWN			98		
#macro	PAD_AUX_MENU_RIGHT		100		
#macro	PAD_AUX_MENU_LEFT		102		
#macro	PAD_SELECT				104		// Menu option interaction inputs 
#macro	PAD_RETURN				106		
#macro	PAD_FILE_DELETE			108		
#macro	PAD_ADVANCE				110		// Textbox inputs 
#macro	PAD_LOG					112

// Macros to simply the typing required to check each respective input binding for the connected and active
// gamepad whenever player input needs to be processed in the code.
#macro	PADCODE_GAME_RIGHT		game_get_input_binding(PAD_GAME_RIGHT)		// Player movement inputs 
#macro	PADCODE_GAME_LEFT		game_get_input_binding(PAD_GAME_LEFT)
#macro	PADCODE_GAME_UP			game_get_input_binding(PAD_GAME_UP)
#macro	PADCODE_GAME_DOWN		game_get_input_binding(PAD_GAME_DOWN)
#macro	PADCODE_RUN				game_get_input_binding(PAD_RUN)
#macro	PADCODE_INTERACT		game_get_input_binding(PAD_INTERACT)		// World interaction input
#macro	PADCODE_READY_WEAPON	game_get_input_binding(PAD_READY_WEAPON)	// Weapon manipulation inputs 
#macro	PADCODE_USE_WEAPON		game_get_input_binding(PAD_USE_WEAPON)
#macro	PADCODE_AMMO_SWAP		game_get_input_binding(PAD_INTERACT)
#macro	PADCODE_RELOAD			game_get_input_binding(PAD_RELOAD)
#macro	PADCODE_FLASHLIGHT		game_get_input_binding(PAD_FLASHLIGHT)		// Flashlight inputs
#macro	PADCODE_LIGHT_SWAP		game_get_input_binding(PAD_LIGHT_SWAP)
#macro	PADCODE_ITEMS			game_get_input_binding(PAD_ITEMS)			// Pausing/inventory shortcut inputs
#macro	PADCODE_MAPS			game_get_input_binding(PAD_MAPS)
#macro	PADCODE_NOTES			game_get_input_binding(PAD_NOTES)
#macro	PADCODE_PAUSE			game_get_input_binding(PAD_PAUSE)
#macro	PADCODE_MENU_RIGHT		game_get_input_binding(PAD_MENU_RIGHT)		// Menu cursor movement inputs 
#macro	PADCODE_MENU_LEFT		game_get_input_binding(PAD_MENU_LEFT)
#macro	PADCODE_MENU_UP			game_get_input_binding(PAD_MENU_UP)
#macro	PADCODE_MENU_DOWN		game_get_input_binding(PAD_MENU_DOWN)
#macro	PADCODE_AUX_MENU_RIGHT	game_get_input_binding(PAD_AUX_MENU_RIGHT)
#macro	PADCODE_AUX_MENU_LEFT	game_get_input_binding(PAD_AUX_MENU_LEFT)
#macro	PADCODE_SELECT			game_get_input_binding(PAD_SELECT)			// Menu option interaction inputs 
#macro	PADCODE_RETURN			game_get_input_binding(PAD_RETURN)
#macro	PADCODE_FILE_DELETE		game_get_input_binding(PAD_FILE_DELETE)
#macro	PADCODE_ADVANCE			game_get_input_binding(PAD_ADVANCE)			// Textbox inputs 
#macro	PADCODE_LOG				game_get_input_binding(PAD_LOG)

// A shorten-downed version that returns the volume for each of the four groups; the bottom three being 
// influenced by what the current global volume is (Values all range from 0 to 1).
#macro	GET_GLOBAL_VOLUME		game_get_group_volume(GLOBAL_VOLUME)
#macro	GET_MUSIC_VOLUME		game_get_group_volume(MUSIC_VOLUME)
#macro	GET_SOUND_VOLUME		game_get_group_volume(SOUND_VOLUME)
#macro	GET_FOOTSTEP_VOLUME		game_get_group_volume(FOOTSTEP_VOLUME)
#macro	GET_AMBIENCE_VOLUME		game_get_group_volume(AMBIENCE_VOLUME)
#macro	GET_UI_VOLUME			game_get_group_volume(UI_VOLUME)

// Macros that provide an easy method of referencing various setting values without having to constantly
// typing out "global.gameSettings.*" for each of these values whenever they are needed.
#macro	RESOLUTION_SCALE		global.gameSettings.resolutionScale
#macro	ASPECT_RATIO			global.gameSettings.aspectRatio
#macro	BRIGHTNESS				global.gameSettings.brightness
#macro	GAMMA					global.gameSettings.gamma
#macro	TEXT_SPEED				global.gameSettings.textSpeed

// Macros that allow easy interfacing with the difficulty-reliant variables that aren't stored as
// individual bits in the "difficultyFlags" variable.
#macro	PLAYER_DAMAGE_MOD		global.gameSettings.pDamageModifier
#macro	ENEMY_DAMAGE_MOD		global.gameSettings.eDamageModifier
#macro	MIN_ITEM_SLOTS			global.gameSettings.minItemSlots
#macro	MAX_ITEM_SLOTS			global.gameSettings.maxItemSlots

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
	// used when the game is in full-screen mode), the image's overall brightness, and the image's gamma level.
	resolutionScale :		0,
	aspectRatio :			0,
	brightness :			0,
	gamma :					0,
	
	// Much like the group of variables above, these will store setting values that can be represented by a
	// single bit, but for audio levels instead of various video setttings. Each is represented by a percentage
	// that is stored as a value between 0 and 1, determining the overall volume of the group they represent.
	globalVolume :			0,
	musicVolume :			0,
	soundVolume :			0,
	footstepVolume :		0,
	ambienceVolume :		0,
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
	
	// Item inventory size limits, which are determined by the game's combat difficulty. The absolute maximum
	// is 24 due to the "global.items" array (Which stores the player's item inventory) being implicitly set
	// to a size of 24 upon creation.
	minItemSlots :			0,
	maxItemSlots :			0,
	
	/// @description Function that borrows the name of the event it should be called from within the
	/// "obj_controller" object. It will clear out and deallocate any memory that was allocated by the
	/// player input binding buffer to prevent any leaks.
	cleanup : function(){
		buffer_delete(inputBindings);
	},
}

#endregion

#region Global functions related to the game settings struct

/// @description Loading in the games settings from the "settings.ini". This function can still be used if
/// that ini file doesn't exist since the "ini_read_*" functions allow foe default values to be set if they
/// can't read in the required values for whatever reason (Ex. the file doesn't exist or the section/key 
/// pair doesn't exist within the file).
function game_load_settings(){
	with(GAME_SETTINGS){
		ini_open("settings.ini");
		
		// First, all the bit flags are grabbed from the settings are applied to the value of 0. That way, 
		// the settings that were previously applied will be completely overwritten by this function loading 
		// the values in from the file, since they could possibly differ.
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
		aspectRatio =		ini_read_real(SECTION_VIDEO, "aspect_ratio", AR_SIXTEEN_BY_NINE);
		brightness =		ini_read_real(SECTION_VIDEO, "brightness", 0.4);
		gamma =				ini_read_real(SECTION_VIDEO, "gamma", 1.0);
		
		// Loading in the volume for each of the four main groups.
		globalVolume =		ini_read_real(SECTION_AUDIO, "global_volume", 1.0);
		musicVolume =		ini_read_real(SECTION_AUDIO, "music_volume", 0.75);
		soundVolume =		ini_read_real(SECTION_AUDIO, "sound_volume", 0.85);
		footstepVolume =	ini_read_real(SECTION_AUDIO, "footstep_volume", 0.8);
		ambienceVolume =	ini_read_real(SECTION_AUDIO, "ambience_volume",	0.9);
		uiVolume =			ini_read_real(SECTION_AUDIO, "ui_volume", 0.65);
		
		// Reading in and applying all player input bindings for the keyboard. If no values exists, the 
		// defaults at the end of each line will be what is set to the input's space in the "inputBindings" 
		// buffer.
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
		
		// Reading in and applying all player input bindings for the gamepad. If no values exists, the 
		// defaults at the end of each line will be what is set to the input's space in the "inputBindings" 
		// buffer.
		buffer_poke(inputBindings, PAD_GAME_RIGHT, buffer_u16,		ini_read_real(SECTION_GAMEPAD, "game_right",		gp_padr));
		buffer_poke(inputBindings, PAD_GAME_LEFT, buffer_u16,		ini_read_real(SECTION_GAMEPAD, "game_left",			gp_padl));
		buffer_poke(inputBindings, PAD_GAME_UP, buffer_u16,			ini_read_real(SECTION_GAMEPAD, "game_up",			gp_padu));
		buffer_poke(inputBindings, PAD_GAME_DOWN, buffer_u16,		ini_read_real(SECTION_GAMEPAD, "game_down",			gp_padd));
		buffer_poke(inputBindings, PAD_RUN, buffer_u16,				ini_read_real(SECTION_GAMEPAD, "run",				gp_face3));
		buffer_poke(inputBindings, PAD_INTERACT, buffer_u16,		ini_read_real(SECTION_GAMEPAD, "interact",			gp_face1));
		buffer_poke(inputBindings, PAD_READY_WEAPON, buffer_u16,	ini_read_real(SECTION_GAMEPAD, "ready_weapon",		gp_shoulderl));
		buffer_poke(inputBindings, PAD_USE_WEAPON, buffer_u16,		ini_read_real(SECTION_GAMEPAD, "use_weapon",		gp_face1));
		buffer_poke(inputBindings, PAD_AMMO_SWAP, buffer_u16,		ini_read_real(SECTION_GAMEPAD, "ammo_swap",			gp_face2));
		buffer_poke(inputBindings, PAD_RELOAD, buffer_u16,			ini_read_real(SECTION_GAMEPAD, "reload",			gp_face3));
		buffer_poke(inputBindings, PAD_FLASHLIGHT, buffer_u16,		ini_read_real(SECTION_GAMEPAD, "flashlight",		gp_face4));
		buffer_poke(inputBindings, PAD_LIGHT_SWAP, buffer_u16,		ini_read_real(SECTION_GAMEPAD, "light_swap",		gp_face2));
		buffer_poke(inputBindings, PAD_ITEMS, buffer_u16,			ini_read_real(SECTION_GAMEPAD, "items",				gp_select));
		buffer_poke(inputBindings, PAD_NOTES, buffer_u16,			ini_read_real(SECTION_GAMEPAD, "notes",				gp_shoulderlb));
		buffer_poke(inputBindings, PAD_MAPS, buffer_u16,			ini_read_real(SECTION_GAMEPAD, "maps",				gp_shoulderrb));
		buffer_poke(inputBindings, PAD_PAUSE, buffer_u16,			ini_read_real(SECTION_GAMEPAD, "pause",				gp_start));
		buffer_poke(inputBindings, PAD_MENU_RIGHT, buffer_u16,		ini_read_real(SECTION_GAMEPAD, "menu_right",		gp_padr));
		buffer_poke(inputBindings, PAD_MENU_LEFT, buffer_u16,		ini_read_real(SECTION_GAMEPAD, "menu_left",			gp_padl));
		buffer_poke(inputBindings, PAD_MENU_UP, buffer_u16,			ini_read_real(SECTION_GAMEPAD, "menu_up",			gp_padu));
		buffer_poke(inputBindings, PAD_MENU_DOWN, buffer_u16,		ini_read_real(SECTION_GAMEPAD, "menu_down",			gp_padd));
		buffer_poke(inputBindings, PAD_AUX_MENU_RIGHT, buffer_u16,	ini_read_real(SECTION_GAMEPAD, "aux_menu_right",	gp_shoulderlb));
		buffer_poke(inputBindings, PAD_AUX_MENU_LEFT, buffer_u16,	ini_read_real(SECTION_GAMEPAD, "aux_menu_left",		gp_shoulderrb));
		buffer_poke(inputBindings, PAD_SELECT, buffer_u16,			ini_read_real(SECTION_GAMEPAD, "select",			gp_face1));
		buffer_poke(inputBindings, PAD_RETURN, buffer_u16,			ini_read_real(SECTION_GAMEPAD, "return",			gp_face2));
		buffer_poke(inputBindings, PAD_FILE_DELETE, buffer_u16,		ini_read_real(SECTION_GAMEPAD, "file_delete",		gp_face3));
		buffer_poke(inputBindings, PAD_ADVANCE, buffer_u16,			ini_read_real(SECTION_GAMEPAD, "advance",			gp_face1));
		buffer_poke(inputBindings, PAD_LOG, buffer_u16,				ini_read_real(SECTION_GAMEPAD, "log",				gp_face3));
		
		// Loading in all the gamepad settings that aren't input constants stored in the input buffer
		// or flags that are all loaded in at the top of this function.
		vibrationIntensity =	ini_read_real(SECTION_GAMEPAD, "vibrate_intensity", 0.5);
		stickDeadzone =			ini_read_real(SECTION_GAMEPAD, "stick_deadzone",	0.25);
		triggerThreshold =		ini_read_real(SECTION_GAMEPAD, "trigger_threshold", 0.15);
		
		// Loading in the accessibility settings that aren't bit flags; storing them into the variables
		// that are responsible for said values during the game's runtime.
		textSpeed =				ini_read_real(SECTION_ACCESSIBILITY, "text_speed",	0.75);
		
		ini_close();
	}
	
	// 
	camera_initialize(0, 0, game_get_aspect_ratio_width(ASPECT_RATIO), game_get_aspect_ratio_height(ASPECT_RATIO), RESOLUTION_SCALE);
}

/// @description Saves the current configuration for the game's settings to the "settings.ini" file
/// stored in the game's appdata folder (This is the default destination for GameMaker when files are
/// created through code).
function game_save_settings(){
	with(GAME_SETTINGS){
		// First, the file has to be opened so the settings can be written to it. If this file doesn't
		// current exist, it will automatically be created by this function being called and then an
		// "ini_write_*" function being used before the ini reader is closed.
		ini_open("settings.ini");
		
		// The video settings are stored first in the section fittingly titled "[VIDEO]". Each non-flag
		// value is stored as the number that they are currently set to, and flags will be stored as 0s
		// or 1s depending on what the bitwise ANDing of the desire bits returns.
		ini_write_real(SECTION_VIDEO, "resolution_scale",			resolutionScale);
		ini_write_real(SECTION_VIDEO, "aspect_ratio",				aspectRatio);
		ini_write_real(SECTION_VIDEO, "fullscreen",					(settingFlags & (1 << FULL_SCREEN)));
		ini_write_real(SECTION_VIDEO, "vsync",						(settingFlags & (1 << VERTICAL_SYNC)));
		ini_write_real(SECTION_VIDEO, "gamma",						gamma);
		ini_write_real(SECTION_VIDEO, "bloom",						(settingFlags & (1 << BLOOM_EFFECT)));
		ini_write_real(SECTION_VIDEO, "chromatic_aberration",		(settingFlags & (1 << ABERRATION_EFFECT)));
		ini_write_real(SECTION_VIDEO, "film_grain",					(settingFlags & (1 << FILM_GRAIN_FILTER)));
		ini_write_real(SECTION_VIDEO, "scanlines",					(settingFlags & (1 << SCANLINE_FILTER)));
		
		// The audio settings come next; each non-flag value will be stored as a decimal between 0 and 1 
		// determining the percentage value for the given volume group before the global volume is taken 
		// into account.
		ini_write_real(SECTION_AUDIO, "global_volume",				globalVolume);
		ini_write_real(SECTION_AUDIO, "music_volume",				musicVolume);
		ini_write_real(SECTION_AUDIO, "play_music",					settingFlags & (1 << PLAY_MUSIC));
		ini_write_real(SECTION_AUDIO, "sound_volume",				soundVolume);
		ini_write_real(SECTION_AUDIO, "footstep_volume",			footstepVolume);
		ini_write_real(SECTION_AUDIO, "ambience_volume",			ambienceVolume);
		ini_write_real(SECTION_AUDIO, "ui_volume",					uiVolume);
		
		// Writes all of the keyboard constants used by the player in their input configuation for
		// the game's various actions that can be triggered when the game allows it and the player
		// presses/holds the necessary input(s).
		ini_write_real(SECTION_KEYBOARD, "game_right",				buffer_peek(inputBindings, KEY_GAME_RIGHT, buffer_u16));
		ini_write_real(SECTION_KEYBOARD, "game_left",				buffer_peek(inputBindings, KEY_GAME_LEFT, buffer_u16));
		ini_write_real(SECTION_KEYBOARD, "game_up",					buffer_peek(inputBindings, KEY_GAME_UP, buffer_u16));
		ini_write_real(SECTION_KEYBOARD, "game_down",				buffer_peek(inputBindings, KEY_GAME_DOWN, buffer_u16));
		ini_write_real(SECTION_KEYBOARD, "run",						buffer_peek(inputBindings, KEY_RUN, buffer_u16));
		ini_write_real(SECTION_KEYBOARD, "interact",				buffer_peek(inputBindings, KEY_INTERACT, buffer_u16));
		ini_write_real(SECTION_KEYBOARD, "ready_weapon",			buffer_peek(inputBindings, KEY_READY_WEAPON, buffer_u16));
		ini_write_real(SECTION_KEYBOARD, "use_weapon",				buffer_peek(inputBindings, KEY_USE_WEAPON, buffer_u16));
		ini_write_real(SECTION_KEYBOARD, "ammo_swap",				buffer_peek(inputBindings, KEY_AMMO_SWAP, buffer_u16));
		ini_write_real(SECTION_KEYBOARD, "reload",					buffer_peek(inputBindings, KEY_RELOAD, buffer_u16));
		ini_write_real(SECTION_KEYBOARD, "flashlight",				buffer_peek(inputBindings, KEY_FLASHLIGHT, buffer_u16));
		ini_write_real(SECTION_KEYBOARD, "light_swap",				buffer_peek(inputBindings, KEY_LIGHT_SWAP, buffer_u16));
		ini_write_real(SECTION_KEYBOARD, "items",					buffer_peek(inputBindings, KEY_ITEMS, buffer_u16));
		ini_write_real(SECTION_KEYBOARD, "notes",					buffer_peek(inputBindings, KEY_NOTES, buffer_u16));
		ini_write_real(SECTION_KEYBOARD, "maps",					buffer_peek(inputBindings, KEY_MAPS, buffer_u16));
		ini_write_real(SECTION_KEYBOARD, "pause",					buffer_peek(inputBindings, KEY_PAUSE, buffer_u16));
		ini_write_real(SECTION_KEYBOARD, "menu_right",				buffer_peek(inputBindings, KEY_MENU_RIGHT, buffer_u16));
		ini_write_real(SECTION_KEYBOARD, "menu_left",				buffer_peek(inputBindings, KEY_MENU_LEFT, buffer_u16));
		ini_write_real(SECTION_KEYBOARD, "menu_up",					buffer_peek(inputBindings, KEY_MENU_UP, buffer_u16));
		ini_write_real(SECTION_KEYBOARD, "menu_down",				buffer_peek(inputBindings, KEY_MENU_DOWN, buffer_u16));
		ini_write_real(SECTION_KEYBOARD, "aux_menu_right",			buffer_peek(inputBindings, KEY_AUX_MENU_RIGHT, buffer_u16));
		ini_write_real(SECTION_KEYBOARD, "aux_menu_left",			buffer_peek(inputBindings, KEY_AUX_MENU_LEFT, buffer_u16));
		ini_write_real(SECTION_KEYBOARD, "select",					buffer_peek(inputBindings, KEY_SELECT, buffer_u16));
		ini_write_real(SECTION_KEYBOARD, "return",					buffer_peek(inputBindings, KEY_RETURN, buffer_u16));
		ini_write_real(SECTION_KEYBOARD, "file_delete",				buffer_peek(inputBindings, KEY_FILE_DELETE, buffer_u16));
		ini_write_real(SECTION_KEYBOARD, "advance",					buffer_peek(inputBindings, KEY_ADVANCE, buffer_u16));
		ini_write_real(SECTION_KEYBOARD, "log",						buffer_peek(inputBindings, KEY_LOG, buffer_u16));
		
		// Just like above, the player's input configuration is stored into the ini file. However,
		// this is for the gamepad input configuration and the above code is for the default input
		// method (The keyboard) configuration.
		ini_write_real(SECTION_GAMEPAD, "game_right",				buffer_peek(inputBindings, PAD_GAME_RIGHT, buffer_u16));
		ini_write_real(SECTION_GAMEPAD, "game_left",				buffer_peek(inputBindings, PAD_GAME_LEFT, buffer_u16));
		ini_write_real(SECTION_GAMEPAD, "game_up",					buffer_peek(inputBindings, PAD_GAME_UP, buffer_u16));
		ini_write_real(SECTION_GAMEPAD, "game_down",				buffer_peek(inputBindings, PAD_GAME_DOWN, buffer_u16));
		ini_write_real(SECTION_GAMEPAD, "run",						buffer_peek(inputBindings, PAD_RUN, buffer_u16));
		ini_write_real(SECTION_GAMEPAD, "interact",					buffer_peek(inputBindings, PAD_INTERACT, buffer_u16));
		ini_write_real(SECTION_GAMEPAD, "ready_weapon",				buffer_peek(inputBindings, PAD_READY_WEAPON, buffer_u16));
		ini_write_real(SECTION_GAMEPAD, "use_weapon",				buffer_peek(inputBindings, PAD_USE_WEAPON, buffer_u16));
		ini_write_real(SECTION_GAMEPAD, "ammo_swap",				buffer_peek(inputBindings, PAD_AMMO_SWAP, buffer_u16));
		ini_write_real(SECTION_GAMEPAD, "reload",					buffer_peek(inputBindings, PAD_RELOAD, buffer_u16));
		ini_write_real(SECTION_GAMEPAD, "flashlight",				buffer_peek(inputBindings, PAD_FLASHLIGHT, buffer_u16));
		ini_write_real(SECTION_GAMEPAD, "light_swap",				buffer_peek(inputBindings, PAD_LIGHT_SWAP, buffer_u16));
		ini_write_real(SECTION_GAMEPAD, "items",					buffer_peek(inputBindings, PAD_ITEMS, buffer_u16));
		ini_write_real(SECTION_GAMEPAD, "notes",					buffer_peek(inputBindings, PAD_NOTES, buffer_u16));
		ini_write_real(SECTION_GAMEPAD, "maps",						buffer_peek(inputBindings, PAD_MAPS, buffer_u16));
		ini_write_real(SECTION_GAMEPAD, "pause",					buffer_peek(inputBindings, PAD_PAUSE, buffer_u16));
		ini_write_real(SECTION_GAMEPAD, "menu_right",				buffer_peek(inputBindings, PAD_MENU_RIGHT, buffer_u16));
		ini_write_real(SECTION_GAMEPAD, "menu_left",				buffer_peek(inputBindings, PAD_MENU_LEFT, buffer_u16));
		ini_write_real(SECTION_GAMEPAD, "menu_up",					buffer_peek(inputBindings, PAD_MENU_UP, buffer_u16));
		ini_write_real(SECTION_GAMEPAD, "menu_down",				buffer_peek(inputBindings, PAD_MENU_DOWN, buffer_u16));
		ini_write_real(SECTION_GAMEPAD, "aux_menu_right",			buffer_peek(inputBindings, PAD_AUX_MENU_RIGHT, buffer_u16));
		ini_write_real(SECTION_GAMEPAD, "aux_menu_left",			buffer_peek(inputBindings, PAD_AUX_MENU_LEFT, buffer_u16));
		ini_write_real(SECTION_GAMEPAD, "select",					buffer_peek(inputBindings, PAD_SELECT, buffer_u16));
		ini_write_real(SECTION_GAMEPAD, "return",					buffer_peek(inputBindings, PAD_RETURN, buffer_u16));
		ini_write_real(SECTION_GAMEPAD, "file_delete",				buffer_peek(inputBindings, PAD_FILE_DELETE, buffer_u16));
		ini_write_real(SECTION_GAMEPAD, "advance",					buffer_peek(inputBindings, PAD_ADVANCE, buffer_u16));
		ini_write_real(SECTION_GAMEPAD, "log",						buffer_peek(inputBindings, PAD_LOG, buffer_u16));
		
		// Saving the gamepad settings that aren't input constants; the vibration strength, stick 
		// deadzone region, and trigger threshold for input activation, respectively.
		ini_write_real(SECTION_GAMEPAD, "vibrate_intensity",		vibrationIntensity);
		ini_write_real(SECTION_GAMEPAD, "stick_deadzone",			stickDeadzone);
		ini_write_real(SECTION_GAMEPAD, "trigger_threshold",		triggerThreshold);
		
		// Finally, write all of the values for the accessibility settings in the game to the file.
		ini_write_real(SECTION_ACCESSIBILITY, "text_speed",			textSpeed);
		ini_write_real(SECTION_ACCESSIBILITY, "objective_hints",	(settingFlags & (1 << OBJECTIVE_HINTS)));
		ini_write_real(SECTION_ACCESSIBILITY, "item_highlights",	(settingFlags & (1 << ITEM_HIGHLIGHTING)));
		ini_write_real(SECTION_ACCESSIBILITY, "interact_prompt",	(settingFlags & (1 << INTERACTION_PROMPTS)));
		ini_write_real(SECTION_ACCESSIBILITY, "is_run_toggle",		(settingFlags & (1 << IS_RUN_TOGGLE)));
		ini_write_real(SECTION_ACCESSIBILITY, "is_aim_toggle",		(settingFlags & (1 << IS_AIM_TOGGLE)));
		ini_write_real(SECTION_ACCESSIBILITY, "swap_movement",		(settingFlags & (1 << SWAP_MOVEMENT_STICK)));
		
		ini_close();
	}
}

/// @description Sets the desired bit in the "settingFlags" variable to the value (Either 0 or 1) determined 
/// by the state of the "flagState" boolean (False = 0, True = any number >= 1). 
/// @param {Real}	flagID
/// @param {Real}	flagState
function game_set_setting_flag(_flagID, _flagState){
	with(GAME_SETTINGS){
		if (_flagState)	{settingFlags = settingFlags | (_flagState << _flagID);}
		else			{settingFlags = settingFlags & ~(1 << _flagID);}
	}
}

/// @description Gets the value for the bit stored in the location specified by the value passed into 
/// the "_flagID" argument space; returning a value of 1 for the setting being enabled, or a 0 for a
/// setting that has been disabled by the player.
/// @param {Real}	flagID
function game_get_setting_flag(_flagID){
	with(GAME_SETTINGS) {return (settingFlags & (1 << _flagID));}
}

/// @description Gets the value for the bit in the "difficultyFlags" variable at the posiiton specified 
/// by the value given as an argument. If it's a 1, the flag for that difficulty setting is toggled to 
/// be active. Otherwise, it should be a value of zero.
/// @param {Real}	flagID
function game_get_difficulty_flag(_flagID){
	with(GAME_SETTINGS) {return (difficultyFlags & (1 << _flagID));}
}

/// @description Assigns a new keyboard/gamepad constant to the buffer that stores all the player's
/// input bindings at an offset inside (Offset meaning the "_inputID" variable's value) the buffer.
/// @param {Real}	inputID
/// @param {Real}	inputConstant
function game_set_input_binding(_inputID, _inputConstant){
	with(GAME_SETTINGS) {buffer_poke(inputBindings, _inputID, buffer_u16, _inputConstant);}
}

/// @description Grabs the input constant that is stored within the buffer at the specified offset;
/// that offset being the value provided for the "_inputID"'s value.
/// @param {Real}	inputID
function game_get_input_binding(_inputID){
	with(GAME_SETTINGS) {return buffer_peek(inputBindings, _inputID, buffer_u16);}
}

/// @description Returns the width for the game's viewport for the currently active aspect ratio.
/// This value is independent to the window's actual width, which is a combination of this and the
/// current scale value when the game isn't in fullscreen mode.
/// @param {Real}	arConstant
function game_get_aspect_ratio_width(_arConstant){
	switch(_arConstant){
		default: // Undefined aspect ratios are considered 16:9 as a failsafe.
		case AR_SIXTEEN_BY_NINE:	return 320;
		case AR_SIXTEEN_BY_TEN:		return 320;
		case AR_THREE_BY_TWO:		return 324;
		case AR_SEVEN_BY_THREE:		return 420;
	}
}

/// @description Returns the height for the game's viewport for the currently active aspect ratio.
/// This value is independent to the window's actual height, which is a combination of this and the
/// current scale value when the game isn't in fullscreen mode.
/// @param {Real}	arConstant
function game_get_aspect_ratio_height(_arConstant){
	switch(_arConstant){
		default: // Undefined aspect ratios are considered 16:9 as a failsafe.
		case AR_SEVEN_BY_THREE:
		case AR_SIXTEEN_BY_NINE:	return 180;
		case AR_SIXTEEN_BY_TEN:		return 200;
		case AR_THREE_BY_TWO:		return 216;
	}
}

/// @description Gets the percentage value for the desired audio group. All audio groups besides the
/// global volume level will be affected by the value of said global volume, and the music volume can
/// be set to 0 if the player has disabled background music playback.
/// @param {Real}	volumeGroup
function game_get_group_volume(_volumeGroup){
	with(GAME_SETTINGS){
		switch(_volumeGroup){
			case GLOBAL_VOLUME:		return globalVolume;
			case MUSIC_VOLUME:		return (settingFlags & (1 << PLAY_MUSIC)) ? (globalVolume * musicVolume) : 0;
			case SOUND_VOLUME:		return (globalVolume * soundVolume);
			case FOOTSTEP_VOLUME:	return (globalVolume * footstepVolume);
			case AMBIENCE_VOLUME:	return (globalVolume * ambienceVolume);
			case UI_VOLUME:			return (globalVolume * uiVolume);
			default:				return 0;
		}
	}
}

/// @description Sets up the "difficultyFlag" variable's necessary bits to reflect the combat difficulty
/// that was set by the value stored in the "_difficultyFlag" argument space. It also clears any of the
/// bits that go unused by that difficulty configuration to avoid features of one difficulty being used
/// in another that it isn't supposed to (Ex. Limited saving being enabled on "Forgiving" and "Standard"
/// difficulty because the bit wasn't cleared).
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
				minItemSlots = 10;
				maxItemSlots = 24;		// (24 - 10) / 2 = 7 available inventory expansion pickups.
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
				minItemSlots = 8;
				maxItemSlots = 20;		// (20 - 12) / 2 = 6 available inventory expansion pickups.
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
				minItemSlots = 8;
				maxItemSlots = 16;		// (16 - 8) / 2 = 4 available inventory expansion pickups.
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
				minItemSlots = 6;
				maxItemSlots = 12;		// (12 - 6) / 2 = 3 available inventory expansion pickups.
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
				pDamageModifier = 0.6;	// Player takes a 40% cut in overall damage output; enemies see a
				eDamageModifier = 1.6;	// 60% boost in their damage to the player.
				minItemSlots = 4;
				maxItemSlots = 10;		// (10 - 4) / 2 = 3 available inventory expansion pickups.
				break;
		}
	}
}

/// @description Much like the above function, this will apply various difficulty flag configurations to
/// the "difficultyFlags" variable; clearing unused bits for a given difficulty configuration when required. 
/// However, unlike the combat difficulty setting function, these flags all relate to the difficulty of the 
/// various puzzles found throughout the game that impede player progress until they're solved.
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