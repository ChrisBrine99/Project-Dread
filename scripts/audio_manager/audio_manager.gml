/// @description 

#region Initializing any macros that are useful/related to the audio listener

// A macro to simplify the look of the code whenever the audio manager struct needs to be referenced. The
// second macro does the same thing, but for referencing the object that is currently linked to the audio
// manager to easily know what position the audio is currently being heard from within the room.
#macro	AUDIO_MANAGER				global.audioManager
#macro	AUDIO_LINKED_OBJECT			global.audioManager.linkedObject

// 
#macro	SOUND_LIMIT					1024

#endregion

#region Initializing enumerators that are useful/related to the audio listener
#endregion

#region Initializing any globals that are useful/related to the audio listener

//
global.soundData = ds_map_create();

#endregion

#region The main struct code for the audio listener

global.audioManager = {
	// 
	linkedObject : noone,
	
	// 
	activeSounds : ds_list_create(),
	
	/// @description 
	end_step : function(){
		// 
		with(linkedObject) {audio_listener_position(x, y, 0);}
		
		// 
		var _sound, _pitch;
		var _deltaTime = DELTA_TIME;
		var _length = ds_list_size(activeSounds);
		for (var i = 0; i < _length; i++){
			_sound = activeSounds[| i];
			with(_sound){
				// 
				if (pitchVelocity != 0){
					_pitch = audio_sound_get_pitch(ID);
					_pitch = value_set_linear(_pitch, pitchTarget, pitchVelocity);
					audio_sound_pitch(ID, _pitch);
				}
				
				// 
				if (echoCount > 0){
					echoTimer -= _deltaTime;
					if (echoTimer <= 0){
						audio_play_sound_ext(sound, echoGain, audio_sound_get_pitch(ID), priority, false);
						audio_sound_set_pitch_target(pitchTarget, pitchVelocity);
						echoGain *= echoDecayFactor;
						echoTimer = echoSpacing;
						echoCount--;
						_length++;
					}
					continue; // Allows the original sound to handle all the required echos even if it is no longer audible.
				}
				
				// 
				if (!audio_is_playing(ID) || audio_sound_get_gain(ID) == 0){
					ds_list_delete(other.activeSounds, i);
					audio_free_buffer_sound(ID);
					audio_stop_sound(ID);
					_length--;
					i--;
				}
			}
		}
	},
	
	/// @description 
	cleanup : function(){
		// 
		var _key = ds_map_find_first(global.soundData);
		while(!is_undefined(_key)){
			with(global.soundData[? _key]){
				buffer_delete(bufferID);
			}
			_key = ds_map_find_next(global.soundData, _key);
		}
		ds_map_destroy(global.soundData);
		
		// 
		var _length = ds_list_size(activeSounds);
		for (var i = 0; i < _length; i++) {delete activeSounds[| i];}
		ds_list_destroy(activeSounds);
	},
}

// 
audio_falloff_set_model(audio_falloff_linear_distance);
audio_listener_orientation(0, 0, 1, 0, -1, 0);

#endregion

#region Global functions related to the audio listener

/// @description Assigns a new object/struct to be linked with the audio manager. This linked instance's control
/// over the audio listener cannot be changed unless the object in control calls the "audio_remove_linked_object"
/// function. Otherwise, the linkedObject variable will remain unchanged.
/// @param {Id.Instance OR Struct}	objectID
function audio_set_linked_object(_objectID){
	var _id = id;
	with(AUDIO_MANAGER){
		if (_id != linkedObject || (linkedObject != noone && instance_exists(linkedObject))) {return;}
		linkedObject = _objectID;
	}
}

/// @description Removes the link between the previous object/struct that was made out to be the audio listener.
/// Note that this can only be done if the object in control of the audio listener calls this function. If not, 
/// the function will not perform any changes to the linkedObject variable's value.
/// @param {Id.Instance OR Struct} nextObjectID
function audio_remove_linked_object(_nextObjectID = noone){
	var _id = id;
	with(AUDIO_MANAGER){
		if (_id != linkedObject) {return;}
		linkedObject = _nextObjectID;
	}
}

