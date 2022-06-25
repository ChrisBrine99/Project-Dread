#region Player macro initialization

// The time is takes for stamina to begin regenerating after the player has stopped running; whether that
// be them releasing the run input OR not moving despite holding the input down still. It's equal to 2.5
// seconds of real-world time. (60 = 1 second of real-world time)
#macro	STAMINA_REGEN_PAUSE_TIME		150

// The time it takes for an ailment (Bleeding or Poisoned) to deal damage to the player whenever said
// character is already inflicted with either or both of the ailments. It's equal to 2.5 seconds of
// real-world time. (60 = 1 second of real-world time)
#macro	AILMENT_EFFECT_TIME				150

// Macros for the damage dealt by the poison and bleeding ailments, respectively. In the case of poison,
// the macro only references the BASE damage of it; not the current damage it could potentially deal 
// during an ailment check, since poison will double in damage each time it deals out said damage.
#macro	BASE_POISON_DAMAGE				0.01
#macro	BLEED_DAMAGE					0.05

// 
#macro	INDEFINITE_EFFECT_DURATION	   -65535

// 
#macro	EFFECT_DAMAGE_RESIST			0
#macro	EFFECT_POISON_IMMUNITY			1
#macro	EFFECT_BLEED_IMMUNITY			2
#macro	EFFECT_CRIPPLE_IMMUNITY			3
#macro	EFFECT_HITPOINT_REGEN			4

// Macros that are used with the accuracy penalty system, which makes a ranged weapon more inaccurate
// the more it is fired in quick succession. This system will reward a player that takes the time to
// line up a shot rather than one who just squeezes the trigger and hopes for the best. The first value
// is the maximum possible accuracy penalty value and the next value is the time it'll take before the
// penalty value begins to decrement AFTER a shot was fired.
#macro	ACCURACY_PENALTY_LIMIT			40
#macro	PENALTY_REDUCTION_PAUSE_TIME	25

// Prevents the accuracy cone for the fires weapon from becoming too large. (To the point where it
// exceeds 180 degrees which doesn't make any sense at all) This macro ensures that the maximum
// angle of the accuracy cone never exceeds 160 degrees. (80 on both sides of the 0 degree origin
// line from the player's current aiming direction)
#macro	ACCURACY_CONE_LIMIT				80

#endregion

#region Player enumerator initialization

// A simple enum that stores the unique ID values for the weapon's functionality when it is being
// used. There are only three types: a projectile that will move in real-time, (Pretty much just
// "grenade launcher"-style weapons) a hitscan bullet, or a melee attack.
enum WeaponType{
	Projectile,
	Hitscan,
	Melee,
}

#endregion

#region Variable inheritance and initialization

// Call the parent object's creation event; initializing all of those variables before any new
// variables and functions that are unique to the player object are created.
event_inherited();

// Adjust the values for the entity's right and left foot animation index values to match up with
// the frames of animation that the player's walking sprites have the respective foot hit the floor.
rightStepIndex = 0;
leftStepIndex = 2;

// Input variables that will allow the player entity to perform various actions given the human 
// player's inputs on a keyboard/gamepad for the game's current frame.
inputRight = false;			// Inputs for moving the entity in the game world.
inputLeft = false;
inputUp = false;
inputDown = false;
inputRun = false;

inputInteract = false;		// Interacting with objects in the game's world.

inputReadyWeapon = false;	// Inputs for the manipulating the currently equipped weapon.
inputUseWeapon = false;
inputSwapAmmo = false;
inputReload = false;

inputFlashlight = false;	// Turning the flashlight on and off; also the input for changing the
inputChangeLight = false;	// bulb that is currently being used by said flashlight.

inputPause = false;			// Inputs for opening the game's various menus.
inputItems = false;
inputNotes = false;
inputMaps = false;

// The main sprites for the player character whenever they are in their default state(s). There are
// two variations of the standing and walking sprites: one for when they have more than 50% health,
// and another for when they are below that percentage threshold; which plays an animation to show
// that the character is injured.
standSprite =		spr_player_unarmed_stand0;
walkSprite =		spr_player_unarmed_walk0;
hurtStandSprite =	spr_player_unarmed_stand0;
hurtWalkSprite =	spr_player_unarmed_walk0;

// The three sprites for the player that are set on a per-weapon basis. Unlike the standard walking
// and standing sprites, these will not have an injured variation since that would be unecessary
// details for something that might actually hinder the gameplay.
aimingSprite =		spr_player_unarmed_stand0; // TEMP VALUE
reloadSprite =		spr_player_unarmed_walk0; // TEMP VALUE
useSprite =			spr_player_unarmed_walk0; // TEMP VALUE

// Variables for the game's 8-directional movement system. The first value is simply a value of 0
// or 1 depending on if there is valid input detected on either movement axis. The second variable
// is a value ranging from 0 and 360 that determines the direction the object will move.
inputMagnitude = 0;
inputDirection = 0;

// The variables that are crucial for the game's "stamina" system. In short, it allows the player
// object to move with a short burst of speed until the stamina variable reaches zero. After that,
// the player will still be able to run, but at a much slower speed until they rest. The modifier
// variable can increase or decrease the maximum stamina to change the duration of that short burst
// of speed.
stamina = 200;
maxStamina = 200;
maxStaminaFactor = 1;

// Another modifier variable that increases the speed that the player's stamina depletes; another
// way of shortening the overall duration of that small burst of speed when beginning to run.
staminaDepletionModifier = 0;

// A value that increases until it reaches a value a 150; (2.5 seconds of real-time) after that occurs
// the player will begin to replenish the stamina value until it is maxed out once again.
staminaRegenTimer = 0;
staminaRegenSpeed = 1;

// A toggle that allows the running input to easily be swapped between a toggle or hold for
// accessibility reasons.
isRunning = false;

// A simple flag that determines if the flashlight will be toggled on or off whenever the player
// presses the flashlight input.
isFlashlightOn = false;

// The timer that counts down from 150 units (60 units being equal to 1 second of real-world time) whenever
// there is an active ailment on the player; be it poison or bleeding.
ailmentTimer = 0;

// A simple flag that lets the player object know if they are currently poisoned or not. If they are
// bleeding, they will lost 5% of their maximum hitpoints every 2.5 seconds after the get inflicted with
// said ailment.
isBleeding = false;

// The variables that manage the "poison" status ailment. The first variable tracking if the player has
// said ailment or not, the second being a flag that flips for each ailment check so that poison only
// applies its damage every 5 seconds instead of every 2.5 seconds like bleeding, and the last variable
// stores how much damage the poison will deal out; doubling after it does so.
isPoisoned = false;
dealPoisonDamage = false;
curPoisonDamage = BASE_POISON_DAMAGE;

// A map that will contain data that provides unique buffs or debuffs to the player that aren't actually
// a status condition or the sanity level. Things like temporary damage resistance; poison, bleed, and
// cripple immunity; hitpoint and stamina regeneration; as well as other effects will all be stored within
// this ds_map. The second data struction is a list holding all of the keys for the effect data that is
// stored within the map to allow for faster access when compared to iterating through the map in order.
additionalEffects = ds_map_create();
effectKeys = ds_list_create();

// The flag that is triggered whenever the player is inflicted with "crippled". This status is unique
// in that is will reduce the required stats and keep those stats lowered until the flag is flipped back
// to false again; meaning they are no longer crippled.
isCrippled = false;

// A struct that contains a value to let the game know if there is an item currently equipped within
// each of the six unique slots found within said struct. In short, if the slot is occupied, the
// slot of that equipped weapon will be stored in the respective variable. Otherwise, the value for
// the empty slot will be "noone" (-4).
equipSlot = {
	weapon :		noone,
	throwable :		noone,
	armor :			noone,
	flashlight :	noone,
	amuletOne :		noone,
	amuletTwo :		noone,
}

