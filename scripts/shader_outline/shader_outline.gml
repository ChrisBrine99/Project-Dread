/// @description Insert summary of this file here.

#region Initializing any macros that are useful/related to the outline shader handler

// A macro to simplify the look of the code whenever the outline shader struct needs to be referenced.
#macro	SHADER_OUTLINE			global.shaderOutline

#endregion

#region Initializing enumerators that are useful/related to the outline shader handler
#endregion

#region Initializing any globals that are useful/related to the outline shader handler

// Stores the ID values for each font resource's texture for easy and quick reference whenever the outline
// shader is in use. Otherwise, these IDs would need to be retrieved every frame within the code.
global.fontTextures = ds_map_create();
ds_map_add(global.fontTextures, font_gui_small,		font_get_texture(font_gui_small));
ds_map_add(global.fontTextures, font_gui_medium,	font_get_texture(font_gui_medium));
ds_map_add(global.fontTextures, font_gui_large,		font_get_texture(font_gui_large));

#endregion

#region The main object code for the outline shader handler (Used only for Structs)

global.shaderOutline = {
	// 
	sPixelWidth :		shader_get_uniform(shd_outline, "pixelWidth"),
	sPixelHeight :		shader_get_uniform(shd_outline, "pixelHeight"),
	sDrawOutline :		shader_get_uniform(shd_outline, "drawOutline"),
	sDrawCorners :		shader_get_uniform(shd_outline, "drawCorners"),
	sColor :			shader_get_uniform(shd_outline, "color"),
	
	// 
	curFont :			-1,
	curTexelWidth :		0,
	curTexelHeight :	0,
	curOutlineColor :	array_create(3, 0),
	
	/// @description 
	begin_step : function(){
		curOutlineColor = array_create(3, 0);
		curTexelWidth = 0;
		curTexelHeight = 0;
		curFont = -1;
	},
	
	/// @description 
	/// @param fontTexture
	outline_set_texel_width : function(_fontTexture){
		var _texelWidth = texture_get_texel_width(_fontTexture);
		if (_texelWidth != curTexelWidth){
			shader_set_uniform_f(sPixelWidth, texture_get_texel_width(_fontTexture));
			curTexelWidth = _texelWidth;
		}
	},
	
	/// @description 
	/// @param fontTexture
	outline_set_texel_height : function(_fontTexture){
		var _texelHeight = texture_get_texel_height(_fontTexture);
		if (_texelHeight != curTexelHeight){
			shader_set_uniform_f(sPixelHeight, texture_get_texel_height(_fontTexture));
			curTexelHeight = _texelHeight;
		}
	}
}

#endregion

#region Global functions related to the outline shader handler

/// @description Initializes the outline shader. If the shader has already been set, the function will do
/// nothing. Otherwise, the shader will be assigned and the required data for the texel dimensions, color,
/// and flags for drawing the outline or corners from the getgo are assigned to each uniform.
/// @param {Asset.GMFont}	font			An existing GML font resource.
/// @param {Array<Real>}	outlineColor	An array with three values for the r, g, and b channels of the outline color.
/// @param {Bool}			drawOutline		Enables/disables the outline outright.
/// @param {Bool}			drawCorners		Enables/disables filling in the corners of the outline.
function shader_set_outline(_font, _outlineColor, _drawOutline = true, _drawCorners = true){
	if (shader_current() == shd_outline) {return;}
	with(SHADER_OUTLINE){
		// 
		shader_set(shd_outline);
		
		// 
		var _fontTexture = global.fontTextures[? _font];
		if (!is_undefined(_fontTexture)){
			outline_set_texel_width(_fontTexture);
			outline_set_texel_height(_fontTexture);
			draw_set_font(_font);
			curFont = _font;
		}
		
		// 
		if (!array_equals(_outlineColor, curOutlineColor)){
			shader_set_uniform_f_array(sColor, _outlineColor);
			curOutlineColor = _outlineColor;
		}
		
		// 
		shader_set_uniform_i(sDrawOutline, _drawOutline);
		shader_set_uniform_i(sDrawCorners, _drawCorners);
	}
}

/// @description Assigns a new font for use with the outline shader. If the font provided by the function is
/// the exact same as the previously assigned font this function will execute no code. Otherwise, time would
/// be wasted assigning the same exact font and its texel dimensions to the respective shader uniforms.
/// @param {Asset.GMFont}	font
function outline_set_font(_font){
	with(SHADER_OUTLINE){
		// Don't bother updating any uniforms or the current font if the one passed into this function is the
		// exact same font that is currently being used for rendering text. Otherwise, overwrite the previous
		// font with the new one and store that font's unique constant to prevent duplicate overwriting.
		if (_font == curFont) {return;}
		draw_set_font(_font);
		curFont = _font;
		
		// Much like the function for initializing the outline shader, the font texture will be grabbed to see
		// if the texel dimensions for it match or differ from the data that is stored in the shader uniforms.
		var _fontTexture = global.fontTextures[? _font];
		if (!is_undefined(_fontTexture)){
			outline_set_texel_width(_fontTexture);
			outline_set_texel_height(_fontTexture);
		}
	}
}

/// @description Overwrites the previously used color (Stored as an array with values ranging from 0 to 1)
/// with a new array of color values. If the color provided is the same as the previous color array, the code
/// will execute nothing since there's no reason to waste time setting up duplicate data.
/// @param {Array<Real>}	color	An array with a size of 3 containing the r, g, and b values for the new color.
function outline_set_color(_color){
	with(SHADER_OUTLINE){
		if (array_equals(_color, curOutlineColor)) {return;} // Don't overwrite the previous color if the new one is the exact same values.
		shader_set_uniform_f_array(sColor, _color);
		curOutlineColor = _color;
	}
}

#endregion