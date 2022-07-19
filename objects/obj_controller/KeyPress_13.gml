//instance_create_menu_struct(obj_main_menu);

//game_end();
//textbox_add_text_data("Normal, *" + YELLOW + "*yellow, *" + RED + "*red, *"
//						+ GREEN + "*green, *" + BLUE + "*blue.");
//textbox_begin_execution();

if (WEATHER_RAIN != noone){
	effect_end_weather_rain();
	return;
}

effect_create_weather_rain();