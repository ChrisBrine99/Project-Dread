// Initialize inherited variable from the parent object, and then set up the shadow to be placed beneath the
// pole that is attached to the ground for the fence. Also, set the collision height of the fence on the Z axis
// to 48 to match its height.
event_inherited(); 
object_set_shadow(true, 5, 1, 4);
zHeight = 48;
