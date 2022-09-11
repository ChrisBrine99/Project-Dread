// A switch/case statement that handles the connection and removal of a gamepad to be used in the game.
switch(async_load[? "event_type"]){
	case "gamepad discovered": // A gamepad has been connected to the PC
		var _gamepadID = async_load[? "pad_index"];
		// First, a check is made to make sure the gamepad is actually supported by SDL and Game Maker. If so,
		// the code will continue on with getting the gamepad's information for future input from the player.
		// Otherwise, don't do anything with the unsupported gamepad.
		if (gamepad_is_supported()){
			// Next, get the "information" for the gamepad: its unique guid value and descriptor for the
			// controller itself--if it actually has one (Ex. DualSense is referred to simply as "Wireless
			// Controller", so this isn't always unique to a given controller. After that, set the default
			// deadzone for the thumbsticks and the analogue button's "digital" threshold for the gamepad.
			var _info = gamepad_get_guid(_gamepadID) + "," + gamepad_get_description(_gamepadID);
			with(global.settings){ // Scope into the settings struct to access the required variables.
				gamepad_set_axis_deadzone(_gamepadID, gpadDeadzone);
				gamepad_set_button_threshold(_gamepadID, gpadButtonThreshold);
			}
			
			// Finally, take the info string and all the other information gathered in the local variables
			// and store it inside the gamepad's manager struct. If the gamepad's device ID is outside of the
			// XInput range, (0 to 3 inclusive) a mapping needs to be grabbed based on the connected and
			// supported controller. After that, it should work as well as an XInput controller would.
			with(global.gamepad){
				deviceID = _gamepadID;
				info = _info;
				if (deviceID >= 4 && deviceID <= 11) {gamepad_test_mapping(deviceID, get_gamepad_mapping_data(info));}
			}
		}
		break;
	case "gamepad lost": // A gamepad was just disconnected from the PC
		with(global.gamepad){
			// This makes sure that the gamepad that was disconnected (If there happened to be multiple 
			// applied to the PC at the same time for whatever reason) is actually the gamepad that was
			// paired with the game. If so, disconnect it be clearing out the struct's variables storing
			// the gamepad's information.
			if (!gamepad_is_connected(deviceID)){
				if (deviceID >= 4 && deviceID <= 11) {gamepad_remove_mapping(deviceID);}
				deviceID = -1;
				info = "";
				isActive = false;
				CONTROL_INFO.initialize_input_icons();
			}
		}
		break;
}