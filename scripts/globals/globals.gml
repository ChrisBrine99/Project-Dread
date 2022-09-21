/// @description Initializes all global variables that aren't bound to any specific object, but are instead 
/// used all throughout the code for various different tasks and reasons.

#region Game state struct

// A simple struct that contains the value for the game's current and previous states, respectively. On top of
// that, it contains the only possible function that should be used to manipulate those state values; preventing
// any possible accidental overwrites to these states from outside objects.
/*global.gameState = {
	// The two storage variables for the game's current state and previous states, respectively.
	curState :			GameState.NoState,
	lastState :			GameState.NoState,
	
	/// @description A simple function that changes the game's current state to one of four valid options:
	/// "InGame", "InMenu", "Cutscene", and "Paused", respectively. The order of these states determines their
	/// priority, which means setting the state from "Paused" to "InGame" can only be done if the function's
	/// "highPriority" flag is set to true.
	/// @param {Enum.GameState}	gameState
	/// @param {Bool}			highPriority
	set_state : function(_gameState, _highPriority = false){
		if (_highPriority || curState < _gameState){
			lastState = curState; // Store the previous game state in case it needs to be referenced later.
			curState = clamp(_gameState, GameState.InGame, GameState.Paused);
		}
	}
}*/

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
	/// @param {Id.Instance}	objectID
	set_linked_object : function(_objectID){
		if (instance_exists(_objectID)) {linkedObject = _objectID;}
		else							{linkedObject = noone;}
	}
}

// Since these only need to be during the initialization phase of the game, they are set here right after
// the audio listener's code has been read by the compiler and initialized. They determine how sounds will
// fall off in volume relative to the position of the sound against the listener's position, and the
// orientation for the listener is set up to properly mimic a stereo effect for all sound effects.
audio_falloff_set_model(audio_falloff_linear_distance);
audio_listener_orientation(0, 0, 1, 0, -1, 0);

#endregion

#region In-Game Playtime Tracker

// Handles the management of the game's delta-timing, as well as the in-game time tracker. Also, this
// struct stores the string representation (HH:MM:SS) of the current in-game playtime's value.
/*global.gameTime = {
	// Stores the values for the current delta timing between two frames (A value of 1 is equal to the
	// game running at a steady 60 frames per second) and the target frame rate for physics calculations
	// per second. Changing the lower variable's value will change what FPS is equal to a delta time of 1.
	deltaTime :			0,
	targetFPS :			60,
	
	// Three variables for the delta in-game playtime tracking. The first will store the integer value for
	// the playtime. (This is the value that is converted to a viewable time format) The second variable
	// will keep track of the delta time between each real-world second; counting up to one before the
	// in game timer's value is increased. Finally, the third value will unpause and pause the timer.
	inGameTime :		0,
	inGameTimeMillis :	0,
	freezeTimer :		false,
	
	// Variables for the viewable format of the current in-game playtime. The first variable stores the
	// string value of the last converted value, and the second variable stores what the previously
	// converted value is; ensuring that the string is only re-formatted when necessary.
	inGameTimeString :	"00:00:00",
	stringLastVal :		0,
	
	/// @description Updates the current delta time value, and the current in-game playtime value if the 
	/// timer is currently toggled to update itself on a per-second basis. This function is called in the
	/// "begin_step" in the main controller object.
	begin_step : function(){
		deltaTime = (delta_time / 1000000) * targetFPS;
		
		inGameTimeMillis += deltaTime / 60;
		if (inGameTimeMillis >= 1){
			inGameTimeMillis--;
			if (!freezeTimer) {inGameTime++;}
		}
	},
	
	/// @description Returns the current in-game playtime as a formatted string (HH:MM:SS) for them to
	/// view wherever it is needed. (Ex. Pause Menu) If the string's value doesn't match the current value
	/// for the in-game time, it will format that new value to match. This prevents the function from
	/// constantly having to format a string that only changes value once every second.
	get_current_in_game_time : function(){
		if (stringLastVal != inGameTime){
			inGameTimeString = string_number_to_time_format(inGameTime, false);
			stringLastVal = inGameTime;
		}
		return inGameTimeString;
	}
}*/

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
/*global.settings = {
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
	textSpeed :				0.75,
							
	objectiveHints :		false,
	itemHighlighting :		false,
	interactionPrompts :	false,
							
	isRunToggle :			false,
	isAimToggle :			false,
	
	/// @description Updates the master volume, which affects all volume groups when it is updated; those
	/// group volumes being the factor of the volume for currently for that group, and the master volume's
	/// current value--both of which should range between zero and one.
	/// @param {Real}	masterVolume
	update_master_volume : function(_masterVolume){
		masterVolume =		clamp(_masterVolume, 0, 1);
		trueSoundVolume =	masterVolume * soundVolume;
		trueGuiVolume =		masterVolume * guiVolume;
		
		if (playMusic)	{trueMusicVolume = masterVolume * musicVolume;}
		else			{trueMusicVolume = 0;}
	},
	
	/// @description Updates the music volume, specifically, which is unique in the fact that is can have its
	/// audio group completely disabled from playing at all--doing so by setting the volume to 0 so that
	/// playback isn't actually halted or reset from disabling/enabling music.
	/// @param {Real}	musicVolume
	/// @param {Bool}	playMusic
	update_music_volume : function(_musicVolume, _playMusic){
		musicVolume =		clamp(_musicVolume, 0, 1);
		playMusic =			_playMusic;
		if (_playMusic)		{trueMusicVolume = masterVolume * musicVolume;}
		else				{trueMusicVolume = 0;} // Mute the music if it's been disabled
	},
	
	/// @description A simple function that updates the playback volume for nearly all sound effects within 
	/// the game. GUI sounds are excempt since they have their own volume group.
	/// @param {Real}	soundVolume
	update_sound_volume : function(_soundVolume){
		soundVolume =		clamp(_soundVolume, 0, 1);
		trueSoundVolume =	masterVolume * soundVolume;
	},
	
	/// @description A simple function that updates the playback volume for all menu/ui sound effects.
	/// @param {Real}	guiVolume
	update_gui_volume : function(_guiVolume){
		guiVolume =			clamp(_guiVolume, 0, 1);
		trueSoundVolume =	masterVolume * guiVolume;
	}
}*/

