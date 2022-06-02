assign_event_flag("Cutscene01", true);
ds_list_add(sceneInstructions, 
	[CUTSCENE_WAIT, 150],
	[CUTSCENE_ADD_TEXTBOX_TEXT, "This is a test to see if a cutscene can create a textbox!"],
	[CUTSCENE_SHOW_TEXTBOX],
	[CUTSCENE_WAIT, 80],
	[CUTSCENE_SET_ENTITY_POSITION, PLAYER, 200, 144],
	[CUTSCENE_WAIT, 45]
);