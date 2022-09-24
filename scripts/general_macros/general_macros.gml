/// @description Stores all constant values that are used all throughout the game's code. From values like
/// keyboard inputs that aren't covered by the built-in vk_* constants, to unique colors, game settings, input
/// bindings, keys for important data structures; all global constants are found here. (Object specific macros
/// will be placed in the Create Event or script file since they are only used by that object/script)

#region Additional vk_* macros for letters, numbers, and other keyboard keys

// Virtual keyboard constants for all numberical keys ABOVE the letters on the keyboard
#macro	vk_0					48
#macro	vk_1					49
#macro	vk_2					50
#macro	vk_3					51
#macro	vk_4					52
#macro	vk_5					53
#macro	vk_6					54
#macro	vk_7					55
#macro	vk_8					56
#macro	vk_9					57

// Virtual keyboard constants for all letters of the alphabet
#macro	vk_a					65
#macro	vk_b					66
#macro	vk_c					67
#macro	vk_d					68
#macro	vk_e					69
#macro	vk_f					70
#macro	vk_g					71
#macro	vk_h					72
#macro	vk_i					73
#macro	vk_j					74
#macro	vk_k					75
#macro	vk_l					76
#macro	vk_m					77
#macro	vk_n					78
#macro	vk_o					79
#macro	vk_p					80
#macro	vk_q					81
#macro	vk_r					82
#macro	vk_s					83
#macro	vk_t					84
#macro	vk_u					85
#macro	vk_v					86
#macro	vk_w					87
#macro	vk_x					88
#macro	vk_y					89
#macro	vk_z					90

// Virtual keyboard constants for any other keys that aren't covered by Game Maker's default vk_* constants
#macro	vk_capslock				20
#macro	vk_numberlock			144
#macro	vk_scrolllock			145
#macro	vk_semicolon			186		// Also ":"
#macro	vk_equal				187		// Also "+"
#macro	vk_comma				188		// Also "<"
#macro	vk_underscore			189		// Also "-"
#macro	vk_period				190		// Also ">"
#macro	vk_fslash				191		// Also "?"
#macro	vk_backquote			192		// Also "~"
#macro	vk_openbracket			218		// Also "{"
#macro	vk_bslash				220		// Also "|"
#macro	vk_closebracket			221		// Also "}"
#macro	vk_quotation			222		// Also "'"

#endregion

#region Global object macros

// Constants that represent their respective default or "zero" values--representing the value that any 
// variable SHOULD be set to whenever it doesn't have a valid reference to whatever they represent.
#macro	NO_STATE			   -20
#macro	NO_SOUND			   -21
#macro	NO_FUNCTION			   -22
#macro	NO_SPRITE			   -23

// A macro replacement for the value that is returned by the built-in "object_get_parent" function when there
// is no parent object assigned to the object in question. 
#macro	NO_PARENT			   -100

// Macro values for constants that are returned by functions created by myself within the code.
#macro	ROOM_INDEX_INVALID     -200
#macro	EVENT_FLAG_INVALID	   -300

// Two constants that refer to the coordinate that is tied to a given value of a 2D vector array. Helps
// explain what the values of "0" and "1" refer to in the context of said vector within the code.
#macro	X						0
#macro	Y						1

// Macros that replace the array index values for what is returned by the "load_external_sound_wav" function.
// These values refer to the audio buffer that was created for sound playback, and the buffer that the audio's
// data is being referenced from. Both need to be managed and deleted to avoid memory leaks.
#macro	AUDIO_DATA				0
#macro	AUDIO_BUFFER			1

#endregion

#region Color hex value macros (ALL ARE IN BGR FORMAT)

// Stores the hexidecimal color codes for important shades of white, gray, and black.
#macro	HEX_WHITE				0xF8F8F8 // BGR = 248, 248, 248
#macro	HEX_LIGHT_GRAY			0xBFBFBF // BGR = 191, 191, 191
#macro	HEX_GRAY				0x7F7F7F // BGR = 127, 127, 127
#macro	HEX_DARK_GRAY			0x404040 // BGR =  64,  64,  64
#macro	HEX_VERY_DARK_GRAY		0x202020 // BGR =  32,  32,  32
#macro	HEX_BLACK				0x000000 // BGR =   0,   0,   0

