/// @description Manages the graphical effects in the game that could be classified as "post-processing"
/// within the rendering pipeline. Effects like lighting, bloom, screen blurring, as well as filters like
/// the scanline and coise are all handled and rendered by this object.

#region	Initializing any macros that are useful/related to obj_effect_handler
#endregion

#region Initializing enumerators that are useful/related to obj_effect_handler
#endregion

#region Initializing any globals that are useful/related to obj_effect_handler

// A list that stores the instance ID values for all lighting components that are currently active within
// the game; allowing them to be rendered in a single batch within the effect handler's draw event.
global.lightSources = ds_list_create();

#endregion

#region The main object code for obj_effect_handler

function obj_effect_handler() constructor{
	// Much like Game Maker's own object_index variable, this will store the unique ID value provided to this
	// object by Game Maker during runtime; in order to easily use it within a singleton system.
	object_index = obj_effect_handler;
	
	// Stores the current texel values for the application surface, which is a normalized value for a single
	// pixel relative to the dimensions of said surface. Since the aspect ratio can be altered in the game,
	// these variables will be updated to store the proper texel sizes for any changes that occur.
	windowTexelWidth =	1 / CAM_WIDTH;
	windowTexelHeight = 1 / CAM_HEIGHT;
	
	// Stores the surface that has each light source rendered onto it before being blended back onto the
	// application surface to result in a natural-looking lighting system.
	surfLight = noone;
	
	// Grabbing all of the uniform location values from within the light shader; storing their values into
	// variables that are then referenced whenever rendering needs to be done with the lighting shader.
	sLightPosition =	shader_get_uniform(shd_light, "lightPosition");
	sLightDirection =	shader_get_uniform(shd_light, "lightDirection");
	sLightStrength =	shader_get_uniform(shd_light, "lightStrength");
	sLightSize =		shader_get_uniform(shd_light, "lightSize");
	sLightFov =			shader_get_uniform(shd_light, "lightFov");
	
	// Two unique variables that effects the base color for the ambient lighting that is drawn before any 
	// light sources have been drawn to the surface. The color determines the hue of areas with no lights and
	// the strength determines how bright that area is without any lighting.
	ambientColor =		HEX_DARK_BLUE;
	ambientStrength =	0.95;
	
	// Stores a buffer image of the application surface that is used to properly create the blurring effect.
	// It can either handle the vertical pass or the horizontal pass required for the shader, but the default
	// application surface cannot be used for both at the same time.
	surfBlurBuffer = noone;
	
	// Store each of the uniforms required for the blurring shader to their own unique variables, which are
	// then used again when rendering with the blur shader to apply the correct settings to it; creating
	// the desired effect based on the settings applied to said uniforms.
	sBlurRadius =		shader_get_uniform(shd_screen_blur, "blurRadius");
	sBlurIntensity =	shader_get_uniform(shd_screen_blur, "blurIntensity");
	sBlurTexelSize =	shader_get_uniform(shd_screen_blur, "blurTexelSize");
	sBlurDirection =	shader_get_uniform(shd_screen_blur, "blurDirection");
	
	// These two variables will determine how the blur will actually look when applied to the application
	// surface. The first value is the radius for the blur, (How many pixels to the left and right of the
	// current fragment being processed in will affect said fragment's final color) and the second is how
	// intense the application of that blurring process will be on a given fragment.
	blurRadius =		5;
	blurIntensity =		0;
	
	// These variables will cause the blur's intensity value to smoothly shift between the current value
	// and the target value set within the "intensityTarget" variable. The modifier will determine how
	// fade the blur's intensity shifts between its currentl value and the target value.
	intensityTarget =	0;
	intensityModifier = 0.001;
	
	// Variables that allow the sprite used for the film grain effect to move sporadically across the screen.
	// In short, the size is used to track the range for the offset values (Both the x and y values will use
	// the same limit value) that are randomly updated on a per-frame basis within the game.
	fgSize = sprite_get_width(spr_film_grain);
	fgOffsetX = 0;
	fgOffsetY = 0;
	
	// Stores the uniform location for the scanline shader's opacity value, which is then used to determine
	// how instance the "scanline" effect is within the game itself.
	sScanlineOpacity =	shader_get_uniform(shd_scanlines, "opacity");
	
	/// @description Code that should be placed into the "Step" event of whatever object is controlling
	/// obj_effect_handler. In short, it will update any variables/effects that need to be altered on a
	/// frame-by-frame basis. (Ex. Smoothly fading blur effect in and out)
	step = function(){
		blurIntensity = value_set_linear(blurIntensity, intensityTarget, intensityModifier);
	}
	
	/// @description Code that should be placed into the "Draw End" event of whatever object is controlling 
	/// obj_effect_handler. In short, it will apply all of the currently active post-processing effects onto 
	/// the screen in world-space BEFORE any UI elements are rendered, but after everything else has been drawn.
	draw_end = function(){
		var _camera = CAMERA.cameraID;
		render_lights(camera_get_view_x(_camera), camera_get_view_y(_camera));
	}
	
	/// @description Code that should be placed into the "Draw GUI Begin" event of whatever object is 
	/// controlling obj_effect_handler. In short, it will render graphical effects to the screen that above 
	/// the application surface, but BEFORE the game's GUI surface. For example, the screen blurring and
	/// bloom effects are applied here.
	draw_gui_begin = function(){
		render_screen_blur();
	}
	
	/// @description Code that should be placed into the "Draw GUI End" event of whatever object is controlling
	/// obj_effect_handler. In short, it will render graphical effects to the screen that above both the
	/// application surface AND the game's GUI surface. For example, both the scanlines and noise filter are
	/// applied here to overlap the entire image.
	draw_gui_end = function(){
		if (global.settings.filmGrainEffect)	{render_film_grain();}
		if (global.settings.scanlineEffect)		{render_scanlines();}
	}
	
	/// @description Code that should be placed into the "Cleanup" event of whatever object is controlling
	/// obj_effect_handler. In short, it will cleanup any data that needs to be freed from memory that isn't 
	/// collected by Game Maker's built-in garbage collection handler.
	cleanup = function(){
		// Freeing the memory that could still potentially be reserved for each of the surfaces that are
		// used in order to achieve all of the post-processing effects that exist within the game. Otherwise,
		// they will remain allocated in memory with no reference to clear them from memory.
		if (surface_exists(surfLight)) {surface_free(surfLight);}
		if (surface_exists(surfBlurBuffer)) {surface_free(surfBlurBuffer);}
		
		// Since this struct should exist for the entire duration of the game, all existing light sources
		// will be removed from memory through this loop before the ds_list for managing and referencing
		// those lights is cleared from memory.
		var _length = ds_list_size(global.lightSources);
		for (var i = 0; i < _length; i++){
			with(global.lightSources[| i].parentID) {object_remove_light_component(true);}
			delete global.lightSources[| i];
		}
		ds_list_destroy(global.lightSources);
	}
	
	/// @description The main function that handles the logic required for rendering the light sources and
	/// the overall world lighting onto the screen; darkening the regions without lights to an ambient color
	/// that can be altered; with a relative brightness for it as well. Then, it renders the lights onto
	/// that initial surface as either point lights or standard lights; blending this onto the application
	/// surface once they've all be rendered to the lighting surface.
	/// @param cameraX
	/// @param cameraY
	render_lights = function(_cameraX, _cameraY){
		// If the current surface used for rendering light sources isn't currently in VRAM, it needs to be
		// initialized based on the current width and height of the camera.
		if (!surface_exists(surfLight)) {surfLight = surface_create(CAM_WIDTH, CAM_HEIGHT);}
		
		// Offset the world matrix to the negative of the current camera's position in order to allow
		// the light surface to render itself in the proper world space coordinates despite the fact that
		// the rectangle it is rendering to isn't actually in world space, but screen space.
		matrix_set(matrix_world, matrix_build(-_cameraX, -_cameraY, 0, 0, 0, 0, 1, 1, 1));
		
		// Set the current rendering target to be the lighting surface, and clear out whatever previously
		// existed on the surface with the values of (0, 0, 0, 0) for each pixel on that surface. Then, apply
		// a manipulated version of the application surface that is blended to the ambient color at a given
		// intensity for the world's base ambient lighting.
		surface_set_target(surfLight);
		draw_clear_alpha(c_black, 0);
		draw_surface_ext(application_surface, _cameraX, _cameraY, 1, 1, 0, ambientColor, ambientStrength * (1 - global.settings.brightness));
		
		// After setting up the surface for rendering all light sources to it, set up the shader for rendering
		// those light sources and apply the correct blendmode to the rendering, which will add each light
		// onto the surface instead of just overwriting them like bm_normal would do.
		shader_set(shd_light);
		gpu_set_blendmode(bm_add);
		
		// In order to reference the uniform locations for the light shader from within each light source
		// instance, they need to all be placed into local variables before they can be referenced locally
		// by any object from this point on in the current function.
		var _sLightPosition, _sLightDirection, _sLightStrength, _sLightSize, _sLightFov;
		_sLightPosition = sLightPosition;
		_sLightDirection = sLightDirection;
		_sLightStrength = sLightStrength;
		_sLightSize = sLightSize;
		_sLightFov = sLightFov;
		
		// After setting up the surface, shader, and local uniform variable values, jump into a loop that 
		// will go through each light source struct that currently exists in the room and render it using
		// the light shader; applying the unique characteristics of each of those lights to the shader and
		// rendering that light onto the light surface.
		var _length = ds_list_size(global.lightSources);
		for (var i = 0; i < _length; i++){
			with(global.lightSources[| i]){
				// Apply the position, direction, strength, radius, and FOV of the light into the shader
				// by using its stored uniform locations, respectively.
				shader_set_uniform_f(_sLightPosition, x, y);
				shader_set_uniform_f(_sLightDirection, direction);
				shader_set_uniform_f(_sLightStrength, strength);
				shader_set_uniform_f(_sLightSize, radius);
				shader_set_uniform_f(_sLightFov, fov);
				
				// After apply all the characteristics to their respective uniforms, draw the light by simply
				// drawing the application surface in this additive blending mode, which results in a proper
				// light source being drawn to the light surface.
				draw_surface_ext(application_surface, _cameraX, _cameraY, 1, 1, 0, color, 1);
			}
		}
		
		// After all the light sources have been looped through, reset both the shader and the rendering
		// target in order to resume Game Maker's standard rendering characteristics.
		shader_reset();
		surface_reset_target();
		
		// Reset the world matrix back to its default values in order to render things properly again.
		matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1));
		
		// Finally, render the light surface by manipulating the blend mode based on the application surface's
		// alpha value for the source color, and an inversion of that alpha for the destination color. After
		// that, reset the blendmode back to normal for any other rendering.
		gpu_set_blendmode_ext(bm_dest_alpha, bm_inv_dest_alpha);
		draw_surface(surfLight, _cameraX, _cameraY);
		gpu_set_blendmode(bm_normal);
	}
	
	/// @description The function that contains all the logic for rendering the contents of the entire
	/// screen with a blur applied to them. It's a two-pass system that will blur in one direction, then
	/// take that first pass's result and draw it back to the application surface for the second direction's
	/// blur; creating an accurate gaussian blur effect in the game.
	render_screen_blur = function(){
		// Don't waste time attempting to render the screen blur if there isn't a possibility of it being
		// visible to the user due to either of these two parameters being zeroed out.
		if (blurRadius == 0 || blurIntensity == 0) {return;}
		
		// Make sure the buffer surface for the blurring effect exists within the GPU's memory before
		// any processing of the effect has begun. It's dimensions are the same as the window's.
		if (!surface_exists(surfBlurBuffer)) {surfBlurBuffer = surface_create(CAM_WIDTH, CAM_HEIGHT);}
		
		// First, the shader will be activated and the main parameters will be set; the radius of the blur,
		// (This determines how many pixels around the current fragment will effect the final color of said
		// fragment) its intensity, (How blurry the image will be overall) and the values for the texel
		// width and height of each pixel for the screen. (THese are normalized values between 0 and 1)
		shader_set(shd_screen_blur);
		shader_set_uniform_f(sBlurRadius, blurRadius);
		shader_set_uniform_f(sBlurTexelSize, windowTexelWidth, windowTexelHeight);
		shader_set_uniform_f(sBlurIntensity, blurIntensity);
		
		// Once the parameters for the shader have been properly set/updated, the first pass of the shader
		// will draw the application surface to the blur's buffer surface; applying the horizontal blurring
		// to it. (What axis is blurred first doesn't actually matter to the shader)
		shader_set_uniform_f(sBlurDirection, 1, 0);
		surface_set_target(surfBlurBuffer);
		draw_surface(application_surface, 0, 0);
		surface_reset_target();
		
		// After the first pass is completed, the buffer surface containing that first pass texture will be
		// redrawn to the application surface; blurring it on the remaining axis to complete the blur effect.
		shader_set_uniform_f(sBlurDirection, 0, 1);
		draw_surface(surfBlurBuffer, 0, 0);
		
		// Finally, the shader is reset to prevent any accidental applications of this blur shader's effects
		// in other draw events throughout the code.
		shader_reset();
	}
	
	
	/// @description A simple function that simulates a film grain effect on top of the game's image. It will
	/// do so by picking a new randomized coordinate to offset itself by and then it will used that offset to
	/// darw and tile itself across the entire screen, accordingly.
	render_film_grain = function(){
		// First, refresh the position of the film grain to a new random position between a range of twice
		// the width of the used sprite; subtracted by said width to make the range -width to +width.
		fgOffsetX = irandom_range(-fgSize, fgSize) + 1;
		fgOffsetY = irandom_range(-fgSize, fgSize) + 1;
		
		// After getting a new randomized position from within the given range, draw the sprite tiled across
		// the screen starting from that offset value; the offset being the exact pixel within the image to
		// place at the top-left corner of the screen--continuing off of that across the whole window.
		draw_sprite_tiled_ext(spr_film_grain, 0, fgOffsetX, fgOffsetY, 1, 1, c_white, 0.15);
	}
	
	/// @description A simple function that simulates an old CRT's interlacing effect that caused every other
	/// scanline to appear slightly darker than the others; producing the scanline effect we all know. This
	/// implementation is very crude and will only apply that interlacing effect as a slightly darkened line
	/// on every other row of pixels on the game window; no color bleeding or distortions that occurred along
	/// with the scanlines on old CRT displays.
	render_scanlines = function(){
		shader_set(shd_scanlines);
		shader_set_uniform_f(sScanlineOpacity, 0.15);
		draw_sprite_ext(spr_rectangle, 0, 0, 0, CAM_WIDTH, CAM_HEIGHT, 0, c_white, 1);
		shader_reset();
	}
}

