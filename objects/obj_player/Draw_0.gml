// Call the base draw event for an entity. After that, the weapon's sprite will be displayed at its required
// position relative to the player's current animation frame and direction. If no weapon is equipped currently,
// nothing else will be drawn aside from the player.
event_inherited();

if (equipSlot.weapon != noone){
	// 
	var _xx, _yy, _direction, _imageIndex;
	_xx = x;
	_yy = y;
	_direction = round(direction / SPRITE_ANGLE_DELTA);
	_imageIndex = floor(imageIndex);
	
	// 
	with(weaponData){
		// 
		var _imageXScale = 1;
		if (_direction == 3){
			imageIndex = 1;
		} else{
			if (_direction == 2) {_imageXScale = -1;}
			imageIndex = 0;
		}
		
		// 
		_xx += position[| _imageIndex * 2];
		_yy += position[| (_imageIndex * 2) + 1];
		draw_sprite_ext(weaponSprites[spriteIndex], imageIndex, _xx, _yy, _imageXScale, 1, 0, c_white, 1);
	}
}