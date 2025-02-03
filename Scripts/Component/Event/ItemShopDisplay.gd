extends Node3D
@export_range(0,3) var player_id = 0
@onready var shop:CapsuleItemShop = get_parent()
var stock_idx:Array[int] = [-1,-1,-1]
const item_x:Array[float] = [-64,0,64]
const item_y = -64
const text_y = 0
const buy = "Buy <ITEM>?"
const bought = "Bought <ITEM>."
const restocking = "With Another Customer."
const out_of_stock = "Sold Out."
func _process(delta: float) -> void:
	pass
