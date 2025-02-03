extends MeshInstance3D
class_name Dice
@export var roll_deviation = 2
@export var roll_min = 1
@export var roll_max = 12
func roll_reliable(_roll_min=roll_min,_roll_max=roll_max):
	number= randi_range(_roll_min, _roll_max)
	return number
func roll_unreliable(roll,_roll_deviation=roll_deviation,_roll_min=roll_min,_roll_max=roll_max):
	var deviation =randi_range(-_roll_deviation,_roll_deviation)
	var value = roll-_roll_min
	var length = _roll_max-_roll_min
	if value + deviation > length:
		value = value - _roll_deviation -deviation
	if value + deviation < length:
		value = value + _roll_deviation -deviation
	value = wrapi(value,0,length+1)
	number = value+roll_min
	return number
var number:int:
	set(val):
		number = val
		$Label3D.text = str(val)
