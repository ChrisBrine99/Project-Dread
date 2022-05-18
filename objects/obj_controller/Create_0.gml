#region Variable Initialization

// 
doorIndicatorOffset = 0;
doorIndicatorAlpha = 1;
doorIndicatorAlphaTarget = 0;

#endregion

#region Function Initialization

/// @description 
/// @param playerX
/// @param playerY
/// @param cameraX
/// @param cameraY
draw_door_indicator = function(_playerX, _playerY, _cameraX, _cameraY){
	// 
	var _indicatorOffset, _indicatorAlpha, _foundDoor;
	_indicatorOffset = floor(doorIndicatorOffset);
	_indicatorAlpha = doorIndicatorAlpha;
	_foundDoor = false;
	with(obj_warp_door){
		// 
		if (requiredKeys == DOOR_BROKEN || !interactComponent.canInteract || point_distance(x + 8, y + 8, _playerX, _playerY) > 30) {continue;}
		
		// 
		switch(doorDirection){
			case DOOR_DIR_NORTH:	draw_sprite_ext(spr_door_indicator, 0, x + 8 - _cameraX, y - 14 - _cameraY - _indicatorOffset, 1, 1, 0, c_white, _indicatorAlpha);	break;
			case DOOR_DIR_WEST:		draw_sprite_ext(spr_door_indicator, 1, x - 18 - _cameraX - _indicatorOffset, y + 8 - _cameraY, 1, 1, 0, c_white, _indicatorAlpha);	break;
			case DOOR_DIR_SOUTH:	draw_sprite_ext(spr_door_indicator, 2, x + 8 - _cameraX, y + 6 - _cameraY + _indicatorOffset, 1, 1, 0, c_white, _indicatorAlpha);	break;
			case DOOR_DIR_EAST:		draw_sprite_ext(spr_door_indicator, 3, x + 18 - _cameraX + _indicatorOffset, y + 8 - _cameraY, 1, 1, 0, c_white, _indicatorAlpha);	break;
		}
		
		// 
		_foundDoor = true;
	}
	
	// 
	if (!_foundDoor){
		doorIndicatorOffset = 0;
		doorIndicatorAlpha = 1;
		doorIndicatorAlphaTarget = 0;
		return; // 
	}
	
	// 
	doorIndicatorOffset += global.deltaTime * 0.05;
	if (doorIndicatorOffset >= 2) {doorIndicatorOffset = 0;}

	// 
	doorIndicatorAlpha = value_set_linear(doorIndicatorAlpha, doorIndicatorAlphaTarget, 0.025);
	if (doorIndicatorAlpha == 0 && doorIndicatorAlphaTarget == 0)		{doorIndicatorAlphaTarget = 1;}
	else if (doorIndicatorAlpha == 1 && doorIndicatorAlphaTarget == 1)	{doorIndicatorAlphaTarget = 0;}
}

#endregion