// A struct that is responsible for storing all of the data relating to the player's currently
// equipped weapon. It contains variables for storing necessary ranged weapon stats, melee weapon
// stats, and the few that are shared between both.
weaponData = {
	// Weapon stats that are shared by both melee and ranged weaponry //
	damage :			0,
	range :				0,
	typeID :			noone,
	
	// Stats that are used exclusively by ranged weaponry //
	accuracy :			0,
	accPenalty :		0,
	fireRate :			0,
	reloadRate :		0,
	fullReloadRate :	0,
	bulletCount :		0,
	bulletSpacing :		0,
	ammoTypes :			0,
	
	// Keeps track of how much ammo is currently available in the inventory //
	ammoRemaining :		0,
	
	// Stats that are used exclusively by melee weaponry //
	hitFrame :			0,
	
	// Modifier stats for certain weapon stats (Used only by ranged weapons) //
	damageMod :			0,
	rangeMod :			0,
	accuracyMod :		0,
	bulletCountMod :	0,
	
	// Stores the position of the weapon's barrel for each of the four main directions //
	barrelPosition :	noone, // Stores reference to ds_list found in global item data ds_map.
	
	/// @description A group of getters that will return the true values for damage, range, accuracy,
	/// and bullet count relative to the current weapon's base states, and the modifications that
	/// the current ammo type applies to those stats.
	get_damage : function()			{return max(0, (damage + damageMod) * PLAYER_DAMAGE_MOD);},
	get_range : function()			{return max(0, range + rangeMod);},
	get_accuracy : function()		{return max(0, accuracy + accuracyMod);},
	get_bullet_count : function()	{return max(1, bulletCount + bulletCountMod);},
}

// Stores which index into the list of the equipped weapon's available ammunitions is currently 
// being used by said weapon.
curAmmoType = 0;

// Three timer variables. The first one is used whenever the player uses their weapon, (The "fire 
// rate" being a melee weapon's attack animation before the hitbox actually spawns) the second being
// used whenever the weapon is reloaded, (Melee weapons use the same variable for their recovery time
// between attacks) and finally the "timeToReload" simply stores how long the weapon will take to
// reload; from either the "short" reload or "long" reload--for animation timing purposes.
fireRateTimer = 0;
reloadRateTimer = 0;
timeToReload = 0;

// Variables that are used for tracking and properly timing the spacing between bullets when there
// are multiple shot from a single pull of the equipped weapon's trigger. Both have no purpose
// outside of those functions within the "state_weapon_spaced_bullets" state.
bulletSpacingTimer = 0;
bulletsRemaining = 0;

// The main variables for handling the ranged weapon recoil system. In short, this system will add a
// value that is unique to each weapon to the penalty variable's current value. Then, this value is added
// to the base accuracy of the weapon to cause its bullets/projectiles to have a greater range of directions
// to spawn in. Slowing down shots is key to keeping shots accurate.
accuracyPenalty = 0;
penaltyReductionTimer = 0;

// The damage resistance factor that is multiplied against any damage that is taken by the player;
// the closer the value is to 0, the lower the overall damage taken. A value of 0 would completely
// remove any damage taken.
damageResistance = 1; // NOTE -- This should only ever range between 0 and 1.

// Much like the weapon struct above, (Which is much more complicated than the flashlight data struct)
// this will store data relating to the currently equipped flashlight for easy reference. It simply
// determines how the player's light component will look when the light is turned on, and also stores
// what type of light is being used. (Ex. a UV light handles differently than a standard light)
flashlightData = {
	radius :		0,
	lightColor :	0,
	strength :		0,
	isLightUV :		false,
}

// 
interactableID = noone;

// 
painSounds = [
	snd_player_hurt0,
	snd_player_hurt1,
	snd_player_hurt2,
	snd_player_hurt3,
	snd_player_hurt4
];
painSoundIndex = noone;

#endregion

#region General player functions (Getters, input, etc.)

/// @description 
get_max_stamina = function() {return max(1, floor(maxStamina * maxStaminaFactor));}

/// @description 
check_player_input = function(){
	// 
	if (!global.gamepad.isActive)	{get_input_keyboard();}
	else							{get_input_gamepad();}
	
	// 
	inputMagnitude = (inputRight - inputLeft != 0) || (inputDown - inputUp != 0);
}

/// @description 
get_input_keyboard = function(){
	// 
	inputRight =		keyboard_check(KEY_GAME_RIGHT);
	inputLeft =			keyboard_check(KEY_GAME_LEFT);
	inputUp =			keyboard_check(KEY_GAME_UP);
	inputDown =			keyboard_check(KEY_GAME_DOWN);
	
	inputInteract =		keyboard_check_pressed(KEY_INTERACT);	
	
	inputUseWeapon =	keyboard_check(KEY_USE_WEAPON);
	inputSwapAmmo =		keyboard_check_pressed(KEY_AMMO_SWAP);
	inputReload =		keyboard_check_pressed(KEY_RELOAD_GUN);
	
	inputFlashlight =	keyboard_check_pressed(KEY_FLASHLIGHT);
	inputChangeLight =	keyboard_check_pressed(KEY_LIGHT_SWAP);
	
	inputPause =		keyboard_check_pressed(KEY_PAUSE);
	inputItems =		keyboard_check_pressed(KEY_ITEMS);
	inputNotes =		keyboard_check_pressed(KEY_NOTES);
	inputMaps =			keyboard_check_pressed(KEY_MAPS);
	
	// 
	if (!IS_RUN_TOGGLE)	{inputRun = keyboard_check(KEY_RUN);}
	else				{inputRun = keyboard_check_pressed(KEY_RUN);}
	
	if (!IS_AIM_TOGGLE)	{inputReadyWeapon = keyboard_check(KEY_READY_WEAPON);}
	else				{inputReadyWeapon = keyboard_check_pressed(KEY_READY_WEAPON);}
	
	// 
	inputDirection = point_direction(0, 0, inputRight - inputLeft, inputDown - inputUp);
}

/// @description 
get_input_gamepad = function(){
	// 
	var _gamepad, _deadzone;
	_gamepad = global.gamepad.deviceID;
	_deadzone = gamepad_get_axis_deadzone(_gamepad);
	
	// 
	var _stickH, _stickV, _stickInUse;
	_stickH = gamepad_axis_value(_gamepad, gp_axislh);
	_stickV = gamepad_axis_value(_gamepad, gp_axislv);
	_stickInUse = (abs(_stickH) >= _deadzone && abs(_stickV) >= _deadzone);
	
	// 
	inputRight =		(gamepad_button_check(_gamepad, PAD_GAME_RIGHT) || _stickH >= _deadzone);
	inputLeft =			(gamepad_button_check(_gamepad, PAD_GAME_LEFT)	|| _stickH <= -_deadzone);
	inputUp =			(gamepad_button_check(_gamepad, PAD_GAME_UP)	|| _stickV <= -_deadzone);
	inputDown =			(gamepad_button_check(_gamepad, PAD_GAME_DOWN)	|| _stickV >= _deadzone);
	
	inputInteract =		gamepad_button_check_pressed(_gamepad, PAD_INTERACT);
	
	inputUseWeapon =	gamepad_button_check(_gamepad, PAD_USE_WEAPON);
	inputSwapAmmo =		gamepad_button_check_pressed(_gamepad, PAD_AMMO_SWAP);
	inputReload =		gamepad_button_check_pressed(_gamepad, PAD_RELOAD_GUN);
	
	inputFlashlight =	gamepad_button_check_pressed(_gamepad, PAD_FLASHLIGHT);
	inputChangeLight =	gamepad_button_check_pressed(_gamepad, PAD_LIGHT_SWAP);
	
	inputPause =		gamepad_button_check_pressed(_gamepad, PAD_PAUSE);
	inputItems =		gamepad_button_check_pressed(_gamepad, PAD_ITEMS);
	inputNotes =		gamepad_button_check_pressed(_gamepad, PAD_NOTES);
	inputMaps =			gamepad_button_check_pressed(_gamepad, PAD_MAPS);
	
	// 
	if (!IS_RUN_TOGGLE)	{inputRun = gamepad_button_check(_gamepad, PAD_RUN);}
	else				{inputRun = gamepad_button_check_pressed(_gamepad, PAD_RUN);}
	
	if (!IS_AIM_TOGGLE)	{inputReadyWeapon = gamepad_button_check(_gamepad, PAD_READY_WEAPON);}
	else				{inputReadyWeapon = gamepad_button_check_pressed(_gamepad, PAD_READY_WEAPON);}
	
	// 
	if (_stickInUse)	{inputDirection = point_direction(0, 0, _stickH, _stickV);}
	else				{inputDirection = point_direction(0, 0, inputRight - inputLeft, inputDown - inputUp);}
}

/// @description A simple function that will equip and unequip the given item onto the player; using
/// whatever function that require for those actions that will be found in the global item data
/// struct.
/// @param slot
equip_item_to_player = function(_slot){
	var _function = noone;
	if (!global.items[_slot].isEquipped){ // Calling the function that will equip the item in the slot.
		_function = variable_instance_get(id, global.itemData[? KEY_EQUIPMENT_DATA][? global.items[_slot].itemName][? EQUIP_FUNCTION]);
		_function(_slot);
	} else{ // Calling the function that will unequip the item in the current slot.
		_function = variable_instance_get(id, global.itemData[? KEY_EQUIPMENT_DATA][? global.items[_slot].itemName][? UNEQUIP_FUNCTION]);
		_function();
	}
}

