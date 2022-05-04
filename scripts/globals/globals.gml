/// @description Initializes all global variables that aren't bound to any specific object, but are instead 
/// used all throughout the code for various different tasks and reasons.

#region Game state struct

// A simple struct that contains the value for the game's current and previous states, respectively. On top of
// that, it contains the only possible function that should be used to manipulate those state values; preventing
// any possible accidental overwrites to these states from outside objects.
global.gameState = {
	// The two storage variables for the game's current state and previous states, respectively.
	curState :			GameState.NoState,
	lastState :			GameState.NoState,
	
	/// @description A simple function that changes the game's current state to one of four valid options:
	/// "InGame", "InMenu", "Cutscene", and "Paused", respectively. The order of these states determines their
	/// priority, which means setting the state from "Paused" to "InGame" can only be done if the function's
	/// "highPriority" flag is set to true.
	/// @param gameState
	/// @param highPriority
	set_state : function(_gameState, _highPriority = false){
		if (_highPriority || curState < _gameState){
			lastState = curState; // Store the previous game state in case it needs to be referenced later.
			curState = clamp(_gameState, GameState.InGame, GameState.Paused);
		}
	}
}

#endregion

#region Audio Listener struct

// A struct that is responsible for maintaining the position of Game maker's audio listener on a per-frame
// basis. Allows for directional audio to be used within the game's environment; making it more immersive
// and having the audio better represent what and where it's being played from within the game world.
global.audioListener = {
	// The main variables that allow the audio listener to be shared between multiple "instances;" (Ex. The
	// camera uses the audio listener during cutscenes and the player object uses it during normal gameplay)
	// updating the listener position to match up with the position of that object over an in-game frame.
	linkedObject :		noone,
	x :					0,
	y :					0,
	
	/// @description Updates the audio listener's position at the end of a given frame. If there is an object
	/// currently linked with the audio listener, it's position will be set to that object's position before
	/// updating the listener position with the function. Otherwise, the audio listener's position will not
	/// change.
	end_step : function(){
		if (linkedObject != noone){
			x = linkedObject.x;
			y = linkedObject.y;
		}
		audio_listener_position(x, y, 0);
	},
	
	/// @description A simple function that overwrites what object is currently linked to the audio listener
	/// struct's positional data. If the object ID wasn't valid, the default value of "noone" will be used.
	/// @param objectID
	set_linked_object : function(_objectID){
		if (instance_exists(_objectID)) {linkedObject = _objectID;}
		else							{linkedObject = noone;}
	}
}

// 
audio_falloff_set_model(audio_falloff_linear_distance);
audio_listener_orientation(0, 0, 1, 0, -1, 0);

#endregion

#region Inventory globals

// 
global.itemData = encrypted_json_load("item_data.json", "");
// TODO -- Loading in the note data JSON file here

// Data structures that store the player's inventory. They are split into three unique catagories: general
// items, documents/notes, and maps of the game's various levels/areas. The items are stored in a standard
// array of a defined length; the current inventory size being a separate variable that limits how much of
// the array the player can access. The other two are data structures that are unique to Game Maker; a list
// for the notes, and a map for the maps, respectively.
global.items = array_create(24, noone);
global.notes = ds_list_create();
global.maps = noone;

// This value is responsible for limiting how much of the inventory the player has access to at any given
// time. This allows a single array to be initialized at the beginning of the game and remain unchanged in
// size; only this variable "changing" the size until the array's limit.
global.curItemInvSize = 0;

#endregion

#region Game setting globals