// Stores the hexidecimal color codes for important red hues. (Used in some menu background and for text highlighting)
#macro	HEX_LIGHT_RED			0x0038F8 // BGR =   0,  56, 248
#macro	HEX_RED					0x0000BC // BGR =   0,   0, 188
#macro	HEX_DARK_RED			0x00005E // BGR =   0,   0,  94

// Stores the hexidecimal color codes for important green hues. (Used in text highlighting, for example)
#macro	HEX_LIGHT_GREEN			0x00F858 // BGR =   0, 248,  88
#macro	HEX_GREEN				0x00B800 // BGR =   0, 184,   0
#macro	HEX_DARK_GREEN			0x005800 // BGR =   0,  88,   0

// Stores the hexidecimal color codes for important blue hues. (Used for most menu background elements)
#macro	HEX_VERY_LIGHT_BLUE		0xFC8868 // BGR = 252, 136, 104 
#macro	HEX_LIGHT_BLUE			0xF85800 // BGR = 248,  88,   0
#macro	HEX_BLUE				0xBC0000 // BGR = 188,   0,   0
#macro	HEX_DARK_BLUE			0x5E0000 // BGR =  94,   0,   0
#macro	HEX_VERY_DARK_BLUE		0x280000 // BGR =  40,   0,   0

// Stores the hexidecimal color codes for important yellow hues. (Used in text highlighting, for example)
#macro	HEX_LIGHT_YELLOW		0x7FE9FF // BGR = 127, 233, 255
#macro	HEX_YELLOW				0x00DCFF // BGR =   0, 220, 255
#macro	HEX_DARK_YELLOW			0x3F727F // BGR =  63, 114, 127

#endregion

#region Color rgb value array macros (R and B values flipped from hex values)

// Each constant refers to the same shades as the hex constants above, but in an RGB array format instead.
#macro	RGB_WHITE				[0.972, 0.972, 0.972] // RGB = 248, 248, 248
#macro	RGB_LIGHT_GRAY			[0.75 , 0.75 , 0.75 ] // RGB = 191, 191, 191
#macro	RGB_GRAY				[0.5  , 0.5  , 0.5  ] // RGB = 127, 127, 127
#macro	RGB_DARK_GRAY			[0.25 , 0.25 , 0.25 ] // RGB =  64,  64,  64
#macro	RGB_VERY_DARK_GRAY		[0.125, 0.125, 0.125] // RGB =  32,  32,  32
#macro	RGB_BLACK				[0    , 0    , 0    ] // RGB =   0,   0,   0

// Each constant refers to the same reds as the hex constants above, but in an RGB array format instead.
#macro	RGB_LIGHT_RED			[0.972, 0.219, 0    ] // RGB = 248,  88,   0
#macro	RGB_RED					[0.737, 0    , 0    ] // RGB = 188,   0,   0
#macro	RGB_DARK_RED			[0.368, 0    , 0    ] // RGB =  94,   0,   0

// Each constant refers to the same greens as the hex constants above, but in an RGB array format instead.
#macro	RGB_LIGHT_GREEN			[0.345, 0.972, 0    ] // RGB =  88, 248,   0
#macro	RGB_GREEN				[0    , 0.721, 0    ] // RGB =   0, 184,   0
#macro	RGB_DARK_GREEN			[0    , 0.345, 0    ] // RGB =   0,  88,   0

// Each constant refers to the same blues as the hex constants above, but in an RGB array format instead.
#macro	RGB_VERY_LIGHT_BLUE		[0.407, 0.533, 0.988] // RGB = 104, 136, 252
#macro	RGB_LIGHT_BLUE			[0    , 0.345, 0.972] // RGB =   0,  88, 248
#macro	RGB_BLUE				[0    , 0    , 0.737] // RGB =   0,   0, 188
#macro	RGB_DARK_BLUE			[0	  , 0    , 0.368] // RGB =   0,   0,  94
#macro	RGB_VERY_DARK_BLUE		[0    , 0    , 0.156] // RGB =   0,   0,  40

// Each constant refers to the same yellows as the hex constants above, but in an RGB array format instead.
#macro	RGB_LIGHT_YELLOW		[1    , 0.913, 0.5  ] // RGB = 255, 233, 127
#macro	RGB_YELLOW				[1    , 0.862, 0    ] // RGB = 255, 220,   0
#macro	RGB_DARK_YELLOW			[0.498, 0.447, 0.247] // RGB = 127, 114,  63

#endregion

#region Item data structure key macros