// A simple struct that contains information about the currently connected gamepad. Namely, it's device ID,
// which determines whether it's an XInput or a Direct Input style gamepad. This distinction along with the 
// variable storing the gamepad's "info" (it's guid and description string) will determine what icons are 
// paired with the controller for the GUI's control information displays.
/*global.gamepad = {
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
		
		var _isActive = isActive;
		if ((!isActive && gamepad_any_button(deviceID, true)) || (isActive && keyboard_check_pressed(vk_anykey))) {isActive = !isActive;}
		if (_isActive != isActive) {CONTROL_INFO.initialize_input_icons();}
	},
	
	/// @description A simple function that returns the mapping data used by various support controllers 
	/// that are of the Direct Input variety. (Ex. Sony Controllers and the Switch Pro Controller) This
	/// string ensures that SDL will map the input to the correct buttons on the controller.
	/// @param {String}	info
	get_gamepad_mapping_data : function(_info){
		switch(_info){
			case SONY_DUALSHOCK_FOUR:	return info + ",a:b1,b:b2,x:b0,y:b3,leftshoulder:b4,rightshoulder:b5,lefttrigger:a3,righttrigger:a4,guide:b13,start:b9,leftstick:b10,rightstick:b11,dpup:h0.1,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,leftx:a0,lefty:a1,rightx:a2,righty:a5,back:b12,";
			case SONY_DUALSENSE:		return info + ",a:b1,b:b2,x:b0,y:b3,leftshoulder:b4,rightshoulder:b5,lefttrigger:a3,righttrigger:a4,guide:b13,start:b9,leftstick:b10,rightstick:b11,dpup:h0.1,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,leftx:a0,lefty:a1,rightx:a2,righty:a5,back:b12,";
			default:					return "";
		}
	}
}*/

#endregion

#region Gameplay difficulty/modifiers global struct

// An extremely important struct that stores all of the difficulty settings for the game. It can manipulate
// the player's item inventory starting/maximum size, the location and availability of items in the world,
// the damage values of both the player and enemies, and also add/remove certain gameplay mechanics to make
// the game easier or more difficulty depending on the set combat difficulty.
/*global.gameplay = {
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
	/// setting, "Forgiving". Player damage is heavily amplified; enemy damage is heavily reduced; the player 
	/// is granted a starting pistol with infinite ammunition, and they will slowly regenerate their health
	/// when out of combat.
	/// @param {Enum.Difficulty}	puzzleDifficulty
	initialize_difficulty_forgiving : function(_puzzleDifficulty){
		combatDifficulty =		Difficulty.Forgiving;
		puzzleDifficulty =		_puzzleDifficulty;
		startingItemInvSize =	10;
		maximumItemInvSize =	24;
		pDamageModifier =		2.0;
		eDamageModifier =		0.5;
		pStartingPistol =		true;
		pRegenHitpoints =		true;
		global.curItemInvSize = startingItemInvSize;
	},
	
	/// @description Initializes the gameplay struct to not affect gameplay at all (Aside from how many slots 
	/// are available to the player in their item inventory).
	/// @param {Enum.Difficulty}	puzzleDifficulty
	initialize_difficulty_standard : function(_puzzleDifficulty){
		combatDifficulty =		Difficulty.Standard;
		puzzleDifficulty =		_puzzleDifficulty;
		startingItemInvSize =	8;
		maximumItemInvSize =	20;
		pDamageModifier =		1.0;
		eDamageModifier =		1.0;
		global.curItemInvSize = startingItemInvSize;
		
		// NOTE -- No gameplay modification flags are set on this difficulty.
	},
	
	/// @description 
	/// @param {Enum.Difficulty}	puzzleDifficulty
	initialize_difficulty_punishing : function(_puzzleDifficulty){
		combatDifficulty =		Difficulty.Punishing;
		puzzleDifficulty =		_puzzleDifficulty;
		startingItemInvSize =	8;
		maximumItemInvSize =	16;
		pDamageModifier =		0.75;
		eDamageModifier =		1.25;
		pItemRepairs =			true;
		global.curItemInvSize = startingItemInvSize;
	},
	
	/// @description 
	/// @param {Enum.Difficulty}	puzzleDifficulty
	initialize_difficulty_nightmare : function(_puzzleDifficulty){
		combatDifficulty =		Difficulty.Punishing;
		puzzleDifficulty =		_puzzleDifficulty;
		startingItemInvSize =	6;
		maximumItemInvSize =	12;
		pDamageModifier =		0.5;
		eDamageModifier =		1.5;
		pItemRepairs =			true;
		pLimitedSaving =		true;
		global.curItemInvSize = startingItemInvSize;
	},
	
	/// @description
	/// @param {Enum.Difficulty}	puzzleDifficulty
	initialize_difficulty_one_life_mode : function(_puzzleDifficulty){
		combatDifficulty =		Difficulty.OneLifeMode;
		puzzleDifficulty =		_puzzleDifficulty;
		startingItemInvSize =	4;
		maximumItemInvSize =	10;
		pDamageModifier =		1.0;
		eDamageModifier =		2.0;
		pItemRepairs =			true;
		pOneLifeMode =			true;
		global.curItemInvSize = startingItemInvSize;
	}
}*/

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

#endregion
