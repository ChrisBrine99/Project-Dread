assign_event_flag("Cutscene01", true);
ds_list_add(sceneInstructions, 
	[CUTSCENE_SET_ENTITY_SPRITE, PLAYER, PLAYER.standSprite, 0],
	[CUTSCENE_WAIT, 15],
	[CUTSCENE_ADD_TEXTBOX_TEXT, "This is a test to see if a cutscene can create a textbox!"],
	[CUTSCENE_SHOW_TEXTBOX],
	[CUTSCENE_WAIT, 15],
	[CUTSCENE_SET_EVENT_FLAG, "Cutscene01", true],
	[CUTSCENE_MOVE_ENTITY_POSITION, PLAYER, 200, 144, 1],
	[CUTSCENE_WAIT, 15]
);