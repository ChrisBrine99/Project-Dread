/// @description Initializes all enumerators that aren't bound to any specific object, but are instead used all 
/// throughout the code for various different tasks and reasons.

/// @description Each value in this enum represents a different state that the game can be in at any given
/// moment. The first state (NoState) is simply a default and doesn't actually affect the game's ability to
/// function, but the other four will alter how the game acts in a wholly unique way.
enum GameState{
	NoState,
	InGame,
	InMenu,
	Cutscene,
	Paused,
}

/// @description Each value in this enum represents a given difficulty level, which is then referenced through
/// the game's code in order to apply or remove certain effects and game mechanics (Ex. Limited saves, weapon
/// degredation, sanity depletion, etc.) The first three indexes are used for both the combat difficulty AND
/// puzzle difficulty, but the last two are exclusive to the former's difficulty level.
enum Difficulty{
	NotSet,
	Forgiving,
	Standard,
	Punishing,
	Nightmare,
	OneLifeMode,
}