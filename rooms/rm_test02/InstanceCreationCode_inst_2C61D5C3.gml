assign_event_flag("Cutscene01", true);
ds_list_add(sceneInstructions, 
	[CUTSCENE_SET_ENTITY_SPRITE, PLAYER, PLAYER.standSprite, 0],
	[CUTSCENE_SET_EVENT_FLAG, "Cutscene01", true],
	[CUTSCENE_WAIT, 15],
	[CUTSCENE_ADD_TEXTBOX_TEXT, "This is a test to see if a cutscene can create a textbox!"],
	[CUTSCENE_ADD_TEXTBOX_TEXT, "Do you want this cutscene to end?"],
	[CUTSCENE_ADD_TEXTBOX_DECISION, "Yes", -1, 8],
	[CUTSCENE_ADD_TEXTBOX_DECISION, "No", -1, 20],
	[CUTSCENE_SHOW_TEXTBOX],
	[CUTSCENE_WAIT, 15],
	[CUTSCENE_ADD_TEXTBOX_TEXT, "No you don't."],
	[CUTSCENE_ADD_TEXTBOX_DECISION, "Yes I Do", 2],
	[CUTSCENE_ADD_TEXTBOX_DECISION, "You're Right, I Don't", -1],
	[CUTSCENE_ADD_TEXTBOX_TEXT, "Yeah, that's what I thought, bitch."],
	[CUTSCENE_SET_TEXTBOX_TO_CLOSE],
	[CUTSCENE_ADD_TEXTBOX_TEXT, "You do know that lying is a sin... right?"],
	[CUTSCENE_ADD_TEXTBOX_TEXT, "Now... Let's try this again..."],
	[CUTSCENE_ADD_TEXTBOX_TEXT, "Do you want this cutscene to end?"],
	[CUTSCENE_ADD_TEXTBOX_DECISION, "Yes", 0],
	[CUTSCENE_ADD_TEXTBOX_DECISION, "No", -1],
	[CUTSCENE_SHOW_TEXTBOX],
	[CUTSCENE_UNLOCK_CAMERA],
	[CUTSCENE_SET_CAMERA_SHAKE, 5, 150, true],
	[CUTSCENE_SET_CAMERA_STATE, STATE_TO_POSITION_SMOOTH, [210, 74, 0.1]],
	[CUTSCENE_WAIT_FOR_CAMERA_POSITION, 210, 74],
	[CUTSCENE_WAIT, 15],
	[CUTSCENE_INVOKE_SCREEN_FADE, HEX_BLACK, 0.075, FADE_PAUSE_FOR_TOGGLE, true],
	[CUTSCENE_SET_ENTITY_POSITION, PLAYER, 370, 144],
	[CUTSCENE_END_SCREEN_FADE, true],
	[CUTSCENE_WAIT, 15]
);