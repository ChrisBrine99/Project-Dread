// Update delta time at the beginning of each new frame.
global.deltaTime = (delta_time / 1000000) * global.targetFPS;

// Resetting the redundancy variables for the outline shader on the start of each new frame.
with(global.shaderOutline){
	curFont = -1;
	curOutlineColor = array_create(0, 0);
}