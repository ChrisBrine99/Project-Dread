// Grabs the ID for the tilemap that allows an entity to play a unique sound effect for their footstep whenever
// they walk over a given material located on this tilemap.
var _layerID = layer_get_id("Floor_Material");
if (layer_exists(_layerID)) {footstepTilemap = layer_tilemap_get_id(_layerID);}