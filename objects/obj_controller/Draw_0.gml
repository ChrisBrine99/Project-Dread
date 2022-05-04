// Similar to how the menu instances list is drawn in the controller's "Draw GUI" event, this line of code will
// jump to the depth sorter's drawing function which will sort all existing entities based on their Y positions
// and render them in the resulting list order. Entities that are off-screen will be skipped over.
with(DEPTH_SORTER) {draw();}


// FOR DEBUGGING
with(DEBUGGER) {draw();}