/// @description 
/// @param {String}				filepath		Path of the file within the "Included Files" section.
/// @param {Any}				key				The value to store this sound data at in the map.
/// @param {Real}				sampleRate		Sample rate of the sound that is being loaded.
/// @param {Constant.AudioType}	audioChannel	Determines how the playback of the sound will be handled (Ex. Mono, Stereo, etc).
function audio_load_sound_wav(_filepath, _key, _sampleRate = 32000, _audioChannel = audio_mono){
	// 
	if (!is_undefined(global.soundData[? _key])) {return;}
	
	// 
	var _file = buffer_load(_filepath + ".wav");
	if (_file == -1){
		show_debug_message("Invalid Filepath -- Buffer could not be created!");
		return;
	}
	
	// 
	var _filesize, _buffer;
	_filesize = buffer_get_size(_file);
	_buffer = buffer_create(_filesize, buffer_fixed, 1);
	buffer_copy(_file, 0, _filesize, _buffer, 0);
	buffer_delete(_file);
	
	// 
	ds_map_add(global.soundData, _key, {
		audioBuffer :	audio_create_buffer_sound(_buffer, buffer_s16, _sampleRate, 0, _filesize, _audioChannel),
		bufferID :		_buffer,
		sampleRate :	_sampleRate,
		size :			_filesize,
	});
}

/// @description An extension of the base "audio_play_sound" function that comes built into GML. On top of
/// playing the sound, it will also store that sound and its information so it can be altered during playback
/// to add effects like pitch-shifting or echoes.
/// @param {Asset.GMSound}	sound		The sound file to play.
/// @param {Real}			volume		The "gain" of the sound (0 = inaudible, 1 = sound's standard volume).
/// @param {Real}			pitch		The pitch multiplier (Default is a value of 1).
/// @param {Real}			priority	The channel priority of the sound when compared to others (Lowest is highest priority).
/// @param {Bool}			loopSound	Flag that determines if the sound will play once or repeat indefinitely.
function audio_play_sound_ext(_sound, _volume, _pitch = 1, _priority = 0, _loopSound = false){
	with(AUDIO_MANAGER){
		if (ds_list_size(activeSounds) >= SOUND_LIMIT) {return;}
		
		// Call the standard function that this one extends; storing the ID it returns into a variable that
		// is then passed into the sound struct found below. This struct will be stored for the duration of
		// this sound's playback (Or until its echo count reaches zero if that effect has been applied) and
		// then be deleted after that. It simply stores information about the sound and any effects applied
		// to it.
		var _soundID = audio_play_sound(_sound, _priority, _loopSound, _volume, 0, _pitch);
		ds_list_insert(activeSounds, 0, {
			// These variables are required in order to prevent the game from crashing, but they go unused
			// when a sound is played using this function. This means they will be ignored when checking
			// for audible noises by any enemy AI.
			x :					0,
			y :					0,
			audibleRadius :		0,
			
			// Each stores a piece of information that was used to determine how the sound is played back
			// to the user in the game. The ID (the instance for this specific playback of the sound) is
			// stored so it can be referenced whenever it needs to be altered (Ex. Optional effects, clean
			// up, etc.).
			ID :				_soundID,
			sound :				_sound,
			priority :			_priority,
			isLooping :			_loopSound,
			
			// Variables for the optional echo effect that can be applied. The count determines how many
			// times the sound will be repeated, the spacing determines how many frames there will be
			// between each echo, and the decay factor will cause each subsequent echo to be that percent
			// quieter than the previous instance of this sound.
			echoCount :			0,
			echoSpacing :		0,
			echoDecayFactor :	0,
			
			// A timer that will sound down form whatever value to "echoSpacing" variable is set as to 0
			// in order to accurately track the time between echos. The second variable will store the
			// volume for the next echo after the decay factor is multiplied with the previous volume.
			echoTimer :			0,
			echoGain :			0,
			
			// Variables for the optional pitch shifting effect. The target will store what the pitch
			// multiplier needs to be, and the velocity will be the speed that the pitch approaches that
			// target value every 1/60th of a second.
			pitchTarget :		0,
			pitchVelocity :		0,
		});
		return _soundID;
	}
}