// A simple struct that contains a variable for each aspect of the game's code that can be altered by the
// player from within the game's settings menu. It includes various video, audio, control, and accessibility
// settings that can all be altered to the player's content. Specifically, they will be grouped within the
// settings menu as follows:
//
//	Video			(All variables on a single menu page)
//	Audio			(All variables on a single menu page)
//	Keyboard		(Variables split into two pages: A "Game" and "Menu" page for each type of binding)
//	Gamepad			(Variables split into three pages: A "Game" and "Menu" page for each binding, and a final "General" page for options that aren't input bindings)
//	Accessibility	(All variables on a single menu page)
// 
global.settings = {
	// --- Video Settings --- //
	aspectRatio :			AspectRatio.SixteenByNine,
	resolutionScale :		4,
	fullScreen :			false,
	brightness :			0.85,
	gamma :					0.9,
	bloomEffect :			true,
	abberationEffect :		true,
	filmGrainEffect :		true,
	scanlineEffect :		true,
	
	// --- Audio Settings --- //
	masterVolume :			1,
	musicVolume :			0.75,
	playMusic :				true,
	soundVolume :			0.85,
	guiVolume :				0.70,
	
	// These three variables will store the calculated values for the sound groups, which is the factor of
	// the group's volume and the game's master volume settings. Otherwise, this calculation would have to be
	// done for each sound whenever it's played, and that's a waste of time.
	trueMusicVolume :		0.75,
	trueSoundVolume :		0.85,
	trueGuiVolume :			0.70,
	
	// --- Keyboard Settings (In-Game) --- //
	keyGameRight :			vk_right,
	keyGameLeft :			vk_left,
	keyGameUp :				vk_up,
	keyGameDown :			vk_down,
	keyRun :				vk_shift,
							
	keyReadyWeapon :		vk_x,
	keyUseWeapon :			vk_z,
	keyReloadGun :			vk_r,
	keyAmmoSwap :			vk_control,
							
	keyInteract :			vk_z,
	keyFlashlight :			vk_f,
	keyLightSwap :			vk_control,
							
	keyItems :				vk_tab,
	keyNotes :				vk_n,
	keyMaps :				vk_m,
	keyPause :				vk_escape,
	
	// --- Keyboard Settings (Menus) --- //
	keyMenuRight :			vk_right,
	keyMenuLeft :			vk_left,
	keyMenuUp :				vk_up,
	keyMenuDown :			vk_down,
	keyAuxMenuRight :		vk_v,
	keyAuxMenuLeft :		vk_c,
							
	keySelect :				vk_z,
	keyReturn :				vk_x,
	keyFileDelete :			vk_d,
							
	keyAdvance :			vk_z,
	keyLog :				vk_x,
	
	// --- Gamepad Settings (In-Game) --- //
	gpadGameRight :			gp_padr,
	gpadGameLeft :			gp_padl,
	gpadGameUp :			gp_padu,
	gpadGameDown :			gp_padd,
	gpadRun :				gp_shoulderlb,
							
	gpadReadyWeapon :		gp_shoulderrb,
	gpadUseWeapon :			gp_face1,
	gpadReloadGun :			gp_face3,
	gpadAmmoSwap :			gp_face2,
							
	gpadInteract :			gp_face1,
	gpadFlashlight :		gp_face4,
	gpadLightSwap :			gp_face2,
							
	gpadItems :				gp_select,
	gpadNotes :				gp_shoulderl,
	gpadMaps :				gp_shoulderr,
	gpadPause :				gp_start,
	
	// --- Gamepad Settings (Menu) --- //
	gpadMenuRight :			gp_padr,
	gpadMenuLeft :			gp_padl,
	gpadMenuUp :			gp_padu,
	gpadMenuDown :			gp_padd,
	gpadAuxMenuRight :		gp_shoulderr,
	gpadAuxMenuLeft :		gp_shoulderl,
							
	gpadSelect :			gp_face1,
	gpadReturn :			gp_face2,
	gpadFileDelete :		gp_face4,
							
	gpadAdvance :			gp_face1,
	gpadLog :				gp_face3,
	
	// --- Gamepad Settings (General) --- //
	gpadVibration :			true,
	gpadVibrateIntesity :	1,
	gpadDeadzone :			0.25,
	gpadButtonThreshold :	0.1,
	
	// --- Accessibility Settings --- //
	textSpeed :				1.75,
							
	objectiveHints :		false,
	itemHighlighting :		false,
	interactionPrompts :	false,
							
	isRunToggle :			false,
	isAimToggle :			false,
	
	/// @description Updates the master volume, which affects all volume groups when it is updated; those
	/// group volumes being the factor of the volume for currently for that group, and the master volume's
	/// current value--both of which should range between zero and one.
	/// @param masterVolume
	update_master_volume : function(_masterVolume){
		masterVolume =		clamp(_masterVolume, 0, 1);
		trueSoundVolume =	masterVolume * soundVolume;
		trueGuiVolume =		masterVolume * guiVolume;
		
		// When it comes to setting the music's volume, the flag for disabling music is checked. If that flag
		// is set to true, the music volume will remain at 0. Otherwise, the standard volume will be set
		// to match the master volume.
		if (playMusic)	{trueMusicVolume = masterVolume * musicVolume;}
		else			{trueMusicVolume = 0;}
	},
	
	/// @description Updates the music volume, specifically, which is unique in the fact that is can have its
	/// audio group completely disabled from playing at all--doing so by setting the volume to 0 so that
	/// playback isn't actually halted or reset from disabling/enabling music.
	/// @param musicVolume
	/// @param playMusic
	update_music_volume : function(_musicVolume, _playMusic){
		musicVolume =		clamp(_musicVolume, 0, 1);
		playMusic =			_playMusic;
		if (_playMusic)		{trueMusicVolume = masterVolume * musicVolume;}
		else				{trueMusicVolume = 0;} // Mute the music if it's been disabled
	},
	
	/// @description A simple function that updates the playback volume for nearly all sound effects within 
	/// the game. GUI sounds are excempt since they have their own volume group.
	/// @param soundVolume
	update_sound_volume : function(_soundVolume){
		soundVolume =		clamp(_soundVolume, 0, 1);
		trueSoundVolume =	masterVolume * soundVolume;
	},
	
	/// @description A simple function that updates the playback volume for all menu/ui sound effects.
	/// @param guiVolume
	update_gui_volume : function(_guiVolume){
		guiVolume =			clamp(_guiVolume, 0, 1);
		trueSoundVolume =	masterVolume * guiVolume;
	}
}

