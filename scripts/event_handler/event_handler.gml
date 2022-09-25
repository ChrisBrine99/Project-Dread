/// @description Contains all variables and functions for the game's event flag system, which will allow the
/// enabling and disabling of things in the game like cutscene objects, item spawns, door locks, and so on.

#region Initializing any macros that are useful/related to the event handler

// A macro to simplify the look of the code whenever the event flag buffer needs to be referenced.
#macro	EVENT_HANDLER			global.eventFlags

// 
#macro	TOTAL_EVENT_FLAG_BYTES	64

//
#macro	INVALID_FLAG			-100

#endregion

#region Initializing enumerators that are useful/related to the event handler
#endregion

#region Initializing any globals that are useful/related to the event handler

// The buffer that stores all the event flags in the game. It is aligned to the smallest value possible of
// a single bit, so the total number of event flags is the buffer's size multiplied by 8. As a result, it
// uses basically no memory, and it's extremely efficient when setting/getting flag states.
global.eventFlags = buffer_create(TOTAL_EVENT_FLAG_BYTES, buffer_fast, 1);

#endregion

#region Global functions related to the event handler

/// @description Sets the desired bit within the event flag buffer to the desired state value. If the ID value
/// for the flag exceeds the total number of bits found in the buffer no flag will be set and the function will
/// simply exit prematurely.
/// @param {Real}	flagID		The position of this flag's bit relative to the start of the buffer.
/// @param {Bool}	flagState	The state to set the flag bit. (0 = False, 1 = True).
function event_set_flag(_flagID, _flagState){
	var _offset = (_flagID >> 3); // Calculates the byte-aligned offset that the flag bit is found.
	if (_offset >= TOTAL_EVENT_FLAG_BYTES) {return;}
	
	// Grab the byte that contains the desired bit from the event flag buffer (There's no way to grab a single
	// bit from a buffer; smallest amount is 8 bits per read) and set the flag bit or clear it depending on
	// what the function calls for. Then, overwrite that original buffer byte with the new data.
	var _data = buffer_peek(EVENT_HANDLER, _offset, buffer_u8);
	if (_flagState)	{_data = _data |	(1 << (_flagID & 7));}
	else			{_data = _data &   ~(1 << (_flagID & 7));}
	buffer_poke(EVENT_HANDLER, _offset, buffer_u8, _data);
}

/// @description Grabs the state of the flag given the ID value provided. Exceeding the total number of bytes
/// in the event flag buffer with a given ID value will prevent any flag check and simply return false.
/// @param {Real}	flagID		The position of this requested flag's bit relative to the first bit in the buffer.
function event_get_flag(_flagID){
	var _offset = (_flagID >> 3); // Calculates the byte-aligned offset that the flag bit is found.
	if (_flagID == INVALID_FLAG || _offset >= TOTAL_EVENT_FLAG_BYTES) {return false;}
	
	// Grab the byte that contains the bit from the buffer. Then, perform a bitwise and with a value that will
	// have the desired bit set to 1 and all other bits set to zero. This way all other bits in the byte that
	// is being used for the comparison are ignored in the result of this get_flag function.
	return (buffer_peek(EVENT_HANDLER, _offset, buffer_u8) & (1 << (_flagID & 7)) != 0);
}

#endregion