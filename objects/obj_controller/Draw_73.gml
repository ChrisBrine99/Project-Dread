// Render all of the world-space post-processing effects to the application surface; starting with the main
// lighting system and everything else after that when it comes to world-space. (Ex. Bloom effect)
with(test) {draw_end();}
with(EFFECT_HANDLER) {draw_end();}