extends Node
@export var turn_order:TurnOrder

func _ready() -> void:
	turn_order.start_sig.connect(on_turn_start)
	turn_order.end_sig.connect(on_turn_end)
var awaiting = false
func _process(delta: float) -> void:
	if awaiting:
		return
	if turn_order.mid_turn and turn_order.active and not turn_order.awaiting:
		if turn_order.get_cur().is_ready_to_end():
			turn_order.end_turn()
func on_turn_start():
	var p:Player= turn_order.get_cur()
	await get_tree().create_timer(1.25).timeout
	await Define.outer_party.focus_on_viewport(p.player_id)
	p.board_control_allowed = true
	
func on_turn_end():
	var p:Player= turn_order.get_cur()
	p.board_control_allowed = false
	await Define.outer_party.finish_focusing()
	await get_tree().create_timer(1.25).timeout
