/// @description Contains all the code and logic that handles the seamless and looping playback of a room or 
/// area's given background track.

#region	Initializing any macros that are useful/related to obj_music_handler

// A constant that replaces the default value for the music handler to know when no song is set to be played
// at the moment. Allows easier understanding of the code compared to random negative ones strewn about.
#macro	NO_SONG					   -1

// Two constrant values for different fading durations for the currently playing song's volume. The first
// is how long it takes for the previous song to fade out and the new song to fade in, while the second
// value represents how long the crossfading occurs for to minimize audio popping.
#macro	SONG_FADE_DURATION			2500
#macro	LOOP_CROSSFADE_LENGTH		100

// Macros for the key names that are used to store data within the music loop data map. The names themselves
// explain what the data contains at that keys represents to the music handler.
#macro	SONG_FILEPATH				"Filepath"
#macro	LOOP_POSITION				"Loop Time"
#macro	LOOP_LENGTH					"Loop Length"

#endregion

#region Initializing enumerators that are useful/related to obj_music_handler

/// @description An enumerator that is used to give names to the ID values that are used to differentiate 
/// songs within the code. Each index should have looping data assigned to it within the music_data JSON
/// file; otherwise it won't be playable.
enum Music{
	Test,
	Test2,
}

#endregion

#region Initializing any globals that are useful/related to obj_music_handler

// Loads in and stores the music looping data within this global variable, which is then referenced to get
// the timings for a given song whenever it is set to be played by the music handler. An undefined ID here
// results in the song at that given ID to be unplayable.
global.musicData = encrypted_json_load("music_data.json", "");

#endregion

#region The main object code for obj_music_handler

