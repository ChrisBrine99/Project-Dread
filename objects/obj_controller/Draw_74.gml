// Call the effect handler's draw gui begin event, which will apply any post-processing effects that are
// currently enabled and required relative to the player's currently toggled settings. (Ex. Bloom, Blur, etc.)
// After that, the rain's optional lightning flashes are rendered if they need to be for the current frame.
with(EFFECT_HANDLER)	{draw_gui_begin();}
with(WEATHER_RAIN)		{draw_gui_begin();}