// Once the warp has been triggered, the screen fade effect will be created, and at the end of each frame the
// door instance will check if its opening sound has stopped playing. After that point, the room switch will
// occur only if the fade has reached its full opacity as well. Then, the room warp will occur and the duration
// of the full opacity will be the length of the door's set closing sound's length.
if (isWarping && !audio_is_playing(openingSound)){
	with(SCREEN_FADE){
		if (alpha == 1 && alphaTarget == 1){
			var _sound = audio_play_sound_ext(other.closingSound, 0, SOUND_VOLUME, 1, false);
			fadeDuration = (audio_sound_length(_sound) * 60) * 0.8; // Multiply by 60 to match number of "frames" per second
			object_perform_room_warp(other.id);
		}
	}
}
