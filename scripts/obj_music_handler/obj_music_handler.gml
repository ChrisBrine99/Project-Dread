/// @description Contains all the code and logic that handles the seamless and looping playback of a room or 
/// area's given background track.

#region	Initializing any macros that are useful/related to obj_music_handler

// A constant that replaces the default value for the music handler to know when no song is set to be played
// at the moment. Allows easier understanding of the code compared to random negative ones strewn about.
#macro	NO_SONG						-1

// Constants that translate the array index numbers into what they store for the array returned by the
// "music_get_song_data" function found further below.
#macro	AUDIO_GROUP					0
#macro	SONG_LENGTH					1
#macro	LOOP_LENGTH					2

// A constant storing the time in milliseconds that it will take for any given music track's volume to fade 
// in or out at the starting or ending of playback, respectively.
#macro	SONG_FADE_TIME				2500

#endregion

#region Initializing enumerators that are useful/related to obj_music_handler
#endregion

#region Initializing any globals that are useful/related to obj_music_handler
#endregion

#region The main object code for obj_music_handler

function obj_music_handler() constructor{
	// Much like Game Maker's own object_index variable, this will store the unique ID value provided to this
	// object by Game Maker during runtime; in order to easily use it within a singleton system.
	object_index = obj_music_handler;
	
	// A struct that contains all the required information for the song that is currently playing within the
	// current room of the game. (Different from ambient environment noise that can play in certain areas)
	curSong = {
		// Stores the resource index for the song that is given by Game Maker, and also the ID value that
		// is given to the sound that is playing that song--required for looping/volume manipulation.
		index :			NO_SONG,
		ID :		   -1,
		
		// Stores the data unique to each song in the game; their unique audio group, (A unique group for each
		// song in order to save on currently used memory) as well as the song's full length (The looping
		// section + whatever intro there is) and loop length--both are required for proper looping to occur.
		audioGroup :   -1,
		songLength :	0,
		loopLength :	0,
	}
	
	// A struct that is nearly identical to the "curSong" struct that is initialized above, but is more of a
	// storage variable for the next song that is queued up to play by the code. As such, it doesn't contain
	// an "ID" variable since no sound instances are interacted with in the struct, and no sounds are played
	// by the struct.
	nextSong = {
		index :			NO_SONG,
		audioGroup :   -1,
		songLength :	0,
		loopLength :	0,
	}
	
	// Two variables that store the ID of sound instance that was playing the previous song, which is copied
	// over from the "ID" variable in the "curSong" struct whenever a new song is being queued up to play.
	// The audio group must also be stored, and that is the purpose of the second variable.
	prevSong = NO_SONG;
	prevAudioGroup = -1;
	
	// A simple flag that lets the music handler know if it's already in the process of queuing up a new song
	// to be played. Prevents overwriting the queue with the "music_set_next_song" function until the next
	// song has been loaded and begins playing.
	isSongChanging = false;
	
	/// @description Code that should be placed into the "End Step" event of whatever object is controlling
	/// obj_music_handler. In short, it is ran every frame and checks to check if the current song that is
	/// playing needs to be looped, (Meaning it has exceeded its stored length value) and to manage the
	/// previously fading out song that needs to be stopped and cleared from memory once its volumes reaches 0.
	end_step = function(){
		// Jump into the "curSong" struct and check the current position of the background music that is
		// playing to see if it needs to be looped back to the beginning of the song's looping section.
		with(curSong){
			var _position = audio_sound_get_track_position(ID);
			if (_position > songLength) {audio_sound_set_track_position(ID, _position - loopLength);}
		}
		
		// Handling the previous song and audio group whenever a new song has been queued up to played;
		// removing the audio group from memory and stopping the song paired with said audio group, and then
		// clearing out both variables from whatever values they were storing afterward.
		if (prevSong != NO_SONG && audio_is_playing(prevSong) && audio_sound_get_gain(prevSong) == 0){
			audio_group_unload(prevAudioGroup);
			audio_stop_sound(prevSong);
			prevAudioGroup = -1;
			prevSong = NO_SONG;
			
			// If the next song that should be played is no song at all, the index and audio group values
			// will be cleared from within the "curSong" struct and the flag for telling the music handler
			// that a song is changing will be set to false.
			if (nextSong.index == NO_SONG){
				with(curSong){
					index = NO_SONG;
					audioGroup = -1;
				}
				isSongChanging = false;
			}
		}
	}
	
	/// @description Code that should be placed into the "Async - Save and Load" event of whatever object is 
	/// controlling obj_music_handler. In short, it is called whenever something is loaded into the program;
	/// in this case it will handle whenever an audio group is loaded into memory by Game Maker--playing the
	/// song found within said audio group.
	async_audio = function(_asyncLoad){
		// Don't perform any of the code within this function if there isn't a song change occurring. Otherwise,
		// the processor will run through code that leads to nothing actually happening whenever the async save/load
		// event is called by Game Maker.
		if (!isSongChanging) {return;}
		isSongChanging = false;
		
		// Store the pointer value to the nextSong struct into a local variable so that it can be easily
		// accessed while inside of the "curSong" struct's scope. Then, check if the async load/save event
		// call was for the audio group that was loaded in for the next queued up song; starting the song
		// if that was the case.
		var _nextSong = nextSong;
		with(curSong){
			if (_asyncLoad[? "group_id"] == _nextSong.audioGroup){
				// Overwrite all the variables within this struct (Aside from the ID variable which is 
				// overwritten later) with the data stored in the "nextSong" struct.
				index =			_nextSong.index;
				audioGroup =	_nextSong.audioGroup;
				songLength =	_nextSong.songLength;
				loopLength =	_nextSong.loopLength;
					
				// Finally, overwrite the sound instance variable to the new sound instance that will be
				// created for the new song index. Then, start the volume at 0 in order to slowly fade it
				// into the required volume over the background music's volume fade time.
				ID = audio_play_sound(index, 100, false);
				audio_sound_gain(ID, 0, 0);
				audio_sound_gain(ID, MUSIC_VOLUME, SONG_FADE_TIME);
			}
		}
	}
	
	/// @description Code that should be placed into the "Cleanup" event of whatever object is controlling
	/// obj_music_handler. In short, it will cleanup any data that needs to be freed from memory that isn't 
	/// collected by Game Maker's built-in garbage collection handler.
	cleanup = function(){
		// Before clearing out the "curSong" struct from memory, make sure that it isn't leaving the audio
		// group it's managing inside of the memory unallocated by unloading it before deleting the struct.
		with(curSong){
			if (audio_group_is_loaded(audioGroup)){
				audio_group_unload(audioGroup);
				audioGroup = -1;
			}
		}
		delete curSong;
		
		// Finally, simply delete the "nextSong" struct from memory since it doesn't manage any memory 
		// allocation like the "curSong" struct does with its audio group.
		delete nextSong;
	}
	
	/// @description A simple function that returns an array of information for the song index that was
	/// provided in the function's argument space. The array contains information for how the song loops
	/// and also its audio group that is loaded whenever it is played.
	/// @param songIndex
	get_song_data = function(_songIndex){
		switch(_songIndex){ // Array indexes are: [Audio Group, Song Length, Loop Length]
			case mus_save_room:			return [ag_save_room, 28.087, 24.677];
			case mus_test:				return [ag_test, 140, 140];
			default:					return [-1, 0, 0];
		}
	}
}

