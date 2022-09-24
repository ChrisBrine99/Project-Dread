/// @description Insert summary of this file here.

#region Initializing any macros that are useful/related to the gamepad manager

// A macro to simplify the look of the code whenever the gamepad manager struct needs to be referenced.
#macro	GAMEPAD_MANAGER			global.gamepadManager

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
	
	/// @description A simple function that is called every single possible in-game frame in order to allow
	/// controller hotswapping to work within the game. In short, it does nothing if no device exists, and
	/// it will switch the "isActive" flag to true or false depending on the last detected input.
	step : function(){
		if (deviceID == -1) {return;}
		
		var _isActive = isActive;
		if ((!isActive && gamepad_any_button(deviceID, true)) || (isActive && keyboard_check_pressed(vk_anykey))) {isActive = !isActive;}
		//if (_isActive != isActive) {CONTROL_INFO.initialize_input_icons();}
	},
}

#endregion

#region Global functions related to the gamepad manager

/// @description 
/// @param gamepad
function gamepad_get_mapping_data(_gamepad){
	switch(_gamepad){
		case SONY_DUALSHOCK_FOUR:	return _gamepad + ",a:b1,b:b2,x:b0,y:b3,leftshoulder:b4,rightshoulder:b5,lefttrigger:a3,righttrigger:a4,guide:b13,start:b9,leftstick:b10,rightstick:b11,dpup:h0.1,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,leftx:a0,lefty:a1,rightx:a2,righty:a5,back:b12,";
		case SONY_DUALSENSE:		return _gamepad + ",a:b1,b:b2,x:b0,y:b3,leftshoulder:b4,rightshoulder:b5,lefttrigger:a3,righttrigger:a4,guide:b13,start:b9,leftstick:b10,rightstick:b11,dpup:h0.1,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,leftx:a0,lefty:a1,rightx:a2,righty:a5,back:b12,";
		default:					return "";
	}
}

#endregion