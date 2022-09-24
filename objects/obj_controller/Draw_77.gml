// Since automatic rendering has been disabled in order to allow for post-processing effects to work properly,
// it needs to be rendered here using the built-in "Post Draw" event to ensure that it's only fully drawn to the
// screen AFTER everything else has been rendered; both application surface and GUI surface alike.
var _scale = RESOLUTION_SCALE; // The scale must be applied to match the window's size.
draw_surface_ext(application_surface, 0, 0, _scale, _scale, 0, c_white, 1);