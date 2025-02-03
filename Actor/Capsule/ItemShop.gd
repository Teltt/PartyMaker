class_name CapsuleItemShop
extends CapsuleBase
## Whether or not the shop generates a new Item on purchase
@export var limited_stock:bool = false
## How are the items that appear in the shop selected
@export var random_from_pool:bool = true
## Items that can appear in the shop
@export var items: Array[PackedScene]
## Stock of the shop, finishes when empty
@export var sale :Array[CapsuleBase]

signal done
func reset():
	super()
func finish():
	for s in sale:
		s.queue_free()
	super()
func activate(activation_type: int, pl: Player) -> Result:
	if activation_type == Define.ACTIVATION.ACT_PASS:
		active = true
		pl.wait_for_event_sig(self,done)
	return 

func handle_player(delta_t: float,player: Player):
	super(delta_t, player)
	
func tick(delta_t: float):
	super(delta_t)

func _draw():
	super()
	
