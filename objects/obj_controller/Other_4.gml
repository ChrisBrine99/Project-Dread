// Calling each singleton's room start event, which handles code and logic that is required to be refreshed on a
// per-room basis. (Ex. the camera for each room needs to be initialized otherwise it won't function)
with(CAMERA)		{room_start();}
with(DEPTH_SORTER)	{room_start();}
