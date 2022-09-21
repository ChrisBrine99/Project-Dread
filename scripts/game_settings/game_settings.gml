/// @description Insert summary of this file here.

#region Initializing any macros that are useful/related to the game settings struct

// 
#macro	FULL_SCREEN				0
#macro	VERTICAL_SYNC			1
#macro	BLOOM_EFFECT			2
#macro	ABERRATION_EFFECT		3
#macro	FILM_GRAIN_FILTER		4
#macro	SCANLINE_FILTER			5

// 
#macro	PLAY_MUSIC				10

// 
#macro	OBJECTIVE_HINTS			20
#macro	ITEM_HIGHLIGHTING		21
#macro	INTERACTION_PROMPTS		22
#macro	IS_RUN_TOGGLE			23
#macro	IS_AIM_TOGGLE			24
#macro	SWAP_MOVEMENT_STICK		25

// 
#macro	GAMEPAD_VIBRATION		30

// 
#macro	CDIFF_FORGIVING			0
#macro	CDIFF_STANDARD			1
#macro	CDIFF_PUNISHING			2
#macro	CDIFF_NIGHTMARE			3
#macro	CDIFF_ONELIFEMODE		4

// 
#macro	PDIFF_FORGIVING			5
#macro	PDIFF_STANDARD			6
#macro	PDIFF_PUNISHING			7

// 
#macro	REGEN_HITPOINTS			10
#macro	STARTING_PISTOL			11
#macro	LIMITED_SAVES			12
#macro	ITEM_DURABILITY			13
#macro	ONE_LIFE_MODE			14
#macro	CHECKPOINTS				15

// 
#macro	PUZZLE_HINTS			20

#endregion

#region Initializing enumerators that are useful/related to the game settings struct
#endregion

#region Initializing any globals that are useful/related to the game settings struct
#endregion

#region The main object code for the game settings struct

global.gameSettings = {
	// 
	settingFlags :			0,
	difficultyFlags :		0,
	
	// 
	aspectRatio :			0,
	screenResolution :		0,
	gamma :					0,
	
	// 
	globalVolume :			0,
	musicVolume :			0,
	gameVolume :			0,
	uiVolume :				0,
	
	// 
	inputBindings :			buffer_create(64, buffer_fast, 1),
	vibrationIntensity :	0,
	stickDeadzone :			0,
	triggerThreshold :		0,
	
	// 
	textSpeed :				0,
	
	// 
	pDamageModifier :		1.0,
	eDamageModifier :		1.0,
	
	/// @description 
	cleanup : function(){
		buffer_delete(inputBindings);
	},
	
	/// @description 
	clear_combat_flags : function(){
		difficultyFlags = difficultyFlags & 
			~((1 << CDIFF_FORGIVING) |	// Clear all five difficulty bits.
			  (1 << CDIFF_STANDARD) |
			  (1 << CDIFF_PUNISHING) |
			  (1 << CDIFF_NIGHTMARE) |
			  (1 << CDIFF_ONELIFEMODE) |
			  (1 << REGEN_HITPOINTS) |	// Clears all modification bits.
			  (1 << STARTING_PISTOL) |
			  (1 << LIMITED_SAVES) |
			  (1 << ITEM_DURABILITY) |
			  (1 << ONE_LIFE_MODE) |
			  (1 << CHECKPOINTS));
	},
	
	/// @description 
	clear_puzzle_flags : function(){
		difficultyFlags = difficultyFlags &
			~((1 << PDIFF_FORGIVING) |	// Clear all three difficulty bits.
			  (1 << PDIFF_STANDARD) |
			  (1 << PDIFF_PUNISHING) |
			  (1 << PUZZLE_HINTS));		// Clear all modification bits.
	}
}

#endregion

#region Global functions related to the game settings struct

/// @description 
/// @param {Real}	difficultyFlag
function game_set_combat_difficulty(_difficultyFlag){
	with(global.gameplayModifier){
		clear_combat_flags(); // Ensures all combat modifying flags are set to zero.
		switch(_difficultyFlag){
			case CDIFF_FORGIVING:
				difficultyFlags = difficultyFlags |
					(1 << CDIFF_FORGIVING) |
					(1 << REGEN_HITPOINTS) |
					(1 << STARTING_PISTOL) |
					(1 << CHECKPOINTS);
				pDamageModifier = 2.0;
				eDamageModifier = 0.5;
				break;
			case CDIFF_STANDARD:
				difficultyFlags = difficultyFlags |
					(1 << CDIFF_STANDARD) |
					(1 << CHECKPOINTS);
				pDamageModifier = 1.0;
				eDamageModifier = 1.0;
				break;
			case CDIFF_PUNISHING:
				difficultyFlags = difficultyFlags |
					(1 << CDIFF_PUNISHING) |
					(1 << ITEM_DURABILITY) |
					(1 << CHECKPOINTS);
				pDamageModifier = 0.75;
				eDamageModifier = 1.25;
				break;
			case CDIFF_NIGHTMARE:
				difficultyFlags = difficultyFlags |
					(1 << CDIFF_PUNISHING) |
					(1 << LIMITED_SAVES) |
					(1 << ITEM_DURABILITY);
				pDamageModifier = 0.75;
				eDamageModifier = 1.5;
				break;
			case CDIFF_ONELIFEMODE:
				difficultyFlags = difficultyFlags |
					(1 << CDIFF_NIGHTMARE) |
					(1 << ITEM_DURABILITY) |
					(1 << ONE_LIFE_MODE);
				pDamageModifier = 0.5;
				eDamageModifier = 2.0;
				break;
		}
	}
}

/// @description 
/// @param puzzleDifficulty
function game_set_puzzle_difficulty(_difficultyFlag){
	with(global.gameplayModifier){
		clear_puzzle_flags(); // Ensures all puzzle modification flag bits are set to zero.
		switch(_difficultyFlag){
			case PDIFF_FORGIVING:
				difficultyFlags = difficultyFlags |
					(1 << PDIFF_FORGIVING) |
					(1 << PUZZLE_HINTS);
				break;
			case PDIFF_STANDARD:
				difficultyFlags = difficultyFlags |
					(1 << PDIFF_STANDARD);
				break;
			case PDIFF_PUNISHING:
				difficultyFlags = difficultyFlags |
					(1 << PDIFF_PUNISHING);
		}
	}
}

#endregion