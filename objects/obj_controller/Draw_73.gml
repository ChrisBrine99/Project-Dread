// Render all of the elements that take place at the end of the game's general rendering of objects, tiles, and
// decorations onto the application surface. This includes the rain and fog weather effects (If either or both
// of them are currently active) and all of the world-space post-processing effects.
with(WEATHER_RAIN)		{draw_end();}
with(WEATHER_FOG)		{draw_end();}
with(EFFECT_HANDLER)	{draw_end();}