// Macro that contains the key value for accessing the global item data's master list, which holds the names,
// types, max slot quantity, base description, and examine description for each item in the game.
#macro	KEY_ITEM_LIST			"Item List"
// The macros that are needed to access the inner information contained within the master item list.
#macro	ITEM_TYPE				"Type"
#macro	ITEM_QUANTITY			"Quantity"
#macro	ITEM_DURABILITY			"Durability"
#macro	ITEM_AMMO_IN_USE		"Ammo In Use"
#macro	ITEM_STANDARD_INFO		"Standard Info"
#macro	ITEM_EXAMINE_INFO		"Examine Info"

// The types of items that exist within the game, which determine how the item will be treated and will
// function within the code. Also determines what options are available to the player when selecting a given
// item. (Ex. ammo can't be "Used", and "Equipment" can't be reloaded)
#macro	TYPE_WEAPON				"Weapon"
#macro	TYPE_CONSUMABLE			"Consumable"
#macro	TYPE_CRAFTING			"Crafting"
#macro	TYPE_USABLE				"Usable"
#macro	TYPE_AMMO				"Ammo"
#macro	TYPE_EQUIPMENT			"Equipment"
#macro	TYPE_THROWABLE			"Throwable"

// Macro that contains the key value for accessing all of the equipable item data from the global item data,
// which tells the code what functions to run for a given item based on it being equipped to the player or
// unequipped. The last key stores a list of data to use in the item's equipping function.
#macro	KEY_EQUIPMENT_DATA		"Equipment Data"
// The macros that are needed to access the inner information contained within the equipment data.
#macro	EQUIP_FUNCTION			"Equip Function"
#macro	UNEQUIP_FUNCTION		"Unequip Function"
#macro	EQUIP_ARGUMENTS			"Equip Arguments"

// Macro that contains the key value for accessing a given weapon's stats; their damage, range, accuracy, 
// fire rate, animations, sound effects, usable ammo types, and so on. 
#macro	KEY_WEAPON_STATS		"Weapon Stats"
// The macros that are needed to access each piece of a weapon's stat data from the data structure.
#macro	WEAPON_TYPE				"Type"
#macro	WEAPON_DAMAGE			"Damage"
#macro	WEAPON_RANGE			"Range"
#macro	WEAPON_ACCURACY			"Accuracy"
#macro	WEAPON_ACC_PENALTY		"Acc Penalty"
#macro	WEAPON_FIRE_RATE		"Fire Rate"			// Doubles as lifespan of melee weapon's hitbox
#macro	WEAPON_RELOAD_RATE		"Reload Rate"		// Doubles as recovery time after a melee attack
#macro	WEAPON_FULL_RELOAD_RATE	"Full Reload"
#macro	WEAPON_BULLET_COUNT		"Bullet Count"
#macro	WEAPON_BULLET_SPACING	"Spacing"			// Value > 0 means bullets show out sequentially; == 0 means all bullets spawn at once
#macro	WEAPON_HIT_FRAME		"Hit Frame"			// Stat is exclusive to melee weaponry
#macro	WEAPON_AMMO_TYPES		"Ammo Types"
#macro	WEAPON_GROUP_ID			"Group ID"
#macro	WEAPON_SPRITES			"Weapon Sprites"
#macro	WEAPON_POSITION			"Weapon Position"
#macro	WEAPON_BARREL_POSITION	"Barrel Position"
/// TODO -- Add sound effect key values here for using the weapon, and reloading.

// Macro that contains the key value for accessing the weapon stat modifier values for a given ammunition.
// Ammunition is able to modify the damage, range, accuracy, and bullet count of a given weapon.
#macro	KEY_AMMO_STATS			"Ammo Stats"
// The macros that are needed to access each of the modifier values for a given ammunition.
#macro	AMMO_DAMAGE_MOD			"Damage Mod"
#macro	AMMO_RANGE_MOD			"Range Mod"
#macro	AMMO_ACCURACY_MOD		"Accuracy Mod"
#macro	AMMO_BULLET_COUNT_MOD	"Bullet Count Mod"

