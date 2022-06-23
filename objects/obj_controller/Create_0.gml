#region Variable Initialization

// The variables that handle the animation of the door indication arrows that are rendered for each door
// that isn't broken, is within 30 units of the player, and is able to be interacted with the player. It's
// a simple bobbing animation that fades in and out of visibility.
doorIndicatorOffset = 0;
doorIndicatorAlpha = 1;
doorIndicatorAlphaTarget = 0;

// The variables that handle displaying the current interaction prompt. This prompt gives information on
// what interactable object the player is currently looking at, and what will happen when they press the
// "interact" input while they remain looking at said object. The first value is the alpha level of that
// prompt and its paired control input, and the second value stores the message explaining what interacting
// does within the game.
interactPromptAlpha = 0;
interactPrompt = "";

#endregion

#region Function Initialization

/// @description A function that is responsible for rendering a HUD element onto the screen that informs
/// the player on nearby doors that can be interacted with in the world. (Broken doors don't have arrows
/// shown to let the player know they can't open the doorway) It will draw an arrow in one of four 
/// directions depending on where the door is facing in the room relative to the camera's perspective. It 
/// slowly fades in and out of visibility until the player moves too far from said door, which will stop 
/// the arrow from continuing to render.
/// @param playerX
/// @param playerY
/// @param cameraX
/// @param cameraY
draw_door_indicator = function(_playerX, _playerY, _cameraX, _cameraY){
	// First, all the doors need to have their distances from the player's current position calculated to
	// see which is the actual door that is closest to them. An arrow will be drawn for each door that is
	// within 30 units of the player; meaning multiple arrows in multiple directions can be rendered at
	// once, but they do share a universal alpha level and positional offset that makes them all fade in 
	// and out of visibility while also moving back and forth relative to their direction at the exact same
	// speed, respectively.
	var _indicatorOffset, _indicatorAlpha, _foundDoor;
	_indicatorOffset = floor(doorIndicatorOffset);
	_indicatorAlpha = doorIndicatorAlpha;
	_foundDoor = false;
	with(obj_warp_door){
		// Check if the door it broken, it can't be interacted with for some reason, or it doesn't meet
		// the distance requirement; causing the door to be skipped over and no arrow to ever be drawn
		// for it.
		if (requiredKeys == DOOR_BROKEN || !interactComponent.canInteract || point_distance(x + 8, y + 8, _playerX, _playerY) > 30) {continue;}
		
		// The arrow will be drawn to match the orientation of the door within the game world; north being
		// the only door that is actually visible to the camera. East, west, and south are only shown by
		// their arrow indicators because of the perspective of the game.
		switch(doorDirection){
			case DOOR_DIR_NORTH:	draw_sprite_ext(spr_door_indicator, 0, x + 8 - _cameraX, y - 14 - _cameraY - _indicatorOffset, 1, 1, 0, c_white, _indicatorAlpha);	break;
			case DOOR_DIR_WEST:		draw_sprite_ext(spr_door_indicator, 1, x - 18 - _cameraX - _indicatorOffset, y + 8 - _cameraY, 1, 1, 0, c_white, _indicatorAlpha);	break;
			case DOOR_DIR_SOUTH:	draw_sprite_ext(spr_door_indicator, 2, x + 8 - _cameraX, y + 6 - _cameraY + _indicatorOffset, 1, 1, 0, c_white, _indicatorAlpha);	break;
			case DOOR_DIR_EAST:		draw_sprite_ext(spr_door_indicator, 3, x + 18 - _cameraX + _indicatorOffset, y + 8 - _cameraY, 1, 1, 0, c_white, _indicatorAlpha);	break;
		}
		
		// Let the alpha animation know it should do a constant fading animation until no doors have been
		// found by this with statement loop.
		_foundDoor = true;
		break;
	}
	
	// If no door was found by the above loop, the alpha and offset animation values will be reset so that 
	// they're ready for when the animation is started when another door is nearby the player again.
	if (!_foundDoor){
		doorIndicatorOffset = 0;
		doorIndicatorAlpha = 1;
		doorIndicatorAlphaTarget = 0;
		return; // Ends early to prevent the animation from playing when no arrows are being rendered.
	}
	
	// Update the offset portion of the animation, which will simply count up a value by 0.05 units for
	// every 1/60th of a real-world second until the value surpasses two. At that point, the value is reset
	// back to zero so the arror returns to its initial position.
	doorIndicatorOffset += DELTA_TIME * 0.05;
	if (doorIndicatorOffset >= 2) {doorIndicatorOffset = 0;}

	// Finally, update the alpha animation for the door indicator arrows; fading in and out at a constant
	// rate of 0.025 units every 1/60th of a real-world second on an endless loop.
	doorIndicatorAlpha = value_set_linear(doorIndicatorAlpha, doorIndicatorAlphaTarget, 0.025);
	if (doorIndicatorAlpha == 0 && doorIndicatorAlphaTarget == 0)		{doorIndicatorAlphaTarget = 1;}
	else if (doorIndicatorAlpha == 1 && doorIndicatorAlphaTarget == 1)	{doorIndicatorAlphaTarget = 0;}
}

/// @description 
draw_interact_prompt = function(){
	// 
	var _interactPromptAlphaTarget = 0;
	with(PLAYER.interactableID){
		_interactPromptAlphaTarget = 1;
		other.indicatorPrompt = interactPrompt;
	}
	
	// 
	interactPromptAlpha = value_set_linear(interactPromptAlpha, _interactPromptAlphaTarget, 0.1);
	
	// 
	if (interactPromptAlpha > 0){
		shader_set_outline(RGB_GRAY, font_gui_small);
		
		// 
		var _inputIconData = noone;
		if (global.gamepad.deviceID != -1 && global.gamepad.isActive) {_inputIconData = global.keyboardIcons[? global.settings.gpadInteract];}
		else {_inputIconData = global.keyboardIcons[? global.settings.keyInteract];}
		
		// 
		var _stringWidth, _interactPromptAlpha, _iconWidth, _interactPromptOffset;
		_stringWidth = string_width(indicatorPrompt);
		_interactPromptAlpha = interactPromptAlpha;
		with(_inputIconData){
			_iconWidth = sprite_get_width(iconSprite);
			_interactPromptOffset = CAM_HALF_WIDTH - round((_iconWidth + _stringWidth + 2) / 2);
			draw_sprite_ext(iconSprite, imgIndex, _interactPromptOffset + _stringWidth + 2, CAM_HEIGHT - 41, 1, 1, 0, c_white, _interactPromptAlpha);
		}
		
		// 
		draw_text_outline(_interactPromptOffset, CAM_HEIGHT - 40, indicatorPrompt, HEX_WHITE, RGB_GRAY, interactPromptAlpha);
		
		shader_reset();
	}
}

#endregion
