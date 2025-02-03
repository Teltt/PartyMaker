extends Control
enum WinnerBox {
	CHECKBOX = 1,
	NUMBER = 2,
	CONFIRM =4
}
var check_value = 0
var value = 0
@export var type = WinnerBox.CHECKBOX
@onready var checkbox = $CheckBox
@onready var spinbox = $SpinBox
@onready var button = $Button

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func reset():
	pass
	checkbox.button_pressed = false
	button.button_pressed = false
	spinbox.value = 4
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if type & WinnerBox.CHECKBOX == WinnerBox.CHECKBOX:	
		if type & WinnerBox.NUMBER == WinnerBox.NUMBER:
			value = spinbox.value
			check_value = 1 if checkbox.button_pressed == true else 0
		else:
			value = 1 if checkbox.button_pressed == true else 0
			check_value = 1 if checkbox.button_pressed == true else 0
		checkbox.set_visible(true)
	else:
		checkbox.set_visible(false)
	if type & WinnerBox.NUMBER == WinnerBox.NUMBER:
		spinbox.max_value = 5
		value = spinbox.value
		spinbox.set_visible(true)
	else:
		spinbox.set_visible(false)
	if type & WinnerBox.CONFIRM == WinnerBox.CONFIRM:
		value = 1 if button.button_pressed == true else 0
		button.set_visible(true)
	else:
		button.set_visible(false)
	pass
