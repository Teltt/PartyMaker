extends EventInternal
class_name Event


## Resets Variables to default
func reset() -> void:
	active = false
	time_since_activation = 0.0
	frames_ticked = 0
## ABOUT THE FUNCTION
## When an Event like Landing or Passing
## happens it goes here to be processed initially
## any persistent logic should be handled in tick or tick player
## ABOUT THE RETURN VALUE
## returns a value to determine whether or not 
## code that changes the state is skipped 
## return false in order to not skip
func activate(type:int, info: Player) -> Result:
	return GO_NO_SKIP
	
## Do any persistent logic here
func tick(delta_t):
	ticked = true
	time_since_activation += delta_t
	frames_ticked += 1

## A persistent function that handles each player
## Handle Player by Player Inputs here
## Functionally it's just a second tick function that operates on each Player
func handle_player(delta_t: float,player: Player) -> void:
	handled_player[player] = true
	pass

## Do drawing here and only here
func _draw() -> void:
	pass


## Deletes this Capsule Event, activates the spaces finish event if it exists
func finish() -> void:
	queue_free()
