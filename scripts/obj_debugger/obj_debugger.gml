/// @description Insert summary of this file here.

#region Initializing any macros that are useful/related to obj_debugger
#endregion

#region Initializing any globals that are useful/related to obj_debugger
#endregion

#region The main object code for obj_debugger

function obj_debugger() constructor{
	linesToDraw = ds_list_create();
	
	/// @description
	end_step = function(){
		var _linesToDraw, _length;
		_linesToDraw = linesToDraw;
		_length = ds_list_size(linesToDraw);
		for (var i = 0; i < _length; i++){
			with(linesToDraw[| i]){
				curLifespan -= global.deltaTime;
				if (curLifespan <= 0){
					ds_list_delete(_linesToDraw, i);
					_length--;
					i--;
				}
			}
		}
	}
	
	/// @description 
	draw = function(){
		var _length = ds_list_size(linesToDraw);
		for (var i = 0; i < _length; i++){
			with(linesToDraw[| i]){
				draw_set_alpha(curLifespan / setLifespan);
				draw_line_color(x, y, endX, endY, color, color);
			}
		}
		draw_set_alpha(1);
		
		/*shader_set_outline(RGB_GRAY, font_gui_small);
		
		// Display the first 8 items in the inventory for testing.
		for (var i = 0; i < 8; i++){
			if (global.items[i] == noone){
				draw_text_outline(5, 5 + (i * 10), NO_ITEM, HEX_WHITE, RGB_GRAY, 1);
				continue;
			}
			
			with(global.items[i]){
				draw_text_outline(5, 5 + (i * 10), itemName, HEX_WHITE, RGB_GRAY, 1);
				draw_text_outline(120, 5 + (i * 10), "x" + string(quantity), HEX_WHITE, RGB_GRAY, 1);
				
				if (isEquipped) {draw_text_outline(140, 5 + (i * 10), "E", HEX_LIGHT_YELLOW, RGB_DARK_YELLOW, 1);}
			}
		}
		
		with(PLAYER){
			draw_set_halign(fa_right);
			with(equipSlot){
				draw_text_outline(CAM_WIDTH - 5, 5, "Weapon: " + string(weapon) + "\n" +
													"Throwable: " + string(throwable) + "\n" +
													"Armor: " + string(armor) + "\n" +
													"Flashlight: " + string(flashlight), HEX_WHITE, RGB_GRAY, 1);
			}
			
			draw_text_outline(CAM_WIDTH - 5, CAM_HEIGHT - 12, string(global.items[equipSlot.weapon].quantity) + "\\" + string(weaponData.ammoRemaining), HEX_WHITE, RGB_GRAY, 1); 
			draw_set_halign(fa_left);
		}
		
		shader_reset();*/
	}
	
	/// @description
	draw_gui = function(){
		// 
		shader_set_outline(RGB_GRAY, font_gui_small);
		draw_text_outline(5, 5, string(PLAYER.accuracyPenalty), HEX_WHITE, RGB_GRAY, 1); 
		shader_reset();
		
		// 
		draw_sprite_ext(spr_rectangle, 0, PLAYER.x + lengthdir_x(8, PLAYER.direction) - CAMERA.x, PLAYER.y + lengthdir_y(8, PLAYER.direction) - 12 - CAMERA.y, 1, 1, 0, c_white, 1);
	}
	
	/// @description 
	cleanup = function(){
		var _length = ds_list_size(linesToDraw);
		for (var i = 0; i < _length; i++) {delete linesToDraw[| i];}
		ds_list_destroy(linesToDraw);
	}
	
	/// @description 
	/// @param startX
	/// @param startY
	/// @param endX
	/// @param endY
	/// @param color
	/// @param lifespan
	debug_add_line = function(_startX, _startY, _endX, _endY, _color, _lifespan){
		ds_list_add(linesToDraw, {
			// 
			x :				_startX,
			y :				_startY,
							
			//				
			endX :			_endX,
			endY :			_endY,
							
			//				
			color :			_color,
			
			// 
			curLifespan :	_lifespan,
			setLifespan :	_lifespan,
		});
	}
}

#endregion

#region Global functions related to obj_debugger
#endregion