// Macro that contains the key value for accessing all of the crafting recipes that exist within the game.
// It's a very simple system; only allowing two items to be combined together at any given time; resulting
// in a completely new item, usually.
#macro	KEY_CRAFTING_DATA		"Crafting Data"
// The macros that are needed to access each of the pieces of information about a given crafting recipe.
#macro	CRAFTING_FIRST_ITEM		"First Item"
#macro	CRAFTING_FIRST_COST		"First Cost"
#macro	CRAFTING_SECOND_ITEM	"Second Item"
#macro	CRAFTING_SECOND_COST	"Second Cost"
#macro	CRAFTING_RESULT_ITEM	"Result Item"
#macro	CRAFTING_MIN_RESULT		"Min Amount"
#macro	CRAFTING_MAX_RESULT		"Max Amount"
#macro	CRAFTING_FUNCTION		"Crafting Function"

// A list of macros that contain the names for every available item in the game in case they need to be used
// somewhere in the code itself. Otherwise, they aren't used since all these are stored in an external file
// for item data that is loaded on the game's startup.
#macro	NO_ITEM					"---"
#macro	DIM_FLASHLIGHT			"Dim Flashlight"
#macro	BRIGHT_FLASHLIGHT		"Bright Flashlight"
#macro	UV_FLASHLIGHT			"UV Flashlight"
#macro	BALLISTIC_VEST			"Ballistic Vest"
#macro	KEVLAR_VEST				"Kevlar Vest"
#macro	HANDGUN					"9mm Handgun"
#macro	PUMP_SHOTGUN			"Pump Shotgun"
#macro	BOLT_ACTION_RIFLE		"Bolt-Action Rifle"
#macro	TRIPLE_BURST_HANDGUN	"Triple-Burst Handgun"
#macro	FULL_AUTO_SHOTGUN		"Full-Auto Shotgun"
#macro	SEMI_AUTO_RIFLE			"Semi-Auto Rifle"
#macro	SUBMACHINE_GUN			"Submachine Gun"
#macro	HAND_CANNON				"Hand Cannon"
#macro	GRENADE_LAUNCHER		"Grenade Launcher"
#macro	INF_HANDGUN				"Inf. Handgun"
#macro	INF_SUBMACHINE_GUN		"Inf. Submachine Gun"
#macro	INF_NAPALM_LAUNCHER		"Inf. Napalm Launcher"
#macro	HANDGUN_AMMO			"Handgun Ammo"
#macro	SHOTGUN_SHELLS			"Shotgun Shells"
#macro	RIFLE_ROUNDS			"Rifle Rounds"
#macro	MAGNUM_ROUNDS			"Magnum Rounds"
#macro	EXPLOSIVE_SHELLS		"Explosive Shells"
#macro	HANDGUN_AMMO_WEAK		"Handgun Ammo (-)"
#macro	SHOTGUN_SHELLS_WEAK		"Shotgun Shells (-)"
#macro	RIFLE_ROUNDS_WEAK		"Rifle Rounds (-)"
#macro	MAGNUM_ROUNDS_WEAK		"Magnum Rounds (-)"
#macro	EXPLOSIVE_SHELLS_WEAK	"Explosive Shells (-)"
#macro	HANDGUN_AMMO_PLUS		"Handgun Ammo (+)"
#macro	SHOTGUN_SHELLS_PLUS		"Shotgun Shells (+)"
#macro	RIFLE_ROUNDS_PLUS		"Rifle Rounds (+)"
#macro	MAGNUM_ROUNDS_PLUS		"Magnum Rounds (+)"
#macro	FRAGMENT_SHELLS			"Fragment Shells"
#macro	NAPALM_SHELLS			"Napalm Shells"
#macro	FROST_SHELLS			"Frost Shells"
#macro	ALUMINUM_CAN			"Aluminum Can"
#macro	GLASS_BOTTLE			"Glass Bottle"
#macro	MAKESHIFT_GRENADE		"Makeshift Grenade"
#macro	MOLOTOV_COCKTAIL		"Molotov Cocktail"
#macro	POCKET_KNIFE			"Pocket Knife"
#macro	METAL_PIPE				"Metal Pipe"
#macro	HATCHET					"Hatchet"
#macro	MACHETE					"Machete"
#macro	FIRE_AXE				"Fire Axe"
#macro	IMMUNITY_AMULET			"Immunity Amulet"
#macro	IRON_SKIN_AMULET		"Iron Skin Amulet"
#macro	STRENGTH_AMULET			"Strength Amulet"
#macro	CALMING_AMULET			"Calming Amulet"
#macro	LUCKY_AMULET			"Lucky Amulet"
#macro	REFUND_AMULET			"Refund Amulet"
#macro	FORTIFIED_AMULET		"Fortified Amulet"
#macro	POWER_AMULET			"Power Amulet"
#macro	HEALING_AMULET			"Healing Amulet"
#macro	SILENT_STEP_AMULET		"Silent Step Amulet"
#macro	IMPURE_SULFUR			"Impure Sulfur"
#macro	PURE_SULFUR				"Pure Sulfur"
#macro	IMPURE_CHARCOAL			"Impure Charcoal"
#macro	PURE_CHARCOAL			"Pure Charcoal"
#macro	CHEMICAL_PURIFIER		"Chemical Purifier"
#macro	EXOTHERMIC_COMPOUND		"Exothermic Compound"
#macro	ENDOTHERMIC_COMPOUND	"Endothermic Compound"
#macro	CASSETTE_TAPE			"Cassette Tape"
#macro	DIRTY_GUNPOWDER			"Dirty Gunpowder"
#macro	GUNPOWDER				"Gunpowder"
#macro	PURIFIED_GUNPOWDER		"Purified Gunpowder"
#macro	FUEL					"Fuel"
#macro	EXPLOSIVE_COMPOUND		"Explosive Compound"
#macro	HANDGUN_CASINGS			"9mm Casings"
#macro	SHOTGUN_CASINGS			"12 Gauge Casings"
#macro	RIFLE_CASINGS			"7.62mm Casings"
#macro	GRENADE_SHELLS			"40mm Shells"
#macro	MAGNUM_CASINGS			".50 Casings"
#macro	REPAIR_PARTS			"Repair Parts"
#macro	HYDROXIDE				"Hydroxide"
#macro	CHLORIDE				"Chloride"
#macro	DIRTY_WATER				"Dirty Water"
#macro	PURIFIED_WATER			"Purified Water"
#macro	DANDELION				"Dandelion"
#macro	GINGER_ROOT				"Ginger Root"
#macro	GOLDENROD				"Goldenrod"
#macro	WEAK_PAINKILLER			"Weak Painkiller"
#macro	POTENT_PAINKILLER		"Potent Painkiller"
#macro	CALMING_COMPOUND		"Calming Compound"
#macro	DETOXING_COMPOUND		"Detoxing Compound"
#macro	WEAK_MEDICINE			"Weak Medicine"
#macro	POTENT_MEDICINE			"Potent Medicine"
#macro	CHEMICAL_MIX_WM_PM		"Chemical Mix (WM+PM)"
#macro	CHEMICAL_MIX_WM_WP		"Chemical Mix (WM+WP)"
#macro	CHEMICAL_MIX_WM_PP		"Chemical Mix (WM+PP)"
#macro	CHEMICAL_MIX_WM_CC		"Chemical Mix (WM+CC)"
#macro	CHEMICAL_MIX_WM_DC		"Chemical Mix (WM+DC)"
#macro	CHEMICAL_MIX_PM_WP		"Chemical Mix (PM+WP)"
#macro	CHEMICAL_MIX_PM_PP		"Chemical Mix (PM+PP)"
#macro	CHEMICAL_MIX_PM_CC		"Chemical Mix (PM+CC)"
#macro	CHEMICAL_MIX_PM_DC		"Chemical Mix (PM+DC)"
#macro	CHEMICAL_MIX_WP_CC		"Chemical Mix (WP+CC)"
#macro	CHEMICAL_MIX_WP_DC		"Chemical Mix (WP+DC)"
#macro	CHEMICAL_MIX_PP_CC		"Chemical Mix (PP+CC)"
#macro	CHEMICAL_MIX_PP_DC		"Chemical Mix (PP+DC)"
#macro	FIRST_AID_KIT			"First Aid Kit"
#macro	ANTI_PSYCHOSIS_PILLS	"Anti-Psychosis Pills"

// A default value that is used for weapons that don't consume ammunition when used; meaning all infinite
// and melee-based weaponry will have this as the only value in their "ammo types" array.
#macro	NO_AMMO					"No Ammo"

// Since it doesn't technically count as a standard item, (AKA it has no data for it found within the item
// data structure that is loaded in from the "item_data.json" file on startup) the item pouch is initialized
// here for it's necessary "item data". Basically, this name being found in an "obj_world_item" instance
// will apply the necessary functions for expanding the player's inventory with it.
#macro	ITEM_POUCH				"Item Pouch"

#endregion