// A simple struct that contains information about the currently connected gamepad. Namely, it's device ID,
// which determines whether it's an XInput or a Direct Input style gamepad. This distinction along with the 
// variable storing the gamepad's "info" (it's guid and description string) will determine what icons are 
// paired with the controller for the GUI's control information displays.
global.gamepad = {
	// Variables relating to the gamepad; the first two explained in the comment above. The third variable
	// is simply a flag that lets the game know whether or not the gamepad is actually in use by the player.
	// If so, the input is checked on the controller instead of the keyboard. 
	deviceID :		-1,
	info :			"",
	isActive :		false,
	
	/// @description A simple function that is called every single possible in-game frame in order to allow
	/// controller hotswapping to work within the game. In short, it does nothing if no device exists, and
	/// it will switch the "isActive" flag to true or false depending on the last detected input.
	step : function(){
		if (deviceID == -1) {return;}
		
		if (!isActive && gamepad_any_button(deviceID, true)){
			control_info_set_icons_gamepad(info);
			isActive = true;
		} else if (isActive && keyboard_check_pressed(vk_anykey)){
			control_info_set_icons_keyboard();
			isActive = false;
		}
	},
	
	/// @description A simple function that returns the mapping data used by various support controllers 
	/// that are of the Direct Input variety. (Ex. Sony Controllers and the Switch Pro Controller) This
	/// string ensures that SDL will map the input to the correct buttons on the controller.
	/// @param info
	get_gamepad_mapping_data : function(_info){
		switch(_info){
			case SONY_DUALSHOCK_FOUR:	return info + ",a:b1,b:b2,x:b0,y:b3,leftshoulder:b4,rightshoulder:b5,lefttrigger:a3,righttrigger:a4,guide:b13,start:b9,leftstick:b10,rightstick:b11,dpup:h0.1,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,leftx:a0,lefty:a1,rightx:a2,righty:a5,back:b12,";
			case SONY_DUALSENSE:		return info + ",a:b1,b:b2,x:b0,y:b3,leftshoulder:b4,rightshoulder:b5,lefttrigger:a3,righttrigger:a4,guide:b13,start:b9,leftstick:b10,rightstick:b11,dpup:h0.1,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,leftx:a0,lefty:a1,rightx:a2,righty:a5,back:b12,";
			default:					return "";
		}
	}
}

#endregion

#region Gameplay difficulty/modifiers global struct

