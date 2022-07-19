/// @description Insert summary of this file here.

#region Initializing any macros that are useful/related to obj_weather_rain

// Determines the total amount of raindrops that can exist simultaneously at any given time. This amount
// is any value between these two range constants.
#macro	MIN_RAINDROPS				95
#macro	MAX_RAINDROPS				130

// The range in "frames" (One frame = 1/60th of a second in the real world) that occurs between spawning
// each raindrop until the total amount of required raindrops have been created by the weather effect.
#macro	MIN_SPAWN_BUFFER			2
#macro	MAX_SPAWN_BUFFER			10

//
#macro	RAIN_Y_START_OFFSET			32

#endregion

#region Initializing enumerators that are useful/related to obj_weather_rain
#endregion

#region Initializing any globals that are useful/related to obj_weather_rain
#endregion

#region The main object code for obj_weather_rain

function obj_weather_rain() constructor{
	// Much like Game Maker's own object_index variable, this will store the unique ID value provided to this
	// object by Game Maker during runtime; in order to easily use it within a singleton system.
	object_index = obj_weather_rain;
	
	// Stores all of the instances of raindrops that currently exist for the weather effect. The variable
	// "totalRaindrops" determines how many raindrops can exist within the ds_list at once; determined by
	// randomly choosing a value between the two set minimum and maximum range values.
	raindrops = ds_list_create();
	totalRaindrops = irandom_range(MIN_RAINDROPS, MAX_RAINDROPS);
	
	// Determines the gap in "frames" (One frame being 1/60th of a real-world second) that space out the
	// spawning of rain droplets; making the rain smoothly begin from no raindrops to a gradual screen full
	// of them.
	spawnBuffer = 0;
	
	// A simple toggle that causes the rain weather effect to slowly end after a call to the function 
	// "effect_end_weather_rain" by slowly decreasing the amount of raindrops that exist at once until that
	// number reaches zero. At that point, the struct will free itself from memory.
	isEnding = false;
	
	// Holds all of the currently existing instances of raindrop splashes that currently exist in the world.
	// These splashes are created by raindrops hitting their "target value" on the y-axis, which resets
	// their position to somewhere on the top edge of the screen.
	splashes = ds_list_create();
	
	// 
	rainSound = audio_play_sound_ext(snd_rainfall, 0, 0, 1, true, true);
	audio_sound_gain(rainSound, SOUND_VOLUME, 6500); // Fade sound in over 6.5 seconds of real-world time.
	
	/// @description Code that should be placed into the "Step" event of whatever object is controlling
	/// obj_weather_rain. In short, it will handle the creation of raindrops, as well as the updating of
	/// their vertical positions and the animations for each currently existing raindrop splash. 
	step = function(){
		// 
		var _length = ds_list_size(raindrops);
		if (isEnding && _length == 0 && audio_sound_get_gain(rainSound) == 0){
			audio_stop_sound(rainSound);
			delete WEATHER_RAIN;
			WEATHER_RAIN = noone;
			return;
		}
		
		// The chunk of code responsible for spawning in all of the raindrop instances that are required
		// for the effect to actually look like rain. It will count down the buffer timer's value until it
		// reaches zero, where another rain struct will be added to the list of total raindrops.
		if (_length < totalRaindrops && !isEnding){
			spawnBuffer -= DELTA_TIME;
			if (spawnBuffer <= 0){
				spawnBuffer = random_range(MIN_SPAWN_BUFFER, MAX_SPAWN_BUFFER);
				var _startY = CAMERA.y - RAIN_Y_START_OFFSET;
				ds_list_add(raindrops, {
					x :			CAMERA.x + irandom_range(2, CAM_WIDTH - 2),
					y :			_startY, // All raindrops will initially spawn at the same Y offset.
					fractionY : 0, // Prevents fractional vertical position values.
					targetY :	_startY + irandom_range(32, CAM_HEIGHT + 64),
					vspd :		4 + random(1.25), // Makes each raindrop have a slightly offset vertical velocity.
					alpha :		random_range(0.45, 1),
				});
			}
		}
		
		// Store some important camera values (as well as the currently calculated value for delta time)
		// so that there aren't constant jumps between the camera's scope and the current raindrop's scope,
		// which will slow down the overall codes execution when there are 100 or so raindrop instances.
		var _cameraX, _cameraY, _cameraWidth, _cameraHeight, _deltaTime;
		_cameraX = CAMERA.x;
		_cameraY = CAMERA.y;
		_cameraWidth = CAM_WIDTH;
		_cameraHeight = CAM_HEIGHT;
		_deltaTime = DELTA_TIME;
		
		// Loop through all of the currently existing raindrop instances, updating their positions; each x
		// position being updated such that it wraps along the screen as the camera moves horizontally, and
		// each y position being updated if the raindrop's target y position has been reached. (That position
		// is where the raindrop's splash effect will be spawned)
		var _raindrops, _splashes, _isEnding, _x, _y, _alpha;
		_raindrops = raindrops;	// Store references to some of the main struct's variables for faster reference in the loop.
		_splashes = splashes;
		_isEnding = isEnding;
		for (var i = 0; i < _length; i++){
			with(raindrops[| i]){
				// Wraps the raindrops that end up outside of the current horizontal bounds of the camera's
				// current view to the right and left sides of the screen from the other, respectively.
				if (x < _cameraX)						{x += _cameraWidth;}
				else if (x > _cameraX + _cameraWidth)	{x -= _cameraWidth;}
				
				// Moving the raindrops vertically through whole values to prevent any sub-pixel movement,
				// which could cause issues while rendering the raindrop given the game's low resolution.
				// The distance from the bottom of the screen that the raindrop's target is will affect
				// how fast it moves towards said target position to align with the 2.5D perspective 
				// that the game's art is going for.
				var _targetToCamRatio = (targetY - _cameraY) / _cameraHeight;
				fractionY += ((vspd * _targetToCamRatio) + 2) * _deltaTime;
				if (fractionY >= 1){
					y += fractionY;
					fractionY -= fractionY;
					
					// If the target position has been hit by the raindrop OR the raindrop goes well below
					// the bottom bounds of the game's current camera view. When this happens, the raindrop
					// splash will be created at the position of the raindrop.
					if (y >= targetY){
						// Pass over the raindrop's coordinates in the room, and the alpha value for the
						// raindrop so the splash will match the characteristics of the raindrop it came
						// from. Then, create the splash struct with those stored values IF the raindrop
						// is within a visible region around the view. Otherwise, no raindrop is created.
						if (x > _cameraX - 16 && y > _cameraY - 16 && x < _cameraX + _cameraWidth + 16 && y < _cameraY + _cameraHeight + 16){
							_x = x;
							_y = y;
							_alpha = alpha;
							ds_list_add(_splashes, {
								x :				_x,
								y :				_y,
								startAlpha :	_alpha,
								curAlpha :		_alpha,
								imgIndex :		0,
							});
						}
						
						// When the weather effect is toggled to end, there will be a 33% chance of the 
						// raindrop will despawn instead of being reset to the top of the screen. The only
						// exception to this is when there are less than 10 raindrops remaining on screen;
						// when that happens the raindrop will always despawn no matter what.
						if (_isEnding && (_length <= 10 || irandom_range(0, 99) <= 33)){
							delete _raindrops[| i];
							ds_list_delete(_raindrops, i);
							_length--;
							i--;
							continue; // Skips over the position/target resetting code
						}
						
						// In order to make the rain seem random and nor repetitive, the horiztonal position,
						// and target y position will be randomly set each time the raindrop hits its target
						// or goes too far below the screen. The y position is always set to be four pixels
						// above the camera's top view boundary, however.
						x = _cameraX + irandom_range(2, _cameraWidth - 2);
						y = _cameraY - RAIN_Y_START_OFFSET;
						targetY = y + irandom_range(32, _cameraHeight + 64);
					}
				}
			}
		}
		
		// Loop through all of the currently existing raindrop splashes, which is as simple as adding to
		// the value that animates the splash. Once that animation value exceeds the total number of images
		// for the animation, the splash will be deleted. Also, the alpha will be faded out at that speed
		// to make the splash effect smoother.
		_length = ds_list_size(splashes);
		for (var j = 0; j < _length; j++){
			with(splashes[| j]){
				curAlpha -= (startAlpha / 20) * _deltaTime;
				imgIndex += 0.6 * _deltaTime;
				if (imgIndex >= 3){
					delete _splashes[| j];
					ds_list_delete(_splashes, j);
					_length--;
					j--;
				}
			}
		}
	}
	
	/// @description Code that should be placed into the "Draw End" event of whatever object is controlling
	/// obj_weather_rain. In short, it will render all existing instances of raindrops and raindrop splash
	/// effects to the screen.
	draw_end = function(){
		// The splash effects are rendered first in their order of creation within the list. If they were
		// rendered after the raindrops, the splashes would appear above drops that could potentially pass
		// through the region that a splash occupies, which isn't correct.
		var _length = ds_list_size(splashes);
		for (var j = 0; j < _length; j++){
			with(splashes[| j]) {draw_sprite_ext(spr_raindrop_land, imgIndex, x, y, 1, 1, 0, c_white, curAlpha);}
		}
		
		// After all the raindrop splashes have been drawn to the screen, the raindrops themselves will be
		// drawn at each of their repesctive positions and transparency values. The distance that the drop's
		// target position is relative to the camera's bottom edge will determine how it is scaled vertically
		// when drawn on screen; adhering to the 2.5D perspective of the game.
		_length = ds_list_size(raindrops);
		var _cameraY, _cameraHeight, _targetToCamRatio, _raindropBlendColor;
		_cameraY = CAMERA.y;
		_cameraHeight = CAM_HEIGHT;
		for (var i = 0; i < _length; i++){
			with(raindrops[| i]){
				_targetToCamRatio = (targetY - _cameraY) / _cameraHeight;
				_raindropBlendColor = min(190 + (_targetToCamRatio * 65), 255);
				draw_sprite_ext(spr_raindrop, 0, x, y, 1, 0.5 + (_targetToCamRatio * 1.5), 0, make_color_rgb(_raindropBlendColor, _raindropBlendColor, _raindropBlendColor), alpha);
			}
		}
	}
	
	/// @description Code that should be placed into the "Cleanup" event of whatever object is controlling
	/// obj_weather_rain. In short, ir removes any data from memory that isn't automatically cleaned up
	/// by Game Maker's default garbage collection code for objects, arrays, and things like that.
	cleanup = function(){
		// Delete any raindrop instances that may still currently exist when this weather effect has been
		// destroyed by the object that manages it. After that, the list that held all thos instances is
		// destroyed to prevents any further memory leaks.
		var _length = ds_list_size(raindrops);
		for (var i = 0; i < _length; i++) {delete raindrops[| i];}
		ds_list_destroy(raindrops);
		
		// Much like above, instances that may still exist upon this struct's deletion will be cleaned up
		// to prevent memory leaks. However, this one will handle cleaning up the list that manages the
		// existing instances of raindrop splashes.
		_length = ds_list_size(splashes);
		for (var j = 0; j < _length; j++) {delete splashes[| j];}
		ds_list_destroy(splashes);
	}
}

#endregion

#region Global functions related to obj_weather_rain

/// @description 
function effect_create_weather_rain(){
	if (WEATHER_RAIN == noone) {WEATHER_RAIN = new obj_weather_rain();}
}

/// @description
function effect_end_weather_rain(){
	with(WEATHER_RAIN){
		audio_sound_gain(rainSound, 0, 2500);
		isEnding = true;
	}
}

#endregion