#endregion

#region Flashlight functions

/// @description A function that equips a flashlight to the player's avaiable slot for a flashlight.
/// If will pull the given flashlight's stats from the master item data ds_map and assigns that data
/// to the player's struct for its flashlight charactistics; applying those values to the light
/// component of the player object.
/// @param slot
equip_flashlight = function(_slot){
	// Unequip the previously equipped flashlight by simply flipping its flag from within the slot
	// that the flashlight is currently contained within.
	if (equipSlot.flashlight != noone) {global.items[equipSlot.flashlight].isEquipped = false;}
	
	// Store the player's attached light component's ID value in a local variable so it can be
	// referenced from within the flashlightData struct. Then, jump into said struct to set its
	// properties. Flip the flashlight flag to "true" after setting up the data and light values.
	var _lightComponent, _equipmentStats;
	_lightComponent = lightComponent;
	_equipmentStats = global.itemData[? KEY_EQUIPMENT_DATA][? global.items[_slot].itemName][? EQUIP_ARGUMENTS];
	with(flashlightData){
		// Set the stats for the dim flashlight in the struct variables below. Each value in the
		// equip data's list corresponds to that same data within the equipment data that was set
		// externally with the item data.
		radius =		_equipmentStats[| 0];
		lightColor =	_equipmentStats[| 1];
		strength =		_equipmentStats[| 2];
		isLightUV =		_equipmentStats[| 3];
		
		// Then, use those stored values to update the player's light component according to the
		// equipped flashlight's stats.
		_lightComponent.set_properties(radius, lightColor, strength, 360);
	}
	isFlashlightOn = true;
	
	// After setting up all the flashlight properties accordingly, set the flag in the item's struct
	// for whether it's equipped or not to true, and set the flashlight's equipment slot to the slot
	// index that the flashlight is stored.
	global.items[_slot].isEquipped = false;
	equipSlot.flashlight = _slot;
}

/// @description Unequips the flashlight by clearing out any data from the player's flashlight stat
/// storage struct before it returns the player's light component back to its default settings.
unequip_flashlight = function(){
	// In order to prevent any unchecked issues, the data stored within the equipped flashlight
	// stat data needs to all be reset to their default values, which are found below.
	with(flashlightData){
		radius =	0;
		color =		c_white;
		strength =	0;
		isLightUV = false;
	}
	
	// If the flashlight was toggled on by the player before they unequipped that light, the player's
	// light component struct needs to have its properties reverted back to the default ambient light
	// settings that is has when no flashlight is in use.
	if (isFlashlightOn){
		with(lightComponent) {set_properties(12, HEX_VERY_DARK_GRAY, -1.5, 360);}
		isFlashlightOn = false;
	}
	
	// Finally, clear the flag value from the item struct's "isEquipped" flag so the inventory knows
	// the change occurred, and reset the equip slot value for the flashlight back to its default.
	global.items[equipSlot.flashlight].isEquipped = false;
	equipSlot.flashlight = noone;
}

/// @description Alters the player object's built-in ambient light by turning it into their flashlight
/// whenever the flashlight is toggled on by the player. The properites of this light are based on
/// the current flashlight that is equipped on the player character.
toggle_flashlight = function(){
	// Altering the information in the lighting component to reflect the switching of the flag's
	// value within the player object.
	var _isFlashlightOn, _flashlightData;
	_isFlashlightOn = isFlashlightOn;
	_flashlightData = flashlightData;
	with(lightComponent){
		if (!_isFlashlightOn) {set_properties(_flashlightData.radius, _flashlightData.lightColor, _flashlightData.strength, 360);}
		else {set_properties(12, HEX_VERY_DARK_GRAY, -1.5, 360);}
	}
	
	// Play a clicking sound effect to signify the player character clicking their flashlight to
	// toggle it on and off within the actual game world itself.
	audio_play_sound_at_ext(x, y - 10, snd_player_flashlight, 0, 0.5 * SOUND_VOLUME, 1, 15, 30, 1, true);
	
	// Flipping the flag that tells this function whether it should turn the light on (The player's
	// lighting component will use the flashlight bulb's properties) or off. (The light will use the
	// default values for the player's ambient light source)
	isFlashlightOn = !isFlashlightOn;
}

#endregion

#region Armor functions

/// @description Equips a piece of armor to the player's available slot for equipping armor. It does
/// this by pulling in the damage resistance and movement penalty stats from the global master item
/// data ds_map. If another piece of armor was previously equipped, it will unequipped before the new
/// armor is equipped and its stats are applied.
/// @param slot
equip_protective_item = function(_slot){
	// First, check if there was a piece of armor equipped previously. If so, the previous armor has
	// its stats removed from the player's stats that it affects BEFORE the new armor's stats are
	// applied to them.
	if (equipSlot.armor != noone) {unequip_protective_item();}
	
	// Grab the stats of the protective item from the global item data ds_map, which holds the values
	// for damage resistance, (A percentage value for all damage taken) and speed adjustment values.
	var _equipmentStats = global.itemData[? KEY_EQUIPMENT_DATA][? global.items[_slot].itemName][? EQUIP_ARGUMENTS];
	damageResistance -=		_equipmentStats[| 0];
	maxHspdFactor -=		_equipmentStats[| 1];
	maxVspdFactor -=		_equipmentStats[| 1];
	
	// Finally, the flag in the item struct that lets the inventory know the item is equipped is set
	// to true, and the slot the armor is currently occupying is stored within the equipment slot
	// struct's variable for the protective item's slot.
	global.items[_slot].isEquipped = true;
	equipSlot.armor = _slot;
}

/// @description Unequips a piece of armor from the player's available slot for armor; doing so by 
/// reversing any affects to the player's damage resistance and movement speed values that the armor
/// alters.
unequip_protective_item = function(){
	// Grab the stats for the currently equipped armor from the global item data ds_map so that the
	// stats can have their values properly reversed. Otherwise, the effects from the armor will
	// be there even after the armor has been unequipped, and that's not correct.
	var _equipmentStats = global.itemData[? KEY_EQUIPMENT_DATA][? global.items[equipSlot.armor].itemName][? EQUIP_ARGUMENTS];
	damageResistance +=		_equipmentStats[| 0];
	maxHspdFactor +=		_equipmentStats[| 1];
	maxVspdFactor +=		_equipmentStats[| 1];
	
	// Finally, reset the flag within the item struct in order to let the inventory know this piece 
	// of armor is no longer equipped onto the player; resetting the "equipSlot" struct's value
	// abck to its default value of "noone" (-4).
	global.items[equipSlot.armor].isEquipped = false;
	equipSlot.armor = noone;
}

#endregion

#region Weapon functions

