// When the next audio group is loaded, this event will be called and the music handler will begin to execute
// its code that starts up the new music track. If an audio group wasn't loaded then nothing occurs.
with(MUSIC_HANDLER) {async_audio(async_load);}