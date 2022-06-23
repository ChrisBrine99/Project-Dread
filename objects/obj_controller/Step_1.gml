// 
with(global.gameTime) {begin_step();}

// Resetting the redundancy variables for the outline shader on the start of each new frame.
with(global.shaderOutline){
	curFont = -1;
	curOutlineColor = array_create(0, 0);
}