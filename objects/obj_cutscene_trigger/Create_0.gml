#region Variable initialization

// 
sceneInstructions = ds_list_create();
startingIndex = 0;

// 
requiredFlags = ds_list_create();
eventFlagID = noone;

// 
eventTargetState = true;

#endregion

#region Function initialization

/// @description 
/// @param flagID
/// @param targetState
assign_event_flag = function(_flagID, _targetState){
	EVENT_CREATE_FLAG(eventFlagID, !_targetState);
	eventFlagID = _flagID;
	eventTargetState = _targetState;
}

/// @description 
/// @param flagID
/// @param requiredState
add_required_flag = function(_flagID, _requiredState){
	if (EVENT_GET_FLAG(_flagID) == EVENT_FLAG_INVALID) {EVENT_CREATE_FLAG(_flagID);}
	ds_list_add(requiredFlags, [_flagID, _requiredState]);
}

#endregion