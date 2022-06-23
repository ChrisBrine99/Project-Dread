// Stores pointers to the components that have been created by a given entity. Each of these components are a
// struct in order to lower the overhead of using standard objects for these optional functionalities for a
// given entity.
lightComponent = noone;
audioComponent = noone;
interactComponent = noone;

// Variables for the fake 3D that the game contains. In short, it allows entities to be above and below each
// other relative to their "Z Height", which is how tall their collision box is on this fake Z-axis.
z = 0;
zHeight = 0;

// Determines the characteristics of the entity's optional shadow. The first two variables determine the position
// of the center of the shadow relative to the entity's actual position, (The origin of the sprite, basically)
// and the final variable is the radius for the shadow, since it's a simple circular drop shadow.
shadowOffsetX = 0;
shadowOffsetY = 0;
shadowRadius = 0;

// The flag that actually determines if the entity will render its shadow onto the floor or not.
displayShadow = false;

// A flag that allows entities to have their rendering toggled on and off at any given moment. Useful for objects
// that are classified as entities, but shouldn't be rendered for the player to see. (Ex. Door warp objects)
displaySprite = true;

// Adds the entity to the depth sorter's global grid by expanding itself by one; making room for this entity's
// information for the depth sorting logic.
depth_sorter_add_entity();
