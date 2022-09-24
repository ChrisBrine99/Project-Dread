/// @description Insert summary of this file here.

#region Initializing any macros that are useful/related to the audio listener

// A macro to simplify the look of the code whenever the audio manager struct needs to be referenced. The
// second macro does the same thing, but for referencing the object that is currently linked to the audio
// manager to easily know what position the audio is currently being heard from within the room.
#macro	AUDIO_MANAGER				global.audioManager
#macro	AUDIO_LINKED_OBJECT			global.audioManager.linkedObject

#endregion

#region Initializing enumerators that are useful/related to the audio listener
#endregion

#region Initializing any globals that are useful/related to the audio listener
#endregion

#region The main struct code for the audio listener

global.audioManager = {
	linkedObject : noone,
	
	/// @description Updates the position of the audio listener to whatever the position of the linked object
	/// is at the end of a given frame (No automatic update to the listener position is processed if no object
	/// is currently linked to the audio manager).
	end_step : function(){
		with(linkedObject) {audio_listener_position(x, y, 0);}	
	}
}

// 
audio_falloff_set_model(audio_falloff_linear_distance);
audio_listener_orientation(0, 0, 1, 0, -1, 0);

#endregion

#region Global functions related to the audio listener

/// @description Assigns a new instance to be linked with the audio manager. This will then cause an automatic
/// update of the audio listener's position at the end of every frame to the position of said linked object
/// at the same moment.
/// @param {Id.Instance}	objectID
function audio_set_linked_object(_objectID){
	with(global.audioManager){
		if (instance_exists(_objectID))	{linkedObject = _objectID;}
		else							{linkedObject = noone;}
	}
}

#endregion