// An extremely important struct that stores all of the difficulty settings for the game. It can manipulate
// the player's item inventory starting/maximum size, the location and availability of items in the world,
// the damage values of both the player and enemies, and also add/remove certain gameplay mechanics to make
// the game easier or more difficulty depending on the set combat difficulty.
global.gameplay = {
	// The general settings for the combat and puzzle difficulty, respectively. They are separated much like
	// in Silent Hill 2 and 3's difficulty selections to allow the player to increase/decrease one without
	// having it effect the other as well. In short, allows better fine tuning of difficulty settings of
	// differing aspects of the game.
	combatDifficulty :		Difficulty.NotSet,
	puzzleDifficulty :		Difficulty.NotSet,		// Can only be "Forgiving, Standard, or Punishing"
	
	// Two variables that simply store the range of slots allowed to the player at any given time relative
	// to their current "Combat Difficulty" setting. The first determines the item inventory initial size, 
	// and the second stores the slot limit.
	startingItemInvSize :	0,
	maximumItemInvSize :	0,
	
	// Variables that are responsible for altering the damage output for the player and enemy based on their
	// respective damage calculations. They will simply be multiplied against those values to either increase
	// or decrease the ending values.
	pDamageModifier :		0,
	eDamageModifier :		0,
	
	// Flags that modifiy the gameplay even further than just manipulating damage values or the inventory
	// size limit. Instead, toggling these flags will change how the game works in general; adding and
	// removing certain gameplay mechanics. (Ex. Limited saving, item repairing, and health regeneration)
	pStartingPistol	:		false,		// Starts the player off with a unique infinite ammo pistol.						("Story" difficulty only)
	pRegenHitpoints :		false,		// Enables the player's hitpoints to always slowly regenerate when out of combat.	("Story" difficulty only)
	pItemRepairs :			false,		// Makes weaponry/items require repairs in order to maintain usability.
	pLimitedSaving :		false,		// Enables the requirement of a "Cassette Tape" to be used per game save.
	pOneLifeMode :			false,		// Makes it so saving is completely disabled; with any game over ending the current playthrough.
	
	/// @description Initializing the gameplay struct to match what is required for the game's easiest difficulty
	/// setting, "Forgiving". player damage is heavily amplified; enemy damage is heavily reduced; the player 
	/// is granted a starting pistol with infinite ammunition, and they will slowly regenerate their health
	/// when out of combat. Puzzle difficulty is set independently of this function and the gameplay struct's
	/// setup.
	/// @param puzzleDifficulty
	initialize_difficulty_forgiving : function(_puzzleDifficulty){
		// Initialize the combat difficulty to store the numerical index for "Forgiving" difficulty; the
		// puzzle difficulty setting being determined outside of this function and carried over by the
		// function's only argument value.
		combatDifficulty =		Difficulty.Forgiving;
		puzzleDifficulty =		_puzzleDifficulty;
		
		// Set the starting item inventory size to be the largest of the difficulty options; that being 10
		// available slots. Also, the maximum size will be the maximum size of the global array that stores
		// the actual item inventory data; that value being 24.
		startingItemInvSize =	10;
		maximumItemInvSize =	24;
		global.curItemInvSize = startingItemInvSize;
		
		// Dramatically boost the damage out for the player to be DOUBLE whatever was actually calcuated using
		// the player damage formula. Then, reduce the enemy damage to be only half of whatever was calculated
		// using their respective damage formula.
		pDamageModifier =		2.0;
		eDamageModifier =		0.5;
		
		// Since "forgiving" was the selected combat difficulty, the player will be granted the ability to
		// regenerate slowly when they are outside of combat, and they will be given a unique starting pistol
		// that consume no ammunition.
		pStartingPistol =		true;
		pRegenHitpoints =		true;
		
		// Loads in the world data that is specific to "Foprgiving" difficulty. However, it only provides the 
		// general data and things like puzzle/important items and their locations can be further changed
		// based on the set puzzle difficulty--these changes being done in Game Maker's room editor instead
		// of this general purpose data file.
		global.worldItemData = encrypted_json_load("world_data_forgiving.json", "");
	},
	
	/// @description Initializes the gameplay struct to not affect that gameplay at all. (Aside from how
	/// many slots are available to the player in their item inventory) This is done because "Standard" 
	/// difficulty is the base difficulty for the game, and no modifications are necessary to make this 
	/// difficulty level match that condition.
	/// @param puzzleDifficulty
	initialize_difficulty_standard : function(_puzzleDifficulty){
		// Set the index value for the combat difficulty to be set to "Standard", and set the puzzle difficulty
		// to be whatever value of the three choices was selected by the player upon starting a new game.
		combatDifficulty =		Difficulty.Standard;
		puzzleDifficulty =		_puzzleDifficulty;
		
		// Set the starting inventory size to be 8 slots, with the maximum possible value being 20 slots
		// once all available Item Pouches have been collected in the game world.
		startingItemInvSize =	8;
		maximumItemInvSize =	20;
		global.curItemInvSize = startingItemInvSize;
		
		// Initialize the damage modifiers for both player damage and enemy damage to have no effect on the
		// standard calculation for said damage output types since standard doesn't change damage values.
		pDamageModifier =		1.0;
		eDamageModifier =		1.0;
		
		// NOTE -- No gameplay modification flags are set on this difficulty.
		
		// Loads in the world data that is specific to "Standard" difficulty. However, it only provides the 
		// general data and things like puzzle/important items and their locations can be further changed
		// based on the set puzzle difficulty--these changes being done in Game Maker's room editor instead
		// of this general purpose data file.
		//global.worldItemData = encrypted_json_load("world_data_standard.json", "");
	},
	
	/// @description 
	/// @param puzzleDifficulty
	initialize_difficulty_punishing : function(_puzzleDifficulty){
		// 
		combatDifficulty =		Difficulty.Punishing;
		puzzleDifficulty =		_puzzleDifficulty;
		
		// 
		startingItemInvSize =	8;
		maximumItemInvSize =	16;
		global.curItemInvSize = startingItemInvSize;
		
		// Reduce the damage output for the player by a factor of 25%; augmenting all damage output for enemies
		// by the same factor. This makes enemies more punishing and the player overall much weaker without
		// having to change enemy health pools.
		pDamageModifier =		0.75;
		eDamageModifier =		1.25;
		
		// Only toggle the flag that makes item durability management a mechanic within the game. This will
		// add a little bit more of a challenge to the standard gameplay without being as punishing as limited
		// save, which is a mechanic saved for "Nightmare" difficulty.
		pItemRepairs =			true;
		
		// Loads in the world data that is specific to "Punishing" difficulty. However, it only provides the 
		// general data and things like puzzle/important items and their locations can be further changed
		// based on the set puzzle difficulty--these changes being done in Game Maker's room editor instead
		// of this general purpose data file.
		global.worldItemData = encrypted_json_load("world_data_punishing.json", "");
	},
	
	/// @description 
	/// @param puzzleDifficulty
	initialize_difficulty_nightmare : function(_puzzleDifficulty){
		// 
		combatDifficulty =		Difficulty.Punishing;
		puzzleDifficulty =		_puzzleDifficulty;
		
		// 
		startingItemInvSize =	6;
		maximumItemInvSize =	12;
		global.curItemInvSize = startingItemInvSize;
		
		// 
		pDamageModifier =		0.5;
		eDamageModifier =		1.5;
		
		// 
		pItemRepairs =			true;
		pLimitedSaving =		true;
		
		// Loads in the world data that is specific to "Nightmare" difficulty. However, it only provides the 
		// general data and things like puzzle/important items and their locations can be further changed
		// based on the set puzzle difficulty--these changes being done in Game Maker's room editor instead
		// of this general purpose data file.
		global.worldItemData = encrypted_json_load("world_data_nightmare.json", "");
	},
	
	/// @description
	/// @param puzzleDifficulty
	initialize_difficulty_one_life_mode : function(_puzzleDifficulty){
		// Much like the other four difficulty initialization functions, the combat difficulty's value is
		// implicitly set to the proper value while the puzzle difficulty is one of the three possible
		// options that is the player's choosing independent of the main difficulty level.
		combatDifficulty =		Difficulty.OneLifeMode;
		puzzleDifficulty =		_puzzleDifficulty;
		
		// Set up the inventory to be the smallest size that it can possibly be relative to the five difficulty
		// levels; starting with a measly four slots and maxing out at only ten slots total.
		startingItemInvSize =	4;
		maximumItemInvSize =	10;
		global.curItemInvSize = startingItemInvSize;
		
		// Contrary to the previous difficulty reducing the damage output for the player by half of their
		// standard amount, this difficulty will keep the standard damage values for the player. However, all
		// enemies will have their damage outputs doubled; making them extremely powerful and punishing.
		pDamageModifier =		1.0;
		eDamageModifier =		2.0;
		
		// Set the flag that enables item durability degredation AND the flag that sets the game into "One
		// Life Mode", which simply disables all save points and prevents reloading upon death. Since saving
		// is disabled, the flag for limiting saves is pointless and not set on this difficulty.
		pItemRepairs =			true;
		pOneLifeMode =			true;
		
		// Loads in the world data that is specific to "One Life Mode" difficulty. However, it only provides
		// the general data and things like puzzle/important items and their locations can be further changed
		// based on the set puzzle difficulty--these changes being done in Game Maker's room editor instead
		// of this general purpose data file.
		global.worldItemData = encrypted_json_load("world_data_one_life_mode.json", "");
	}
}

