//instance_create_menu_struct(obj_main_menu);

textbox_add_text_data("This is a test to see if the textbox system works! Hopefully this all does work and I don't have to spend 3 hours bug testing... And this here will hopefully add one more line to the textbox to see how it looks when filled.");
textbox_add_color_data(HEX_LIGHT_RED, RGB_DARK_RED, 11, 15);
textbox_add_color_data(HEX_LIGHT_BLUE, RGB_DARK_BLUE, 30, 37);

textbox_add_text_data("This should be the second textbox and contain different indexes for its color data! On top of that, the background should be a different color as well!", Actor.Test01, 0, 1, 1);
textbox_add_color_data(HEX_LIGHT_YELLOW, RGB_DARK_YELLOW, 20, 34);
textbox_add_color_data(HEX_LIGHT_BLUE, RGB_DARK_BLUE, 73, 82);
textbox_add_color_data(HEX_LIGHT_GREEN, RGB_DARK_GREEN, 127, 142);
textbox_add_decision_data("Ask for cock torture", 3);
textbox_add_decision_data("Ask for ball torture", 2);

textbox_add_text_data("FUCK!!", Actor.Test01, 5, 4, 4);
textbox_add_shake_effect(3, 60);
textbox_set_to_close();

textbox_add_text_data("This is what will be shown if you chose the first option! Cool!!!", Actor.Test01, 1);
textbox_add_color_data(HEX_LIGHT_YELLOW, RGB_DARK_YELLOW, 45, 50);

textbox_begin_execution();
