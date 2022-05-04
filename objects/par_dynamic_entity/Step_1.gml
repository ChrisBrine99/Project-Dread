// If the entity has been destroyed, (AKA its "isDestroyed" flag has been set to true at any point during the 
// current frame of execution) it will be removed from the game here instead of wherever the flag was set.
if (isDestroyed && !isInvincible) {instance_destroy(self);}