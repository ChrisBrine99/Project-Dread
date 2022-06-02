// Removing all of the components from the entity object; preventing memory leaks from occurring if these weren't
// cleaned up during runtime. Over time, this would cause the game to crash given enough leakage.
object_remove_light_component();
object_remove_interact_component();

// Remove this entity's slot from the depth sorter's grid. Otherwise, there will permanently be an unutilized
// slot in the grid; potentially causing a crash due to the invalid data along with a potential memory leak.
depth_sorter_remove_entity();