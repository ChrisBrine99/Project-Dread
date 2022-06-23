// Don't draw the entity if their spriteLength variable contains a value of zero. This means that their sprite
// wasn't properly initialized and it will cause the game to crash whe running the rendering code below.
if (spriteLength == 0) {return;}

// Setting the loop offset, which determines which direction of the entity's current sprite to use relative to
// its current direction value and the difference in angle values between each of the sprite's directions. Now,
// whenever the sprite needs to be looped, it will start at this offset instead of 0.
loopOffset = (loopLength * round(direction / SPRITE_ANGLE_DELTA)) % spriteLength;
if (imageIndex < loopOffset || imageIndex >= loopOffset + loopLength) {imageIndex = clamp(imageIndex, loopOffset, loopOffset + loopLength - 1);}

// Animating the entity's current sprite, but with an image speed that is based on delta timing and a 60fps
// reference. (Which is the denominator--changing the value changes the animation frames per second) Other
// that that, it simply counts up until the image index needs to be looped back around; triggering the event
// that is normally automatically called by an animation ending when using the default image_speed variable.
if (GAME_STATE_CURRENT != GameState.Paused){
	imageIndex += animSpeed * (spriteAnimSpeed / ANIMATION_FPS) * DELTA_TIME;
	if (imageIndex > spriteLength || imageIndex > loopOffset + loopLength){
		event_perform(ev_other, ev_animation_end);
		imageIndex = loopOffset;
	}
}

// After the new animation logic has been updated; draw the sprite to the screen using all the other default
// image/sprite manipulation variables that are built into every Game Maker object.
draw_sprite_ext(sprite_index, imageIndex, x, y + z, image_xscale, image_yscale, image_angle, image_blend, image_alpha);