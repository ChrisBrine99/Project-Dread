/// @description Insert summary of this file here.

#region Item interaction functions

/// @description 
function interact_item_collect_default(){
	show_debug_message("INTERACTION HAS OCCURRED!");
}

/// @description 
function interact_item_collect_pouch(){
	// 
	if (global.curItemInvSize < global.gameplay.maximumItemInvSize) {global.curItemInvSize += 2;}
	
	// 
	textbox_add_text_data("You've found an Item Pouch! The amount of space to carry items has been permanently increased by two slots!");
	textbox_add_color_data(HEX_GREEN, RGB_DARK_GREEN, 17, 27);
	textbox_add_color_data(HEX_LIGHT_YELLOW, RGB_DARK_YELLOW, 98, 100);
	textbox_begin_execution();
	
	// 
	instance_destroy(parentID);
}

#endregion