#endregion

#region Outline shader globals

// A simple struct that contains all the data necessary for using the outline shader from anywhere within
// the project's code. Otherwise, these variables would have to be initialized on a per-object basis for
// each one that uses the shader, and that's not the most efficient use of memory.
global.shaderOutline = {
	// Stores the unique number given to the outline shader by Game Maker during compilation. Makes the code
	// invloving this shader look neater and more readable overall.
	ID :				shd_outline,
	
	// Grab and store each of the shader's unique uniform's location values given by the shader. In short, 
	// this returns an index that the shader will use to reference the uniform's place in memory when the 
	// shader is actively running.
	sPixelWidth :		shader_get_uniform(shd_outline, "pixelWidth"),
	sPixelHeight :		shader_get_uniform(shd_outline, "pixelHeight"),
	sDrawOutline :		shader_get_uniform(shd_outline, "drawOutline"),
	sDrawCorners :		shader_get_uniform(shd_outline, "drawCorners"),
	sColor :			shader_get_uniform(shd_outline, "color"),
	
	// Store the last font and outline color used by this shader in order to prevent redundant overwrites
	// that end up containing the same exact data in the end. (Ex. changing to the same font, but grabbing
	// the texel size values anyway, and setting the shader's color to the same value)
	curFont :			-1,
	curOutlineColor :	array_create(0, 0),
}