/// @description Equips the weapon by setting the value of its "equip slot" to whatever slot the
/// weapon is currently stored in. Then, the stats for the weapon are stored within the local struct
/// for all the equipped weapon's stats. (Ex. damage, sounds, sprites, etc.)
/// @param slot
equip_weapon = function(_slot){
	// If there was another wepaon already equipped in the "equip slot" for the weapon, it will be
	// unequipped by flipping that flag within the item in the inventory. This stops the inventory
	// from thinking the item is still equipped and accidentally placing the equipped symbol on the
	// item.
	if (equipSlot.weapon != noone) {global.items[equipSlot.weapon].isEquipped = false;}
	global.items[_slot].isEquipped = true;
	
	// Grabs all of the weapon's stats from the item data map. After the weapon's stats have been
	// grabbed they will all be placed in the player's weapon data struct; allowing for easier
	// access to these stats when they are required.
	var _itemData, _currentAmmo;
	_itemData = global.itemData[? KEY_WEAPON_STATS][? global.items[_slot].itemName];
	_currentAmmo = global.items[_slot].currentAmmo;
	with(weaponData){
		damage =			_itemData[? WEAPON_DAMAGE];
		range =				_itemData[? WEAPON_RANGE];
		typeID =			_itemData[? WEAPON_TYPE];
		accuracy =			_itemData[? WEAPON_ACCURACY];
		accPenalty =		_itemData[? WEAPON_ACC_PENALTY];
		fireRate =			_itemData[? WEAPON_FIRE_RATE];
		reloadRate =		_itemData[? WEAPON_RELOAD_RATE];
		fullReloadRate =	_itemData[? WEAPON_FULL_RELOAD_RATE];
		bulletCount =		_itemData[? WEAPON_BULLET_COUNT];
		bulletSpacing =		_itemData[? WEAPON_BULLET_SPACING];
		ammoTypes =			_itemData[? WEAPON_AMMO_TYPES];
		barrelPosition =	_itemData[? WEAPON_BARREL_POSITION];
		
		// Finding out how much ammunition is currently available for the weapon in the inventory.
		var _ammoInUse = global.items[_slot].currentAmmo;
		if (_ammoInUse != NO_AMMO)	{ammoRemaining = inventory_item_count(_ammoInUse);}
		else						{ammoRemaining = noone;} // Unique value when there is no ammunition.
		
		// Gather the ammunition modifier data from the ammunition that was last stored within the
		// weapon. If there was no ammunition data found, the modifier values will simply all be set
		// to zero since melee weapons don't use various ammunition types.
		var _ammoData = global.itemData[? KEY_AMMO_STATS][? _currentAmmo];
		if (!is_undefined(_ammoData)){ // Only ranged weapons will access this code.
			damageMod =			_ammoData[? AMMO_DAMAGE_MOD];
			accuracyMod =		_ammoData[? AMMO_ACCURACY_MOD];
			rangeMod =			_ammoData[? AMMO_RANGE_MOD];
			bulletCountMod =	_ammoData[? AMMO_BULLET_COUNT_MOD];
		} else{ // Only melee/infinite weapons will access this code.
			damageMod =			0;
			accuracyMod =		0;
			rangeMod =			0;
			bulletCountMod =	0;
		}
	}
	
	// 
	//useSprite =			_itemData[? WEAPON_USE_SPRITE];
	//aimingSprite =		_itemData[? WEAPON_AIMING_SPRITE];
	//reloadSprite =		_itemData[? WEAPON_RELOAD_SPRITE];
	
	// Loop through all the available ammunition types in order to set the index value for swapping
	// ammunition to match what is currently within the weapon when it's equipped.
	var _totalAmmoTypes = ds_list_size(weaponData.ammoTypes);
	for (var i = 0; i < _totalAmmoTypes; i++){
		if (weaponData.ammoTypes[| i] == global.items[_slot].currentAmmo){
			curAmmoType = i;
			break; // Exit the loop since the matching ammo index was found.
		}
	}
	
	// Finally, overwrite the value stored within the "equip slot" to whatever slot the equipped 
	// weapon is currently occupying in the inventory. This does nothing other than allow the weapon
	// to be readied in-game since it checks for this value to not equal "noone". (-4)
	equipSlot.weapon = _slot;
}

/// @description Unequips a weapon from the player. It does so by clearing out any values that were
/// contained in the entirety of the weapon stat struct, and then it resets the "equip slot" value 
/// to its default value of "noone". (-4)
unequip_weapon = function(){
	// Resetting all of the variables within the weaponData struct to reflect the fact that the
	// weapon will no longer be equipped to the player character; both the melee exclusive variables
	// and the ranged weapon variables since there is no way to determine what was unequipped.
	with(weaponData){
		// First, reset the three variables that are shared between all weapon types.
		damage =			0;
		range =				0;
		typeID =			noone;
		
		// Resetting all of the ranged weapon exclusive weapon stats in case the unequipped weapon
		// was a ranged weapon.
		accuracy =			0;
		accPenalty =		0;
		fireRate =			0;
		reloadRate =		0;
		fullReloadRate =	0;
		bulletCount =		0;
		bulletSpacing =		0;
		ammoTypes =			0;
		barrelPosition =	noone;
		
		// Resetting the calculated value for the weapon's surplus ammunition that exists within
		// the player's item inventory.
		ammoRemaining =		0;
		
		// Resetting the melee hitbox spawning frame data for the current melee weapon if one was
		// what was equipped.
		hitFrame =			0;
		
		// Resetting all ranged weapon stat modifier variables back to their default values in case
		// the unequipped weapon was a ranged weapon.
		damageMod =			0;
		rangeMod =			0;
		accuracyMod =		0;
		bulletCountMod =	0;
	}
	
	// Reset the ammo type's index since there isn't an array within the "ammoTypes" variable anymore.
	curAmmoType = 0;
	
	// Finally, once the weapon's data has been successfully reset by the code above, the equip
	// slot's weapon value will be reset to the default value of "noone" (-4). Before that, the item
	// that was equipped needs its flag flipped to reflect the unequipping action.
	global.items[equipSlot.weapon].isEquipped = false;
	equipSlot.weapon = noone;
}

/// @description A function that performs the logic for using the player's currently equipped weapon.
/// There are three possible weapon types: projectile, hitscane, and melee weapons. Each will have
/// a different effect when used, and this function handles all of that based on the type of the
/// currently equipped weapon.
use_weapon = function(){
	// In order to correctly use a given weapon, it needs to be determined if its a weapon that uses
	// ammunition OR not. This determines whether or not a check for the weapon's quantity in order
	// to trigger an automatic reload when the gun is completely empty.
	var _usesAmmo = (weaponData.ammoTypes[| curAmmoType] != NO_AMMO);
	
	// The auto-reloading logic, and also what stops a completely empty weapon with no more ammo
	// remaining in the inventory from being used. If there is ammo, the reloading state will be
	// set and the weapon will be reloaded instead.
	if (_usesAmmo && global.items[equipSlot.weapon].quantity == 0){
		if (weaponData.ammoRemaining > 0){ // Reload if there is available ammunition in the inventory.
			object_set_next_state(state_weapon_reload);
			reloadRateTimer = weaponData.fullReloadRate;
			timeToReload = reloadRateTimer; // Used for syncing reloading animation to reload time.
		}
		return; // Don't allow the weapon to be fired when it is completely empty.
	}
	
	// UNIQUE CASE -- If the weapon fires multiple bullets, but they're spaced out in their spawning;
	// the player will be put in a unique state that spawns those multiple bullets over a given
	// period of time.
	if (weaponData.bulletSpacing > 0){
		object_set_next_state(state_weapon_spaced_bullets);
		bulletsRemaining = weaponData.get_bullet_count();
		return; // Exit from the function before the regular bullet/hitbox-spawning logic is used.
	}
	
	// If the weapon that is equipped currently uses ammunition, (And its bullets aren't spaced out
	// between a set amount of frames) subtract one from its quantity.
	if (_usesAmmo) {global.items[equipSlot.weapon].quantity--;}
	
	// Determine how the weapon will be used based on its type. Depending on this value, the weapon
	// can either spawn a projectile based on the weapon, a single-frame hitscan check can be done
	// for the weapon, OR the melee attack logic can be initiated.
	switch(weaponData.typeID){
		case WeaponType.Projectile:
			use_weapon_projectile();
			// Once the weapon's necessary projectile object(s) were created by the above function
			// call, they will handle their own updating and physics/collisions. Otherwise, the
			// player will enter their recoil/recovery state.
			object_set_next_state(state_weapon_recovery);
			fireRateTimer = weaponData.fireRate;
			break;
		case WeaponType.Hitscan:
			use_weapon_hitscan();
			// After checking for the necessary hitscan collision(s) for the bullet(s) fired, jump
			// to the weapon's recovery state, which is what plays the recoil animation and counts
			// for the fire rate timer.
			object_set_next_state(state_weapon_recovery);
			fireRateTimer = weaponData.fireRate;
			break;
		case WeaponType.Melee:
			object_set_next_state(state_weapon_melee_attack);
			break;
	}
}

/// @description 
use_weapon_projectile = function(){
	// 
	var _projectileObject = asset_get_index(global.itemData[? KEY_EQUIPMENT_DATA][? global.items[equipSlot.weapon]][? EQUIP_ARGUMENTS]);
	if (is_undefined(_projectileObject)) {return;} // Return before attempting to create an invalid object.
	
	// 
	var _weaponData, _bulletCount, _instance;
	_weaponData = weaponData;
	_bulletCount = weaponData.get_bullet_count();
	repeat(_bulletCount){ // Repeat for as many bullets as required.
		_instance = instance_create_object(x, y, _projectileObject);
		with(_instance){
			// TODO -- Carry over weapon stats here.
		}
	}
	
	// 
	
}

