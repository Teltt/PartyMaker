extends CapsuleBase



## Resets Variables to default
func reset() -> void:
	super()

## Deletes this Space, Severs connections too
func finish() -> void:
	super()
	
## ABOUT THE FUNCTION
## When an Event like Landing or Passing
## happens it goes here to be processed initially
## any persistent logic should be handled in tick or tick player
## ABOUT THE RETURN VALUE
## returns a value to determine whether or not 
## code that changes the state is skipped 
## return false in order to not skip
func activate(activation_type: int, pl: Player = null) -> Result:
	
	if activation_type == Define.ACTIVATION.ACT_INIT_SPACE:
		super(activation_type,pl)
		my_player = Define.dummy
	if activation_type == Define.ACTIVATION.ACT_PASS:
		pl.coin_mgr.prepare_change(1,1.0,0.5)
		finish()
	return GO_NO_SKIP


## Do any persistent logic here
func tick(delta_t: float) -> void:
	super(delta_t)

## A persistent function that handles each player
## Handle Player by Player Inputs here
## Functionally it's just a second tick function that operates on each Player
func handle_player(delta_t: float,player: Player) -> void:
	super(delta_t,player)
	pass
## Do drawing here and only here
func _draw() -> void:
	super()
	pass
