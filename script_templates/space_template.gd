@tool
extends Space
class_name NameTheSpace

## Resets Variables to default
func reset() -> void:
	super()

## Deletes this Capsule Event, activates the spaces finish event if it exists
func finish() -> void:
	queue_free()
	
## ABOUT THE FUNCTION
## When an Event like Landing or Passing
## happens it goes here to be processed initially
## any persistent logic should be handled in tick or tick player
## ABOUT THE RETURN VALUE
## returns a value to determine whether or not 
## code that changes the state is skipped 
## return false in order to not skip
func activate(activation_type: int, pl: Player  =null, event: Event = null) -> bool:
	if activation_type == Define.ACTIVATION.ACT_LAND:
		super(activation_type,pl,event)
	if activation_type == Define.ACTIVATION.ACT_PASS:
		super(activation_type,pl,event)
	return false

## Do any persistent logic here
func tick(delta_t: float) -> void:
	super(delta_t)

## A persistent function that handles each player
## Handle Player by Player Inputs here
## Functionally it's just a second tick function that operates on each Player
func handle_player(delta_t: float,player: Player) -> void:
	pass

func save() -> Dictionary:
	var last_dictionary = super()
	var new_dictionary = {}
	for key in last_dictionary.keys():
		new_dictionary[key] = last_dictionary[key]
	return new_dictionary
	
func load_me(save_dictionary:Dictionary) -> void:
	super(save_dictionary)