/// @description Performs a raycast to check for collisions between the fired projectile and any
/// objects that is hits along that path; the length of the cast being the magnitude of the max
/// range for the equipped weapon. It will continue checking each collision along the way until
/// an object is hit that ends the check altogether, which means the bullet collided with something
/// it couldn't pass through. (Ex. Almost all walls and hostile entities will stop bullets)
use_weapon_hitscan = function(){
	// Calculate the start position of the raycast based on the player's current direction and the direction
	// they are currently facing; north, east, south, or west. In order to reference the correct indexes
	// for the barrel position at that direction, the current direction is divided by 90 and then multiplied
	// by 2 since each "index" contains an x and y position, respectively. Then, those found values are
	// added to the player's coordinates to get the correct position of the gun's barrel.
	var _index, _barrelPosition, _startX, _startY;
	_index = round(direction / 90) * 2;
	_barrelPosition = weaponData.barrelPosition; // Store the reference to the list for faster execution.
	_startX = x + _barrelPosition[| _index];
	_startY = y + _barrelPosition[| _index + 1];
	
	// In order to get the direction of the player, but clamps to one of the four valid aiming directions,
	// the index value that was calculated is multiplied by 45 to achieve said values.
	var _direction = _index * 45; // Multiply the index by 45 to get the values 0, 90, 180, and 270 for valid aiming directions.
	
	// Next, the max possible directional offset for the raycast (AKA the accuracy that makes the 
	// bullet spray randomly around a given offset) needs to be calculated relative to the current
	// accuracy penalty and the base accuracy for the weapon; limiting the cone to a maximum angle
	// of 80 on each side relative to the player's clamped direction value.
	var _accuracy, _range;
	_accuracy = min(weaponData.get_accuracy() + accuracyPenalty, ACCURACY_CONE_LIMIT);
	_range = weaponData.get_range(); // Grabs and stores the range for the weapon as well.
	
	// Then, the amount of times that the raycast collision logic needs to be ran is calculated
	// here; defaulting to a value of one. However, if the weapon is set to spawn multiple bullets
	// at the same time, (AKA all shotguns in the game) the number of collision checks will be
	// set to the total number of "bullets" that the weapon uses per trigger pull.
	var _length = 1; // By default there should only be a single bullet fired. Hence the "= 1" piece of code.
	if (weaponData.bulletSpacing == 0) {_length = weaponData.get_bullet_count();}
	
	// Now the collision check loop will begin, which will only ever run multiple times when the
	// player is firing a shotgun, or shotgun-like weapon. In short, it will calculate the direction
	// for the bullet based on the calculated accuracy cone; determining the ending coordinates
	// based on that calculated direction value. Then, a call to the function "collision_line_list"
	// is performed, which will create a list populated with the objects it collided with in order.
	// Then, the collisions are handled with a switch statement that holds data for all the valid
	// collisions between a bullet and the world.
	var _collisionList, _bulletDirection, _endX, _endY, _listLength, _objIndex;
	_collisionList = ds_list_create();
	for (var i = 0; i < _length; i++){
		// Setting the offset direction and ending positions for the current hitscan check--these
		// values being unique to each check performed.
		_bulletDirection = _direction + random_range(-_accuracy, _accuracy);
		_endX = _startX + lengthdir_x(_range, _bulletDirection);
		_endY = _startY + lengthdir_y(_range, _bulletDirection);
	
		// Call the collision function and set it to check for EVERY object that is along the
		// ray; ordering the list of collided objects from closest to the starting coordinates
		// to the ending coordinates.
		collision_line_list(_startX, _startY, _endX, _endY, all, false, true, _collisionList, true);
		
		// Now, the collisions need to be processed, which involves looping through the list
		// of collided objects and resolving their collisions based on matching object index
		// values. (Child actors will use their parent's object index unless specified otherwise)
		_listLength = ds_list_size(_collisionList);
		for (var j = 0; j < _listLength; j++){
			// 
			with(_collisionList[| j]){
				_objIndex = object_get_parent(object_index);
				if (_objIndex == NO_PARENT) {_objIndex = object_index;}
				
				// 
				switch(_objIndex){
					case obj_collider:
						j = _listLength;
						break;
				}
			}
		}
		// TODO -- Turn this loop above into a dedicated function that the player and the player
		// projectile objects can use to reference how to handle collisions.
		
		// FOR TESTING COLLISIONS
		with(DEBUGGER) {debug_add_line(_startX, _startY, _endX, _endY, c_white, 100);}
	}
	// Remember to remove the temporary ds_list from memory to avoid a leak occurring.
	ds_list_destroy(_collisionList);
	
	// Finally, apply the accuracy penalty that occurs from the weapon being shot. Also max out the
	// buffer timer that is counted down before the accuracy penalty's value gets reduced; preventing
	// it from constantly depleting instantly after a shot has been fired.
	accuracyPenalty = min(accuracyPenalty + weaponData.accPenalty, ACCURACY_PENALTY_LIMIT);
	penaltyReductionTimer = PENALTY_REDUCTION_PAUSE_TIME;
}

/// @description The function that handles the accuracy penalty reduction logic. In short, the function
/// will not do anything if there isn't an accuracy penalty currently being applied to the player's base
/// accuracy value for their equipped weapon OR the player is firing/holding the input AND they aren't
/// currently reloading despite that. If neither of those conditions are met, the penalty reduction buffer
/// timer is reduced until it hits 0; after which the accuracy penalty is reduced at a little over half 
/// the standard rate of 1 unit per 1/60th of a second with respect to delta time.
update_accuracy_penalty = function(){
	// If the accuracy penalty has already been reduced to zero OR the player has the using weapon
	// input held down, the logic to actually reduce the pausing timer or penalty value will not
	// need to be ran, so the function will be exited early.
	if (accuracyPenalty == 0 || (inputUseWeapon && reloadRateTimer <= 0)) {return;}
	
	// Count down the reduction timer, which is a value that prevents the accuracy penalty from
	// beginning its reduction process immediately after a shot was fired and the player stopped
	// firing said weapon. (AKA the input was released) After the timer reaches 0, the accuracy
	// penalty will begin to be reduced back down to 0.
	penaltyReductionTimer -= DELTA_TIME;
	if (penaltyReductionTimer <= 0){
		accuracyPenalty -= DELTA_TIME * 0.75; // Takes a little under half a second to fully reduce the accuracy penalty when it's at its max value.
		if (accuracyPenalty < 0) {accuracyPenalty = 0;}
	}
}

/// @description A simple function that reloads the currently equipped weapon for the player OR the
/// weapon found within whatever other slot index was provided for this function. This argument is
/// used because reloading the weapon can occur from within the item inventory, and with weapons 
/// that aren't even equipped in the item inventory as well.
/// @param slot
reload_weapon = function(_slot){
	var _ammoNeeded = 0; // Stores the amount of ammo needed from within the inventory.
	with(global.items[equipSlot.weapon]) {_ammoNeeded = maxQuantity - quantity;}
	
	// Determine how much of the ammunition exists within the inventory, and find out how much
	// of the ammo is leftover from the total requirement relative to the amount that was found
	// in the inventory, if there wasn't enough to fill the flip.
	var _leftover = inventory_item_remove_amount(weaponData.ammoTypes[| curAmmoType], _ammoNeeded);
	global.items[equipSlot.weapon].quantity += _ammoNeeded - _leftover;
	
	// Finally, update the variable that stores the total quantity of the weapon's current ammo
	// within the inventory to match how much was removed  to put into the gun.
	with(weaponData) {ammoRemaining = max(ammoRemaining - (_ammoNeeded - _leftover), 0);}
}

/// @description Swapping the equipped weapon's currently used ammunition type. This is done by
/// looping through the list of valid ammunition types found within the equipped weapon's data. If
/// a valid ammunition for the weapon is found in the inventory, it will be put into the gun and the
/// previous ammunition will be sent back into the inventory. Otherwise, nothing will happen and
/// the weapon will keep its previous ammunition in use.
swap_weapon_ammo = function(){
	// First, store the pointer to the list of ammo types within a local variable for quicker access.
	// Also, determine how many ammo types there are within that list; storing the result for quick
	// access as well.
	var _ammoTypes, _numAmmoTypes;
	_ammoTypes = weaponData.ammoTypes;
	_numAmmoTypes = ds_list_size(_ammoTypes);
	
	// Then, store the ammo type that was in the gun BEFORE they pressed the swap ammunition key,
	// which will be used to end the loop below. Then, increment the current ammo time by one index;
	// looping back to 0 if that number exceeds the number of ammo types.
	var _prevAmmoType = curAmmoType;
	curAmmoType++;
	if (curAmmoType >= _numAmmoTypes) {curAmmoType = 0;}
	
	// Make one more local variable, which will store the total quantity of the next available
	// ammunition type for the weapon. Then, the loop will begin to search for an ammo type that
	// exists in the inventory IF there is any of those ammunition types.
	var _ammoCount;
	while(curAmmoType != _prevAmmoType){
		// First, count how much of the next ammo types exists within the inventory. If there is
		// any, this new ammunition type will be switched into the weapon and the previous ammo will
		// be removed from the gun and placed into the inventory if possible.
		_ammoCount = inventory_item_count(_ammoTypes[| curAmmoType]);
		if (_ammoCount > 0){
			// Attempt to add the previous ammunition to the item inventory, and remove that
			// quantity from the weapon's item struct quantity to make room for the new ammo type.
			inventory_item_add(_ammoTypes[| _prevAmmoType], global.items[equipSlot.weapon].quantity, 0);
			global.items[equipSlot.weapon].quantity = 0;
			
			// Store that "_ammoCount" variable's value within the weapon's variable that stores the
			// total remaining ammunition for easy displaying to the player on the HUD.
			weaponData.ammoRemaining = _ammoCount;
			
			// Finally, set the player to reload their weapon by assign their state to that, and
			// setting up the two reload timer variable values that the state relies on to function.
			// The reload will result in the new ammunition being put in the equipped weapon.
			object_set_next_state(state_weapon_reload);
			reloadRateTimer = weaponData.fullReloadRate;
			timeToReload = reloadRateTimer;
			break; // Breaks out of the loop early, since there's no need to continue.
		}
		
		// If the "_ammoCount" value was equal to 0 it means there was no amount of that type found
		// within the inventory, so the next ammunition type will be checked. Increment the value
		// that tracks the current ammo type and loop around again.
		curAmmoType++;
		if (curAmmoType >= _numAmmoTypes) {curAmmoType = 0;}
	}
}