// Stores the ID values for each font resource's texture for easy and quick reference whenever the outline
// shader is in use. Otherwise, these IDs would need to be retrieved every frame within the code.
global.fontTextures = ds_map_create();
ds_map_add(global.fontTextures, font_gui_small,		font_get_texture(font_gui_small));
ds_map_add(global.fontTextures, font_gui_medium,	font_get_texture(font_gui_medium));
ds_map_add(global.fontTextures, font_gui_large,		font_get_texture(font_gui_large));

#endregion

#region Feathering shader globals

// A very simple struct that contains all the data required to use and access the feathering shader's effects.
// In short, they only store the uniform locations for the starting fade coordinates and ending coordinates,
// respectively.
global.shaderFeathering = {
	// Stores the unique number given to the outline shader by Game Maker during compilation. Makes the code
	// invloving this shader look neater and more readable overall.
	ID : shd_feathering,
	
	// Grab and store each of the shader's unique uniform's location values given by the shader. In short, 
	// this returns an index that the shader will use to reference the uniform's place in memory when the 
	// shader is actively running.
	sFadeStart :		shader_get_uniform(shd_feathering, "fadeStart"),
	sFadeEnd :			shader_get_uniform(shd_feathering, "fadeEnd"),
}

#endregion

#region "Other" global variables

// A global list that stores pointers to all the currently existing interact components within the current
// room. This allows all of them to easily be iterated through and processed for when there is an interact
// check performed by the player object.
global.interactables = ds_list_create();

// The data structure that is responsible for storing all the data for items that can be picked up within
// the game world. Each element stores the name of the item, room its found in, quantity, and durability.
// Each difficulty will have a unique file for their world item data, since item locations and certain items
// in general are different on a per-difficulty basis.
global.worldItemData = -1;

#endregion
