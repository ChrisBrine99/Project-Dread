// 
if (EVENT_GET_FLAG(eventFlagID) == eventTargetState){
	instance_destroy(self);
	return;
}

// 
var _length, _flag;
_length = ds_list_size(requiredFlags);
for (var i = 0; i < _length; i++){
	_flag = requiredFlags[| i];
	if (!is_undefined(_flag) && EVENT_GET_FLAG(_flag[0]) != _flag[1]){
		instance_destroy(self);
		break;
	}
}