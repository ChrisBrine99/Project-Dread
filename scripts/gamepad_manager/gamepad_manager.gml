/// @description Insert summary of this file here.

#region Initializing any macros that are useful/related to the gamepad manager

// 
#macro	GAMEPAD_ID				global.gamepadManager.gamepadID
#macro	GAMEPAD_IS_ACTIVE		global.gamepadManager.isActive

#endregion

#region Initializing enumerators that are useful/related to the gamepad manager
#endregion

#region Initializing any globals that are useful/related to the gamepad manager
#endregion

#region The main object code for the gamepad manager

global.gamepadManager = {
	// 
	gamepadID : -1,			// 0 to 4 = XInput, 4 to 11 = DirectInput
	isActive : false,
}

#endregion

#region Global functions related to the gamepad manager
#endregion