#endregion

#region Throwable functions

/// @description 
/// @param slot
equip_throwable = function(_slot){
	
}

/// @description 
unequip_throwable = function(){
	
}

#endregion

#region Functions for Status Conditions and Addition Buffs/Debuffs

/// @description Updates the player's ailments and the timer that is paired with dealing out those ailment
/// effects at regular intervals. Despite the fact that there are three main ailments: bleeding, poisoned,
/// and crippled; only the first two have effects that trigger every few seconds, so they are updated here.
update_player_ailments = function(){
	// If the player isn't poisoned or bleeding, there is no reason to execute the rest of the function and
	// it will simply be exited out of here.
	if (!isBleeding && !isPoisoned) {return;}
	
	// While either (or both) of the status ailments are active, a timer will decrement from a value of 150;
	// this value being equal to 2.5 seconds of real-world time. Once the timer hits 0, a check will be
	// performed to see if the bleeding ailment is active; dealing a set percentage of damage if it is, and
	// another check to see if they are poisoned; dealing increasing damage over time every OTHER timer
	// check.
	ailmentTimer -= DELTA_TIME;
	if (ailmentTimer <= 0){
		ailmentTimer = AILMENT_EFFECT_TIME;
		
		// Store the current maximum hitpoints for the player since it will be needed for both ailment
		// effects as they work off a percentage relative to that maximum. If they are bleeding currently,
		// the set 2.5% max hitpoint damage is remove from the player's current hitpoints.
		var _maxHitpoints = get_max_hitpoints();
		if (isBleeding) {set_hitpoints(-(_maxHitpoints * BLEED_DAMAGE));}
		
		// Next, check if they are poisoned. If they are and NOT set to deal poison damage on the current
		// checking interval, the flag for dealing damage is flipped. Otherwise, the damage is dealt out
		// and then its value is doubled; dealing increasing damage as the effect lingers.
		if (isPoisoned){
			if (dealPoisonDamage){
				set_hitpoints(-(_maxHitpoints * curPoisonDamage));
				curPoisonDamage *= 2; // Doubles the damage each time (1% health -> 2% -> 4%...)
			}
			// Flip the flag so that damage is dealt every OTHER ailment timer check. (5 seconds instead of
			// the standard 2.5 seconds that bleeding will take)
			dealPoisonDamage = !dealPoisonDamage;
		}
	}
}

/// @description The function that handles toggling the "bleeding" status ailment on the player, which is
/// an extremely simple status that deals out damage every 2.5 seconds. When bleeding is set to active, the
/// damage timer will be reset so it takes 2.5 seconds for the damage to actually occur.
/// @param isBleeding
set_bleeding = function(_isBleeding){
	isBleeding = _isBleeding;
	if (_isBleeding) {ailmentTimer = AILMENT_EFFECT_TIME;}
}

/// @description The function that handles toggling the "poisoned" status ailment to be active or not on the
/// player. When activated, it will set the damage to take place 5 seconds AFTER initial poisoning, and when
/// removed the damage variables are reset to their default values.
/// @param isPoisoned
set_poisoned = function(_isPoisoned){
	isPoisoned = _isPoisoned;
	if (_isPoisoned){ // When the player is first inflicted with poisoning, the ailment timer will be reset, regardless of if they are currently bleeding or not.
		ailmentTimer = AILMENT_EFFECT_TIME;
		return;
	}
	// The player is no longer poisoned, reset the variables that are responsible for allowing poison damage
	// to be dealt out to false and a value of 0.01, (1%) respectively.
	dealPoisonDamage = false;
	curPoisonDamage = BASE_POISON_DAMAGE;
}

/// @description The function that handles applying the "crippled" status ailment onto the player or having
/// them recover from it. In short, it won't deal any period damage, but it will instead alter the player's
/// maximum hitpoints and stamina; reducing them by 25% and 50%, respectively. On top of that, the stamina
/// depletion and regeneration speeds are also debuffed.
/// @param isCrippled
set_crippled = function(_isCrippled){
	isCrippled = _isCrippled;
	if (isCrippled){ // Active the "crippled" status; applying all its stat debuffs here.
		// Reduces max hitpoints by 25% of the current maximum.
		set_max_hitpoint_factor(-0.25, true);
		
		// Then, the stamina for the player is heavily altered to make it deplete much faster, regenerate
		// much slower, and have half of its previous maximum available. The depletion speed is increased
		// by 50%, specifically, and the regen speed takes stamina twice as long to fully recover.
		staminaDepletionModifier += 0.5;
		maxStaminaFactor -= 0.5;
		staminaRegenSpeed -= 0.5;
		
		// Finally, the current stamina for the player is halved to match the fact that their maximum stamina 
		// was also just cut in half. Removing the crippled ailment doesn't reverse this effect; that will 
		// be done during the standard stamina regeneration instead.
		stamina = max(0, stamina - (stamina * 0.5));
		return;
	}
	// The player is no longer crippled, so reverse all of the effects that were applied to their various
	// stats by reversing the signs of the values being added/subtracted.
	set_max_hitpoint_factor(0.25, true);
	staminaDepletionModifier -= 0.5;
	maxStaminaFactor += 0.5;
	staminaRegenSpeed += 0.5;
}

/// @description
/// @param effectID
/// @param duration
/// @param startFunction
/// @param endFunction
add_additional_effect = function(_effectID, _duration, _startFunction, _endFunction){
	// 
	var _index = ds_list_find_index(effectKeys, _effectID);
	if (_index != -1){
		with(additionalEffects[? effectKeys[| _index]]){
			if (_duration > timeRemaining && timeRemaining != INDEFINITE_EFFECT_DURATION) {timeRemaining = _duration;}
		}
		return;
	}
	
	// 
}

/// @description 
/// @param key
remove_additional_effect = function(_key){
	
}

#endregion

#region Miscellaneous functions

/// @description The function that is called in order to start the player objects functionality. It will set
/// their starting position, attach the camera to them as they move around the game world, add the light
/// component, set their sprite, maximum movement speed, set their starting hitpoints, set up their drop
/// shadow, and initialize their starting state.
initialize = function(){
	// 
	x = 160;
	y = 150;
	
	// 
	camera_set_state(STATE_FOLLOW_OBJECT, [id, 8]);
	
	// 
	object_add_light_component(x, y, 0, -12, 32, HEX_VERY_DARK_GRAY, -10, 360, 0, true);
	object_set_shadow(true, 6);

	// 
	set_sprite(spr_player_unarmed_stand0, 0);

	// 
	maxHspd = 0.65;
	maxVspd = 0.65;
	
	// 
	hitpoints = 20;
	maxHitpoints = 20;
	
	// 
	object_set_next_state(state_default);
	curState = state_default; // To prevent the state from taking an in-game frame to actually be set; simply set it here instantly.
}

