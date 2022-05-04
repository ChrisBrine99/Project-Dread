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

// Variables for the entity shadow system. These "shadows" are just circles displayed on the floor beneath
// the entity's feet if the flag for doing so is set within the entity. The radius variable stores the radius
// for the width of the shadow; that value being halved for the height of the shadow to make it match the
// perspective that the game is going for.
displayShadow = false;
shadowRadius = 0;

// Adds the entity to the depth sorter's global grid by expanding itself by one; making room for this entity's
// information for the depth sorting logic.
depth_sorter_add_entity();