#endregion

#region Global functions related to obj_effect_handler

/// @description Removes all of the light sources from memory that aren't set to persistent whenever a room
/// has triggered its "Room End" event (This function should be called by "obj_controller" in its "Room End"
/// for this very purpose. Without this function all light sources will be lost in memory since the objects
/// they were previously attached to might not exist within the next room.
function effect_unload_room_lighting(){
	// First, create a new list that will become the global light sources list once all the non-persistent
	// lights have been cleared out of memory. Persistent are carried over into this list.
	var _persistentLights = ds_list_create();
	
	// Loop through all light sources that currently exist within the room; carrying them over to the next
	// room or removing it from memory depending on the value of each of their "isPersistent" flags.
	var _length, _light;
	_length = ds_list_size(global.lightSources);
	for (var i = 0; i < _length; i++){
		_light = global.lightSources[| i];
		// The current light is a persistent light source, (Ex. The player's flashlight) so it will be
		// carried over to the new list for all light sources.
		if (_light.isPersistent){
			ds_list_add(_persistentLights, _light);
			continue; // Skips to the next index instently
		}
		// The current light source isn't persistent; delete it from memory before moving onto the next index.
		delete global.lightSources[| i];
	}
	
	// After the previous list has had all its non-persistent light sources cleared from it, the list will
	// be destroyed from memory and the pointer to the persistent light source list will be carried into the
	// global.lightSources variable; making that list the new light source management list.
	ds_list_destroy(global.lightSources);
	global.lightSources = _persistentLights;
}

#endregion