#endregion

#region Global functions related to obj_music_handler

/// @description A simple function that gets and stores the next song's data, and begins the transition for
/// the currently playing song to slowly fade out before this "next" song takes over.
/// @param songIndex
function music_set_next_song(_songIndex){
	with(MUSIC_HANDLER){
		// Don't allow the song to be queued up if another song has already been set to be queued up to play
		// next OR if the song being set to queue up next is the exact same song that is currently playing.
		if (isSongChanging || curSong.index == _songIndex) {return;}
		isSongChanging = true;
		
		// First, store the current song's sound instance value and audio group in order to clear the group
		// from memory when the currently playing song finishes fading out; only when a song is actually
		// being played.
		if (curSong.index != NO_SONG){
			prevSong =			curSong.ID;
			prevAudioGroup =	curSong.audioGroup;
			audio_sound_gain(prevSong, 0, SONG_FADE_TIME);
		}
		
		// Grab the song's data based on its index and then begin loading in the audio group that is paired
		// with the index for the given song provided within the argument space.
		var _songData = get_song_data(_songIndex);
		if (_songData[AUDIO_GROUP] != -1) {audio_group_load(_songData[AUDIO_GROUP]);}
		
		// After beginning the loading of the next audio group, store the next song's data into the 
		// "nextSong" struct for use when the audio group has actually been loaded into memory.
		with(nextSong){
			index =			_songIndex;
			audioGroup =	_songData[AUDIO_GROUP];
			songLength =	_songData[SONG_LENGTH];
			loopLength =	_songData[LOOP_LENGTH];
		}
	}
}

#endregion