function obj_music_handler() constructor{
	// Much like Game Maker's own id variable for objects, this will store the unique ID value given to this
	// singleton, which is a value that is found in the "obj_controller_data" script with all the other
	// macros and functions for handling singleton objects.
	id = MUSIC_HANDLER_ID;
	
	// A struct that contains all the information about the background music that is currently playing. It
	// stores the audio index given to the song when it's played by the built-in function "audio_play_sound".
	// On top of that, it also stores the unique ID of the song that's used for getting loop timings, the
	// stream ID given to the music file when it's loaded into memory, and the information about the loop
	// timings for the song; the loop buffer being there for crossfading during the loop to avoid popping.
	curSong = {
		song :			NO_SONG,
		songID :		-1,
		streamID :		-1,
		loopPosition :	0,
		loopLength :	0,
		loopBuffer :	NO_SONG,
	};
	
	// A struct that contains information about the song that has been selected to play next. It will store
	// that information here until the song stored within the "curSong" struct has finished fading out.
	// After that, the information from here is placed in the other struct; clearing it out of this struct.
	queuedSong = {
		song :			NO_SONG,
		songID :		-1,
		streamID :		-1,
		loopPosition :	0,
		loopLength :	0,
	};
	
	/// @description Code that should be placed into the "End Step" event of whatever object is controlling
	/// obj_music_handler. In short, it is ran every frame; checking if a song switch needs to occur or if
	/// a crossfading loop has to be executed for the currently playing song.
	end_step = function(){
		// Store the "queuedSong" strust in a local variable so it can be accessed from inside the scope of
		// the "curSong" struct without much of a hassle. Then, jump into scope of that latter struct in
		// order to handle song switching/looping.
		var _queuedSong = queuedSong;
		with(curSong){
			// Within this if check contains the logic that handles switching songs; transferring the data
			// from the queue struct to the main struct. However, this is only ever done if the IDs in both
			// structs don't match and the current song that's playing has had its volume reduced to zero.
			if (_queuedSong.songID != songID && audio_sound_get_gain(song) == 0){
				if (song != NO_SONG){
					audio_stop_sound(song);
					audio_destroy_stream(streamID);
				}
				
				// Copy over the data from the queue struct and place it into a temporary array that will
				// then be used to place that data into the main song struct's respective variables.
				var _songData = [-1, -1, 0, 0];
				with(_queuedSong){
					_songData[0] = songID;
					_songData[1] = streamID;
					_songData[2] = loopPosition;
					_songData[3] = loopLength;
					songID = -1;
					streamID = -1;
					loopPosition = 0;
					loopLength = 0;
				}
				songID = _songData[0];
				streamID = _songData[1];
				loopPosition = _songData[2];
				loopLength = _songData[3];
				
				// Finally, begin the fading in of the new background song; storing the audio ID returned
				// through this function by game maker so that only this instance of the sound has its
				// settings altered instead of every instance after this line.
				song = audio_play_sound_ext(streamID, 1000, 0, 1);
				audio_sound_gain(song, MUSIC_VOLUME, SONG_FADE_DURATION);
			}
			
			// This is statement contains the logic that is used to loop the song that is currently playing
			// by chekcing if the position into the current song has exceeded the timer required for looping
			// to actually occur. Then, that current position is subtracted by the loop duration to loop
			// the song seamlessly.
			if (song != NO_SONG){
				var _position = audio_sound_get_track_position(song);
				if (_position >= loopPosition){
					// In order to loop without noticeable popping, I've opted to use a crossfading technique.
					// So, the ID stored in "song" is placed within the loop buffer variable, which is then
					// faded out.
					loopBuffer = song;
					audio_sound_gain(loopBuffer, 0, LOOP_CROSSFADE_LENGTH);
				
					// All the while the loop buffer ID is set to begin fading out, the new loop for the song
					// is created; with its volume faded into audibility.
					song = audio_play_sound_ext(streamID, 1000, 0, 1);
					audio_sound_gain(song, MUSIC_VOLUME, LOOP_CROSSFADE_LENGTH);
					audio_sound_set_track_position(song, _position - loopLength);
				}
			
				// Once the loop buffer's audio has reached a volume of zero, the sound will stop playing and
				// the ID that was once stored within the variable is cleared since it doesn't reference audio
				// that is playing any longer.
				if (loopBuffer != NO_SONG && audio_sound_get_gain(loopBuffer) == 0){
					audio_stop_sound(loopBuffer);
					loopBuffer = NO_SONG;
				}
			}
		}
	}
	
	/// @description  Code that should be placed into the "Cleanup" event of whatever object is controlling
	/// obj_music_handler. In short, it just cleans up all the memory that was allocated by this struct to
	/// prevent any memory leaks during runtime.
	cleanup = function(){
		// Since this is the only object that references it; the music looping data that was read from file
		// is removed from memory here. Since it was loaded in from a JSON format, only the outer data
		// structure needs to be called for deletion in order to remove them all.
		ds_map_destroy(global.musicData);
		
		// Delete the struct that contains the data for the currently playing song; making sure to stop
		// that audio from playing and that its audio stream is cleared from memory before destroying the
		// struct itself.
		with(curSong){
			if (audio_is_playing(song)) {audio_stop_sound(song);}
			if (audio_is_playing(loopBuffer)) {audio_stop_sound(loopBuffer);}
			if (streamID != -1) {audio_destroy_stream(streamID);}
		}
		delete curSong;
		
		// The same thing that happens to the current song struct will also occur to the queued song struct;
		// minus any sound stopping since no audio is ever produced by this struct's data. Once the audio
		// stream is removed from memory, the outer struct is cleared from memory as well.
		with(queuedSong){
			if (streamID != -1) {audio_destroy_stream(streamID);}
		}
		delete queuedSong;
	}
	
	/// @description The function that is responsible for loading in an external music file for playback
	/// within the game. If there's no looping information for the audio file that is being loaded given
	/// the provided song's ID, no file will be loaded since it won't be allowed to properly loop.
	/// @param {Real}	songID
	load_music_file = function(_songID){
		// First, check to see if there is loop time data contained at the given ID. If there is, the file
		// can be loaded since it will be able to loop. Otherwise, the file will not be loaded.
		var _musicData = global.musicData[? string(_songID)];
		if (is_undefined(_musicData)) {return;}
		
		// If there was a song that was previously being played by the handler, it will begin fading out 
		// in order to begin playing the song that will be queued up to replace the song. If the ID for the
		// song to play happens to match the song that is currently playing, however, no data will be loaded
		// and the song that is playing will simply resume playing.
		with(curSong){
			if (songID == _songID){
				if (audio_sound_get_gain(song) != MUSIC_VOLUME) {audio_sound_gain(song, MUSIC_VOLUME, SONG_FADE_DURATION);}
				return;
			}
			if (audio_is_playing(song)) {audio_sound_gain(song, 0, SONG_FADE_DURATION);}
		}
		
		// Load in the audio file and store all of its information into the queued song's struct for use
		// when the currently playing song has finished fading out and thus, the song stored here can play.
		with(queuedSong){
			if (songID == _songID) {return;}
			if (streamID != -1) {audio_destroy_stream(streamID);}
			songID = _songID;
			streamID = audio_create_stream("music/" + _musicData[? SONG_FILEPATH]);
			loopPosition = _musicData[? LOOP_POSITION];
			loopLength = _musicData[? LOOP_LENGTH];
		}
	}
}

#endregion

#region Global functions related to obj_music_handler

/// @description A global function to call a song change from within the music handler. It does this by
/// simply calling its "load_music_file" function using the ID supplied to it by this function call.
/// @param {Real}	songID
function music_set_next_song(_songID){
	with(MUSIC_HANDLER) {load_music_file(_songID);}
}

#endregion