/// @description Updating the player object's movement variables; doing so by getting the current
/// keyboard input values from the four directional input flags and determining the resulting
/// horizontal and vertical velocity for the player object, respectively.
update_movement = function(){
	// First, determine the magnitude and direction of movement based on the movement keys that the
	// player are currently pressing. No movement is processed for a given axis if opposite keys
	// for the same axis are pressed simultaneously.
	inputMagnitude = ((inputRight - inputLeft) != 0) || ((inputDown - inputUp) != 0);

	// Determining if the player is running based on the default value or simply holding the button
	// down for the entire time they wish to run, or by pressing it once to toggle the running and
	// pressing it again to revert back to walking.
	if (global.settings.isRunToggle && inputRun) {isRunning = !isRunning;}
	else if (!global.settings.isRunToggle) {isRunning = inputRun;}
	
	// Handling the logic for running, which will cause the player object to move fast for a given
	// duration until the stamina variable is completely drained. After that, the player will move
	// as a slower pace until they stop running for enough time that the stamina value can regenerate.
	var _runningModifier = 1;
	if (isRunning * inputMagnitude != 0){ // Increase the player's speed if they still have stamina.
		if (stamina > 0){
			stamina -= (DELTA_TIME + (staminaDepletionModifier * DELTA_TIME));
			if (!isCrippled) {_runningModifier = 2.35;}	// 135% boost to movement speed when not cippled;
			else			 {_runningModifier = 1.75;} // only a 75% boost otherwise.
		} else if (!isCrippled){ // The "out of stamina" speed isn't possible while crippled.
			_runningModifier = 1.65; // Only a 65% boost when out of initial stamina.
		}
	} else if (stamina < get_max_stamina()){ // Prevent running and slowly recharge the player's stamina over time.
		staminaRegenTimer += DELTA_TIME;
		if (staminaRegenTimer >= STAMINA_REGEN_PAUSE_TIME){ // Pause for 2.5 seconds before refilling the stamina variable.
			stamina += 0.5 * DELTA_TIME * staminaRegenSpeed;
			if (stamina >= get_max_stamina()){ // Max out the stamina and stop the recharging code from running.
				stamina = get_max_stamina();
				staminaRegenTimer = 0;
			}
		}
		// Resets the running flag to its default value. (It isn't automatically reset if the player
		// has the accessibility setting active that makes running a toggle input)
		isRunning = false;
	}
	
	// Setting the player's horizontal and vertical velocity based on the direction the player has
	// been set to move in relative to the input combination of the four directional movement keys.
	// Then, the position of the player is updated and collision is processed using the default
	// entity positional update function.
	hspd = lengthdir_x(inputMagnitude * get_max_hspd() * _runningModifier, inputDirection);
	vspd = lengthdir_y(inputMagnitude * get_max_vspd() * _runningModifier, inputDirection);
	update_position(false);
}

/// @description A simple function that checks for a collision between the player's mask and a cutscene
/// trigger's mask. When this occurs, the cutscene's event flag to set to the required state and the
/// scene will begin playing out. Otherwise, the scene will be triggered every time the trigger collision
/// occurs.
check_collision_cutscene_trigger = function(){
	var _trigger = instance_place(x, y, obj_cutscene_trigger);
	with(_trigger){
		cutscene_begin_execution(_trigger, sceneInstructions, startingIndex);
		if (eventFlagID != noone) {EVENT_SET_FLAG(eventFlagID, eventTargetState);}
	}
}

/// @description Checks for collisions between the player's "interaction point", which is a point in one of
/// the eight input directions that determines their viewpoint for interactable objects, and one of the
/// interactable object's "interaction radius", which is the radius around their origin point that determines
/// the area that the player's interaction point must be within in order to process an interaction.
check_collision_interactable = function(){
	// First, get the player's interaction point coordinates, which will be an 8x8 circle that is offset
	// vertically by 6 pixels so it's more in line with the character's face in the artwork while also
	// considering the whole 2.5d perspective of the game.
	var _x, _y, _interactableID;
	_x = x + lengthdir_x(8, direction);
	_y = y + lengthdir_y(8, direction) - 6;
	_interactableID = noone;
	
	// Loop through all existing interaction components and compare their area of interaction against the
	// player's current interaction point. If they can be interacted with (The player can actually see it
	// or they've seen it previously) AND the interaction point is within their radius of interaction, their
	// unique pointer is returned and stored within the player's variable for tracking the current object
	// can interact with when the user pressed the "interact" key.
	var _length = ds_list_size(global.interactables);
	for (var i = 0; i < _length; i++){
		with(global.interactables[| i]){
			if (canInteract && point_distance(x, y, _x, _y) <= radius){
				_interactableID = global.interactables[| i];
				break;
			}
		}
	}
	
	// Set the actual player variable "interactableID" to whatever value was set within the local variable
	// after looping through all interactable objects has been completed. If no interactable exists at the
	// current interaction point, this value will be set to "noone".
	interactableID = _interactableID;
}

/// @description The function that is responsible for playing the footstep sound effects for the
/// player object whenever they move around the game world. If there is no valid footstep tile at
/// the feet of the player, no sound will actually play. Otherwise, the matching material's sound
/// will be played for each of the player's footstep frames.
play_footstep_sound = function(){
	// In order to see if the footstep sound should be played, the integer image index value parsed
	// for whatever direction the player is moving is grabbed and then checked against both foot index
	// values. However, if the flag to play the sounds is false no sound will be played at all.
	var _imageIndex = floor(imageIndex) % loopLength;
	if (canPlayFootstep && (_imageIndex == rightStepIndex || _imageIndex == leftStepIndex)){
		// In order to add variance to each of the player's footsteps on any given material, the
		// volume and pitch of each step will be randomly altered from within a range of values.
		// The sound's fading distance and max audible range is set here, and altered if running.
		var _volume, _pitch, _refDistance, _maxDistance;
		_volume = random_range(0.15, 0.35) * SOUND_VOLUME;
		_pitch = 1 + random_range(-0.05, 0.05);
		_refDistance = 25;
		_maxDistance = 75;
		
		// Whenever the player is running, the sound of the footstep needs to be altered to be more
		// impactful/louder to the user. To do this, an increase will be applied to the volume from
		// a larger range than normal. On top of this, the pitch of the sound will be lowered in
		// pitch. Finally, the maximum distance that the sound can be heard is vastly increased.
		if (isRunning){
			_volume += random_range(0.3, 0.4);
			_pitch -= random_range(0.08, 0.12);
			_refDistance = 60;
			_maxDistance = 150;
		}
		
		// Whenever a new tile has been found by this tilemap pixel check for a given tile, the
		// sound effect that will play for each of the player's footsteps will need to be updated
		// to match it. (Or to stop all sound entirely if there is no valid footstep material under
		// the player's feet) So, the switch statement below will find the matching material and
		// set the proper sound to match.
		var _tileIndex = tile_get_index(tilemap_get_at_pixel(footstepTilemap, x, y));
		if (_tileIndex != lastTileIndex){
			lastTileIndex = _tileIndex;
			switch(_tileIndex){
				case FLOOR_MATERIAL_TILE:	curFootstepSound = snd_player_step_tile;	break;
				case FLOOR_MATERIAL_WOOD:	curFootstepSound = snd_player_step_wood;	break;
				case FLOOR_MATERIAL_MUD:	curFootstepSound = snd_player_step_mud;		break;
				case FLOOR_MATERIAL_WATER:	curFootstepSound = snd_player_step_water;	break;
				case FLOOR_MATERIAL_SNOW:	curFootstepSound = snd_player_step_snow;	break;
				case FLOOR_MATERIAL_GRASS:	curFootstepSound = snd_player_step_grass;	break;
				case FLOOR_MATERIAL_GRAVEL:	curFootstepSound = snd_player_step_gravel;	break;
				default:					curFootstepSound = NO_SOUND;				break;
			}
		}
		
		// Only bother attempting to play a sound if there is currently a valid sound index stored
		// within the "curFootstepSound" variable. Otherwise, play the stored sound that is paired
		// with the given index whenever a footstep sound needs to be played.
		if (curFootstepSound != NO_SOUND) {audio_play_sound_at_ext(x, y, curFootstepSound, 0, _volume, _pitch, _refDistance, _maxDistance, 1, true);}
	}
	// Only flip the flag back to "true" if the player's whole number image index value is no longer
	// equal to either of the footstep frame index values. Otherwise, it will remain false until then.
	canPlayFootstep = (_imageIndex != rightStepIndex && _imageIndex != leftStepIndex);
}

#endregion

#region State functions

/// @description A unique variation on the dynamic entity's default "state_cutscene_move" function, which
/// is used to move said entity during a cutscene if they've been set to do so by the cutscene's scene
/// instructions. The variation here will call the parent's function to handle the movement logic, but
/// will also apply the player's curretn alking animation while also playing footstep sound effects for
/// said animation.
__state_cutscene_move = state_cutscene_move; // Stores the parent function before overriding it.
state_cutscene_move = function(){
	__state_cutscene_move();
	set_sprite(walkSprite, 1);
	play_footstep_sound();
}

