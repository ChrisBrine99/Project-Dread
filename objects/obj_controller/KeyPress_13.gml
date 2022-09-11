//instance_create_menu_struct(obj_main_menu);

//game_end();
//textbox_add_text_data("Normal, *" + YELLOW + "*yellow, *" + RED + "*red, *"
//						+ GREEN + "*green, *" + BLUE + "*blue.");
//textbox_begin_execution();

/*textbox_add_text("This is a*" + YELLOW + "* test# to see if the new textbox works. Can you believe that it actually works; even the pauses for*" + GREEN + "* punctuation#?");
textbox_add_sound_effect(snd_player_hurt0);
textbox_add_text("*" + RED + "*Mommy#?! Sorry.*" + YELLOW + "* Mommy#? Sorry.*" + GREEN + "* Mommy#? Sorry.*" + BLUE + "* Mommy#? Sorry.*" + RED + "* Mommy#? Sorry. *" + YELLOW + "*Mommy#? Sorry.*" + GREEN + "* Mommy#? Sorry.*" + BLUE + "* Mommy#? Sorry.*" + RED + "* Mommy#? Sorry. *" + YELLOW + "*Mommy#? Sorry.*" + GREEN + "* Mommy#? Sorry.*" + BLUE + "* Mommy#? Sorry.*" + RED + "* Mommy#? Sorry. *" + YELLOW + "*Mommy#? Sorry.*" + GREEN + "* Mommy#? Sorry.*" + BLUE + "* Mommy#? Sorry.", 1, 1, Actor.Claire, 3);
textbox_add_sound_effect(snd_player_hurt0, 60);
textbox_add_text("More irrelevent text here. Something, something, penis music!?", 1, 1, Actor.Claire, 0);
textbox_add_shake_effect(5, 60);
textbox_activate();*/

control_info_clear_data();

control_info_create_anchor("Test", 5, 100, ALIGNMENT_LEFT);
control_info_add_data("Test", INPUT_RUN, "");
control_info_add_data("Test", INPUT_LOG, "Log");
control_info_initialize_anchor("Test");

control_info_create_anchor("Test2", CAM_WIDTH - 5, 120, ALIGNMENT_RIGHT);
control_info_add_data("Test2", INPUT_ITEMS, "Items");
control_info_add_data("Test2", INPUT_MENU_DOWN, "");
control_info_initialize_anchor("Test2");

control_info_create_anchor("Test3", 200, 5, ALIGNMENT_DOWN);
control_info_add_data("Test3", INPUT_ADVANCE, "Next");
control_info_add_data("Test3", INPUT_SELECT, "Select");
control_info_initialize_anchor("Test3");

control_info_create_anchor("Test4", 200, CAM_HEIGHT - 5, ALIGNMENT_UP);
control_info_add_data("Test4", INPUT_READY_WEAPON, "Ready Weapon");
control_info_add_data("Test4", INPUT_PAUSE, "Pause");
control_info_initialize_anchor("Test4");



//music_set_next_song(Music.Test2);

//if (WEATHER_RAIN != noone || WEATHER_FOG != noone){
//	effect_end_weather_rain(true);
	//effect_end_weather_fog(true);
//	return;
//}

//effect_create_weather_rain(false, true);
//effect_create_weather_fog(true);