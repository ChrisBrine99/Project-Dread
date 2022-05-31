/// @description 

#region	Initializing any macros that are useful/related to obj_depth_sorter
#endregion

#region Initializing enumerators that are useful/related to obj_depth_sorter
#endregion

#region Initializing any globals that are useful/related to obj_depth_sorter

// A global grid that contains a single slot for each active entity instance within the room. Every frame
// each entity's y position and ID are stored within this grid, which is then sorted based on they Y values
// in order to render the entities to the screen in order of their current depth; lower values drawing first.
global.entities = ds_grid_create(2, 0);

#endregion

#region The main object code for obj_depth_sorter

function obj_depth_sorter() constructor{
	// Much like Game Maker's own object_index variable, this will store the unique ID value provided to this
	// object by Game Maker during runtime; in order to easily use it within a singleton system.
	object_index = obj_depth_sorter;
	
	// Stores the total number of entities that exist within the current room. In short, its simply the size
	// of the ds_grid that is used to sort the entities based on their y/z positions in the room.
	totalEntities = 0;
	
	// Variables that store the IDs for the wall tiles in the current room, which are then used to render the
	// tilemaps in between the rendering of the entity shadows and the entities themselves; preventing any
	// overlap that could occur wihth shadows and these two tile layers.
	wallTiles =	-1;
	auxWallTiles =	-1;
	
	// Some variables that store debug information that can be displayed by the debugging object; allowing
	// for instantly knowing how many entities and entity drop shadows are currently being drawn by the 
	// depth sorting's draw event.
	entitiesDrawn = 0;
	shadowsDrawn = 0;
	
	/// @description Code that should be placed into the "room start" event of whatever object is controlling
	/// obj_depth_sorter. In short, 
	room_start = function(){
		// First, get the layer IDs for the tilemap layers themselves, since they have to be checked for
		// validity before any tilemap IDs can be grabbed and their data can be tweaked.
		var _wallLayer, _auxWallLayer;
		_wallLayer = layer_get_id("Wall_Tiles");
		_auxWallLayer = layer_get_id("Aux_Wall_Tiles");
		
		// Setting the base wall tile layer to be invisible, while also grabbing its ID in order to manually
		// draw the tilemap in between the rendering of both the entity shadows (First to be drawn) and the
		// entities themselves (Last to be drawn)
		if (layer_exists(_wallLayer)){
			wallTiles = layer_tilemap_get_id(_wallLayer);
			layer_set_visible(_wallLayer, false);
		}
		
		// Doing the same thing as above, but for the "auxiliary" wall tiles, (Things like clocks, pictures,
		// and other details that can be placed onto the wall itself) which is a layer that is drawn above
		// the base wall tiles to add details onto them.
		if (layer_exists(_auxWallLayer)){
			auxWallTiles = layer_tilemap_get_id(_auxWallLayer);
			layer_set_visible(_auxWallLayer, false);
		}
	}
	
	/// @description Code that should be placed into the "draw" event of whatever object is controlling
	/// obj_depth_sorter. In short, it renders all of the entities within the room in the order of their
	/// depth. This means that the Y positions will determine if each sprite overlaps the other, and so on.
	draw = function(){
		// If there are currently no entities in memory to display to the screen, exit out of the function
		// before it can waste time processing the code below that it can access with nothing to draw.
		if (totalEntities == 0) {return;}
		
		// A local variable that stores the index into the entity grid to place the next entity's information;
		// whether that be a dynamic entity or static, as they both have differing parent objects.
		var _yy = 0;
		
		// First, all currently existing dynamic and static entities are iterated through and placed into 
		// the ds_grid for the depth sorting rendering system. At the moment, it's unsorted; with sorting 
		// occurring after both entity groups have had their data added to the grid.
		with(par_dynamic_entity){
			global.entities[# 0, _yy] = id;
			global.entities[# 1, _yy] = y + z;
			_yy++;
		}
		with(par_static_entity){
			global.entities[# 0, _yy] = id;
			global.entities[# 1, _yy] = y + z;
			_yy++;
		}
		ds_grid_sort(global.entities, 1, true); // This is what sorts the grid based on stored y values.
		
		// To save time within the rendering loop, grab the camera's coordinates and current dimensions before
		// entering the loop, since these values never change and will cause a lot of jumping in the code if
		// they weren't stored in local variables like below.
		var _cameraX, _cameraY, _cameraWidth, _cameraHeight;
		with (CAMERA){ // The x and y values are stored within the camera singleton object.
			_cameraX = x;
			_cameraY = y;
		}
		_cameraWidth = _cameraX + CAM_WIDTH;	// The width and height are found within a struct that is separate from the camera.
		_cameraHeight = _cameraY + CAM_HEIGHT;
		
		// Call the function that renders the shadows ovals of varying/unique sizes onto the floors of the
		// current room, but below the wall tilemaps. (Those are rendered manually directly below this line)
		shadowsDrawn = 0; // Reset the debug counter before shadows are drawn again.
		draw_entity_shadows(_cameraX, _cameraY, _cameraWidth, _cameraHeight);
		
		// Draw the room's walls and wall details AFTER rendering shadows, which should only have their 
		// darkening effect applied to the ground and entities that other entities are above in certain cases.
		draw_tilemap(wallTiles, 0, 0);
		draw_tilemap(auxWallTiles, 0, 0);
		
		// Loops through all of the entities and render them in the order they were sorted in above.
		entitiesDrawn = 0; // Reset the debug counter before entities are drawn again.
		var _entitiesDrawn = 0;
		for (var i = 0; i < totalEntities; i++){
			with(global.entities[# 0, i]){
				// Display every entity that is VISIBLE ON SCREEN and has their flag for rendering themselves
				// currently set to "true". Otherwise, the view bounds check will be false OR no sprite should
				// render--meaning no draw event will be called for the entity; saving resources.
				if (displaySprite && x + sprite_width >= _cameraX && y + sprite_height >= _cameraY && x - sprite_width <= _cameraWidth && y - sprite_height <= _cameraHeight){
					event_perform(ev_draw, 0);
					_entitiesDrawn++;
				}
			}
		}
		entitiesDrawn = _entitiesDrawn;
	}
	
	/// @description Cleans up any systems and variables that could potentially cause memory leaks if left
	/// unhandled while the game is still running. (Game Maker cleans it all up at the end of runtime by
	/// default, so it doesn't matter as much in that case)
	cleanup = function(){
		ds_grid_destroy(global.entities);
	}
	
	/// @description The function that is responsible for rendering shadows on the game's floor beneath each
	/// currently existing entity in the room. It loop through all of the entities that exist within the 
	/// current room, rendering their shadows if they have been flagged to do so; the size of the shadow 
	/// being depending on how high up the entity is from the floor. (AKA its current Z value)
	/// @param cameraX
	/// @param cameraY
	/// @param cameraWidth
	/// @param cameraHeight
	draw_entity_shadows = function(_cameraX, _cameraY, _cameraWidth, _cameraHeight){
		shader_set(shd_shadow);
		var _shadowsDrawn, _shadowRadius, _halfRadius, _shadowX, _shadowY;
		_shadowsDrawn = 0;
		for (var i = 0; i < totalEntities; i++){
			with(global.entities[# 0, i]){
				if (displayShadow){
					// As the entity's z value increases, their shadow will slowly shrink in size until it is
					// no longer visible. Also, the veritcal size of the shadow is half that of the horizontal
					// size; to mimic the fake 2.5D depth of the game's artsyle.
					_shadowRadius = shadowRadius / max(1, (z * 0.15));
					_halfRadius = _shadowRadius * 0.5;
					
					// Stores the coordinates for the current entity's drop shadow; making the overall code
					// below that actually draws the shadow easier to read while containing less repeating math.
					_shadowX = x + shadowOffsetX;
					_shadowY = y + shadowOffsetY;
					
					// Determine if the entity's shadows should be drawn by checking if it's actually visible on the
					// screen. Otherwise, rendering will be a waste of time and resources, so it will be skipped.
					if (_shadowX + _shadowRadius < _cameraX || _shadowY + _halfRadius < _cameraY || _shadowX - _shadowRadius > _cameraWidth || _shadowY - _shadowRadius > _cameraHeight) {continue;}
					draw_ellipse_color(_shadowX - _shadowRadius, _shadowY - _halfRadius, _shadowX + _shadowRadius, _shadowY + _halfRadius, c_white, c_black, false);
					_shadowsDrawn++;
				}
			}
		}
		shadowsDrawn = _shadowsDrawn;
		shader_reset();
	}
}

#endregion

#region Global functions related to obj_depth_sorter

/// @description A simple function that expands the height of the depth sorting grid to account for a newly
/// created entity/static entity. If a non-entity object attempts to call this function it will simply exit
/// out of the function without expanding the grid.
function depth_sorter_add_entity(){
	if (!object_is_ancestor(object_index, par_dynamic_entity) && !object_is_ancestor(object_index, par_static_entity)) {return;}
	with(DEPTH_SORTER){ // Jump into scope with the depth sorter to access the "totalEntities" value faster.
		ds_grid_resize(global.entities, 2, totalEntities + 1);
		totalEntities++;
	}
}

/// @description A simple function that reduces the height of the depth sorting grid to account for the
/// removal of a given entity object. If there are no entities in the grid (AKA "totalEntities" is equal to
/// a value of 0 already) OR the object calling it isn't an entity child, the function will not perform the
/// height reduction to the sorting grid.
function depth_sorter_remove_entity(){
	if (!object_is_ancestor(object_index, par_dynamic_entity) && !object_is_ancestor(object_index, par_static_entity)) {return;}
	with(DEPTH_SORTER){ // Jump into scope with the depth sorter to access the "totalEntities" value faster.
		if (totalEntities > 0){ // Only resize if the number of entities isn't already 0.
			ds_grid_resize(global.entities, 2, totalEntities - 1);
			totalEntities--;
		}
	}
}

#endregion