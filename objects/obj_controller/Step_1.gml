// Call the gametime manager's begin step event, which will update the delta time variable as well as the
// gameplay time tracker if it's currently active for tracking said time.
with(global.gameTime) {begin_step();}

// Resetting the redundancy variables for the outline shader on the start of each new frame.
with(global.shaderOutline){
	curFont = -1;
	curOutlineColor = array_create(0, 0);
}