/// @description The player's default state. In short, it allows the player to move their character
/// around the game world, interact with the game world, toggle their flashlight, (If it's equipped)
/// and ready their weapon. (If it's equipped)
state_default = function(){
	// First, get the input from the player's current control method (Either gamepad or keyboard)
	// and then check if the movement needs to be updates based on the character movement inputs
	// with the "update_movement" function.
	check_player_input();
	update_movement();
	
	// When pressing the interact input, the closest available interactable object that is currently
	// colliding with the player's interaction point (This is all done within a separate collision check
	// function) will have its associated interaction function executed.
	if (inputInteract) {with(interactableID) {script_execute(interactFunction);}}
	// Toggling the player's flashlight on/off. (If one is currently equipped)
	else if (inputFlashlight && equipSlot.flashlight != noone) {toggle_flashlight();}
	// Finally, process the input for readying the player's equipped weapon, which will swap their
	// state over to their "aiming/readied" weapon state; allowing them to use it in-game.
	else if (inputReadyWeapon && equipSlot.weapon != noone)	{object_set_next_state(state_weapon_ready);}
	
	// Handle what sprite to use for the player based on a single condition: is the player moving or
	// not at the current moment. If that's the case, the walking/running animation will play, and
	// the standing sprite will be used otherwise.
	if (inputMagnitude != 0){
		direction = inputDirection; // Only update the player's direction when there is valid input.
		set_sprite(walkSprite, 1);
		// Call the function responsible for handling footstep sounds during this chunk of code 
		// that only runs when the player is moving/recieving input from the user.
		play_footstep_sound();
	} else{
		set_sprite(standSprite, 1);
		// Stop the footstep sound from playing so it doesn't continue playing while the player
		// is no longer moving. Also, reset the flag to play the next footstep sound to true.
		if (audio_is_playing(curFootstepSound)) {audio_stop_sound(curFootstepSound);}
		canPlayFootstep = true;
	}
}

/// @description The state for the player whenever their weapon is ready for use. In short, the state
/// only allows the player to do things that affect their weapon; whether that's reloading, using
/// the weapon, or switching the weapon's current ammunition type. (Reloading and swapping ammo only
/// being possible with "ranged" weaponry--not melee and infinite weapons)
state_weapon_ready = function(){
	// First, call the state that gets the player's current input from their currently active 
	// control method. (Can be either keyboard or a gamepad)
	check_player_input();
	
	// Returning the player to their default state, but only if they release the button that they
	// must have held down in order to keep the weapon ready, (If the toggle accessibility setting 
	// is active they only need to press the button again to exit to the default state) or they
	// no longer have a weapon equipped for whatever reason.
	if ((!inputReadyWeapon && !global.settings.isAimToggle) || (inputReadyWeapon && global.settings.isAimToggle) || equipSlot.weapon == noone){
		object_set_next_state(state_default);
		return; // Exit the state early to prevent the weapon from being used.
	}
	
	// Attempting to swap the current ammunition that is contained within the player's currently
	// equipped weapon. Nothing will occur if the equipped weapon is a melee weapon/a weapon
	// with infinite ammunition OR if no other ammunition for the weapon exists within the inventory.
	if (inputSwapAmmo) {swap_weapon_ammo();}
	// Reloading the currently equipped weapon if there is available ammunition within the inventory
	// for it. If the magazine is completely empty, the reload state will use the wepaon's "full"
	// and longer reload rate. Otherwise, the standard reload speed is used.
	else if (inputReload && weaponData.ammoRemaining > 0){
		if (global.items[equipSlot.weapon].quantity > 0) {reloadRateTimer = weaponData.reloadRate;}
		else {reloadRateTimer = weaponData.fullReloadRate;}
		object_set_next_state(state_weapon_reload);
		timeToReload = reloadRateTimer; // Used for syncing reloading animation to reload time.
	}
	// Using the currently equipped weapon, which only requires that the input for weapon use is
	// pressed by the player; everything else being checked and handled within the function.
	else if (inputUseWeapon) {use_weapon();}
	
	// Determine the direction the player is facing if they press any of the four direction inputs
	// Otherwise, the sprite will simply be drawn based on the direction the player is facing.
	inputMagnitude = ((inputRight - inputLeft) != 0) || ((inputDown - inputUp) != 0);
	if (inputMagnitude != 0) {direction = point_direction(0, 0, (inputRight - inputLeft), (inputDown - inputUp));}
	set_sprite(aimingSprite, 0);
}

/// @description The state that the player enters whenever they fire a ranged weapon. (The grenade 
/// launcher doesn't enter this state since it always reloads after each shell that's fired) In
/// short, it will prevent any movement or input from being detected until the weapon's fire rate
/// timer (60 units = 1 second of real-time) has been fully depleted. After that, the player will
/// be returned to their "weapon ready" state.
state_weapon_recovery = function(){
	fireRateTimer -= DELTA_TIME;
	if (fireRateTimer <= 0) {object_set_next_state(state_weapon_ready);}
	
	set_sprite(useSprite, 0); // Lock animation speed to match the length of the recoil
	imageIndex = loopOffset + ((1 - (fireRateTimer / weaponData.fireRate)) * loopLength);
}

/// @description The state that the player enters whenever they reload their currently equipped
/// weapon. (Melee and infinite weapons are exempt from this state) Much like the fire rate state,
/// the player will be locked from performing any actions until the timer has fully depleted. After
/// that the weapon will be reloaded be calling the function for doing so, and the player will be
/// return to their "weapon ready" state.
state_weapon_reload = function(){
	reloadRateTimer -= DELTA_TIME;
	if (reloadRateTimer <= 0){
		object_set_next_state(state_weapon_ready);
		reload_weapon(equipSlot.weapon);
	}
	
	set_sprite(reloadSprite, 0);  // Lock animation speed to match the length of the reload
	imageIndex = loopOffset + ((1 - (reloadRateTimer / timeToReload)) * loopLength);
}

/// @description A unique state for using a weapon when that weapon has a multi-burst effect for each
/// pull of the trigger (AKA the "Triple-Burst Handgun") In short, the bullets will be spawned with
/// a set amount of frames between them; repeating this timer countdown until the number of bullets
/// needed has been met OR the weapon runs out of bullets.
state_weapon_spaced_bullets = function(){
	// The two exit conditions for the state: completing the spawning/hitscans for all the required
	// bullets (This is determined by the weapon's "Bullet Count" stat) OR the weapon has run out
	// of ammunition prior to the required amount being spawned. Either condition will result in
	// the standard fire rate state being activated.
	if (bulletsRemaining == 0 || global.items[equipSlot.weapon].quantity == 0){
		object_set_next_state(state_weapon_recovery);
		fireRateTimer = weaponData.fireRate;
		bulletSpacingTimer = 0;
		imageIndex = 0;
		return; // Exits the state function early to prevent any accidental excess bullet spawns.
	}
	
	// Decrementing the timing responsible for spawning each bullet in a sequence of time instead
	// of all at once like a shotgun would function, for example. Once the timer has gone below 0,
	// the bullet creation logic will be processed, and the whole thing restarts if it needs to.
	bulletSpacingTimer -= DELTA_TIME;
	if (bulletSpacingTimer <= 0){
		// Since the switch statement doesn't sent the player object to the next state like it
		// does within the "use_weapon" function, it will instead just call either the projectile
		// OR hitcscan code for every necessary bullet that will be spawned.
		switch(weaponData.typeID){
			case WeaponType.Projectile:	use_weapon_projectile();	break;
			case WeaponType.Hitscan:	use_weapon_hitscan();		break;
		}
	
		// Resetting the timer back to whatever the "Bullet Spacing" value is for the weapon, (This
		// value is measured in "frames", where 1/60th of a real-world second is a frame) and also
		// resetting the weapon's use sprite's animation for the next possible bullet spawning.
		bulletSpacingTimer = weaponData.bulletSpacing;
		imageIndex = 0;
		
		// Finally, remove one from the weapon's magazine (This is the same as the quantity value
		// for regular stacking items; hence the "quantity--". Also, decrement the remaining sum 
		// of bullets to spawn before restarting the spaced bullet spawning logic.
		global.items[equipSlot.weapon].quantity--;
		bulletsRemaining--;
	}
	
	// Set the sprite for this state to be the weapon's use animation, which is automatically reset
	// every time a new bullet is spawned in order to match the animation to the bullets actually
	// being created in the game world itself.
	set_sprite(useSprite, 1);
}

/// @description 
state_weapon_melee_attack = function(){
	
}

#endregion