/// @description An extension of the base "audio_play_sound_at" function that comes built into GML. On top of
/// playing the sound, it will also store that sound and its information so it can be altered during playback
/// to add effects like pitch-shifting or echoes. This function will create a positional sound that can only
/// be heard within a certain distance from the coordinates chosen for said sound to play from.
/// @param {Real}			x				Horizontal position within the current room.
/// @param {Real}			y				Vertical position within the current room.
/// @param {Asset.GMSound}	sound			The sound file to play.
/// @param {Real}			volume			The maximum possible volume for the sound when heard by the listener.
/// @param {Real}			falloffRef		Full volume when listener is closer to the sound's origin than this value.
/// @param {Real}			falloffMax		The furthest position that the listener can hear the sound.
/// @param {Real}			falloffFactor	Determines how the sound fades out between the ref and max values.
/// @param {Real}			pitch			The pitch multiplier (Default is a value of 1).
/// @param {Real}			priority		The channel priority of the sound when compared to others (Lowest is highest priority).
/// @param {Bool}			loopSound		Flag that determines if the sound will play once or repeat indefinitely.
function audio_play_sound_at_ext(_x, _y, _sound, _volume, _fallOffRef, _falloffMax, _falloffFactor = 1, _pitch = 1, _priority = 0, _loopSound = false){
	with(AUDIO_MANAGER){
		if (ds_list_size(activeSounds) >= SOUND_LIMIT) {return;}
		
		// Call the standard function that this one extends; storing the ID it returns into a variable that
		// is then passed into the sound struct found below. This struct will be stored for the duration of
		// this sound's playback (Or until its echo count reaches zero if that effect has been applied) and
		// then be deleted after that. It simply stores information about the sound and any effects applied
		// to it.
		var _soundID = audio_play_sound_at(_sound, _x, _y, 0, _priority, _loopSound, _volume, 0, _pitch);
		ds_list_insert(activeSounds, 0, {
			// Stores the position and audible radius of the sound. These are then used to determine if
			// an enemy hears the sounds being produced by the player, which will result in them being
			// altered or not from sound.
			x :					_x,
			y :					_y,
			audibleRadius :		_falloffMax,
			
			// Each stores a piece of information that was used to determine how the sound is played back
			// to the user in the game. The ID (the instance for this specific playback of the sound) is
			// stored so it can be referenced whenever it needs to be altered (Ex. Optional effects, clean
			// up, etc.).
			ID :				_soundID,
			sound :				_sound,
			priority :			_priority,
			isLooping :			_loopSound,
			
			// Variables for the optional echo effect that can be applied. The count determines how many
			// times the sound will be repeated, the spacing determines how many frames there will be
			// between each echo, and the decay factor will cause each subsequent echo to be that percent
			// quieter than the previous instance of this sound.
			echoCount :			0,
			echoSpacing :		0,
			echoDecayFactor :	0,
			
			// A timer that will sound down form whatever value to "echoSpacing" variable is set as to 0
			// in order to accurately track the time between echos. The second variable will store the
			// volume for the next echo after the decay factor is multiplied with the previous volume.
			echoTimer :			0,
			echoGain :			0,
			
			// Variables for the optional pitch shifting effect. The target will store what the pitch
			// multiplier needs to be, and the velocity will be the speed that the pitch approaches that
			// target value every 1/60th of a second.
			pitchTarget :		0,
			pitchVelocity :		0,
		});
		return _soundID;
	}
}

/// @description Calling this function will cause the most recently played sound to have an echo
/// effect applied to it.
/// @param {Real}	count			Total number of echos to be created.
/// @param {Real}	spacing			Time in "frames" (1 = 1/60th seconds) between echos.
/// @param {Real}	decayFactor		Volume ratio between each subsequent echo (Ex. 0.15 would mean each echo is 15% as loud as the previous one).
function audio_sound_apply_echo(_count, _spacing, _decayFactor){
	with(AUDIO_MANAGER.activeSounds[| 0]){ // Always interface with the most recently played sound.
		echoCount = _count;
		echoSpacing = _spacing;
		echoDecayFactor = _decayFactor;
		echoGain = audio_sound_get_gain(ID) * _decayFactor;
		echoTimer = _spacing;
	}
}

/// @description Calling this function will cause the pitch for the newest played sound to change
/// smoothly over time to the target value; the speed being determined by the velocity value.
/// @param {Real}	target		The target for the sound's pitch multipler.
/// @param {Real}	velocity	The speed of the pitch change every 1/60th of a second.
function audio_sound_set_pitch_target(_target, _velocity){
	with(AUDIO_MANAGER.activeSounds[| 0]){ // Always interface with the most recently played sound.
		pitchTarget = _target;
		pitchVelocity = _velocity;
	}
}

/// @description Similar to how "audio_sound_set_pitch_target" alters pitch over time, this function 
/// will cause the most recently played sound's volume to shift over time in the same fashion.
/// @param {Real}		target	The target volume (0 = completely silent).
/// @param {Real}		time	How long the gain transition will take in real-world seconds.
function audio_sound_set_volume_target(_target, _time){
	with(AUDIO_MANAGER.activeSounds[| 0]){ // Always interface with the most recently played sound.
		audio_sound_gain(ID, _target, _time * 60);
	}
}

#endregion