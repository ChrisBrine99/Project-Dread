// Manually draw the entity within the Draw event since the depth sorter is what handles all the rendering for
// all currently visible entities within a given room. Otherwise, the order of sprite rendering wouldn't be
// correct.
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, image_blend, 1);