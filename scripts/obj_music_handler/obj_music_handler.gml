/// @description Contains all the code and logic that handles the seamless and looping playback of a room or 
/// area's given background track.

#region	Initializing any macros that are useful/related to obj_music_handler

// A constant that replaces the default value for the music handler to know when no song is set to be played
// at the moment. Allows easier understanding of the code compared to random negative ones strewn about.
#macro	NO_SONG					   -1

//
#macro	SONG_FADE_DURATION			2500
#macro	LOOP_CROSSFADE_LENGTH		100

// 
#macro	SONG_FILEPATH				"Filepath"
#macro	LOOP_POSITION				"Loop Time"
#macro	LOOP_LENGTH					"Loop Length"

#endregion

#region Initializing enumerators that are useful/related to obj_music_handler

/// @description
enum Music{
	Test,
}

#endregion

#region Initializing any globals that are useful/related to obj_music_handler

// 
global.musicData = encrypted_json_load("music_data.json", "");

#endregion

#region The main object code for obj_music_handler

function obj_music_handler() constructor{
	// Much like Game Maker's own object_index variable, this will store the unique ID value provided to this
	// object by Game Maker during runtime; in order to easily use it within a singleton system.
	object_index = obj_music_handler;
	
	// 
	curSong = {
		song :			NO_SONG,
		songID :		noone,
		streamID :		noone,
		loopPosition :	0,
		loopLength :	0,
		loopBuffer :	NO_SONG,
	};
	
	// 
	queuedSong = {
		song :			NO_SONG,
		songID :		noone,
		streamID :		noone,
		loopPosition :	0,
		loopLength :	0,
	};
	
	/// @description 
	end_step = function(){
		// 
		var _queuedSong = queuedSong;
		with(curSong){
			// 
			if (_queuedSong.songID != songID && audio_sound_get_gain(song) == 0){
				if (song != NO_SONG){
					audio_stop_sound(song);
					audio_destroy_stream(streamID);
				}
				
				// 
				var _songData = [noone, noone, 0, 0];
				with(_queuedSong){
					_songData[0] = songID;
					_songData[1] = streamID;
					_songData[2] = loopPosition;
					_songData[3] = loopLength;
					songID = noone;
					streamID = noone;
					loopPosition = 0;
					loopLength = 0;
				}
				songID = _songData[0];
				streamID = _songData[1];
				loopPosition = _songData[2];
				loopLength = _songData[3];
				
				// 
				song = audio_play_sound_ext(streamID, 1000, 0, 1);
				audio_sound_gain(song, MUSIC_VOLUME, SONG_FADE_DURATION);
			}
			
			// 
			if (song != NO_SONG){
				var _position = audio_sound_get_track_position(song);
				if (_position >= loopPosition){
					// 
					loopBuffer = song;
					audio_sound_gain(loopBuffer, 0, LOOP_CROSSFADE_LENGTH + 25);
				
					// 
					song = audio_play_sound_ext(streamID, 1000, 0, 1);
					audio_sound_gain(song, MUSIC_VOLUME, LOOP_CROSSFADE_LENGTH);
					audio_sound_set_track_position(song, _position - loopLength);
				}
			
				// 
				if (loopBuffer != NO_SONG && audio_sound_get_gain(loopBuffer) == 0){
					audio_stop_sound(loopBuffer);
					loopBuffer = NO_SONG;
				}
			}
		}
	}
	
	/// @description 
	cleanup = function(){
		// 
		ds_map_destroy(global.musicData);
		
		// 
		with(curSong){
			if (audio_is_playing(song)) {audio_stop_sound(song);}
			if (audio_is_playing(loopBuffer)) {audio_stop_sound(loopBuffer);}
			if (streamID != noone) {audio_destroy_stream(streamID);}
		}
		delete curSong;
		
		// 
		with(queuedSong){
			if (audio_is_playing(song)) {audio_stop_sound(song);}
			if (streamID != noone) {audio_destroy_stream(streamID);}
		}
		delete queuedSong;
	}
	
	/// @description 
	/// @param songID
	load_music_file = function(_songID){
		// 
		var _musicData = global.musicData[? string(_songID)];
		if (is_undefined(_musicData)) {return;}
		
		// 
		with(curSong){
			if (songID == _songID){
				if (audio_sound_get_gain(song) != MUSIC_VOLUME) {audio_sound_gain(song, MUSIC_VOLUME, SONG_FADE_DURATION);}
				return;
			}
			if (audio_is_playing(song)) {audio_sound_gain(song, 0, SONG_FADE_DURATION);}
		}
		
		// 
		with(queuedSong){
			if (songID == _songID) {return;}
			if (streamID != noone) {audio_destroy_stream(streamID);}
			songID = _songID;
			streamID = audio_create_stream("music/" + _musicData[? SONG_FILEPATH]);
			loopPosition = _musicData[? LOOP_POSITION];
			loopLength = _musicData[? LOOP_LENGTH];
		}
	}
}

#endregion

#region Global functions related to obj_music_handler

/// @description 
/// @param songID
function music_set_next_song(_songID){
	with(MUSIC_HANDLER) {load_music_file(_songID);}
}

#endregion