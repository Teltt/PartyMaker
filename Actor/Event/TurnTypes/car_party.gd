extends Node3D
@export_storage var captain:Player
@export var players:Array[Player]
@export_storage var tfs:Array[RemoteTransform3D]
@onready var drivers:Node3D=$Car/Drivers
@export var driver_offset:float = 1.0
@export var turn_order:TurnOrder
func _ready() -> void:
		
	turn_order.start_sig.connect(on_turn_start)
	turn_order.end_sig.connect(on_turn_end)
	turn_order.sig_order_chosen.connect(on_order_chosen)
var awaiting = false
func _process(delta: float) -> void:
	if awaiting:
		return
	if turn_order.mid_turn and turn_order.active and not turn_order.awaiting:
		captain = turn_order.get_cur()
		car_process(delta)

func car_process(delta:float)-> void:
	update_space(delta)
	if captain.is_ready_to_end():
		turn_order.end_turn()
func on_order_chosen():
	
	for p in players.size():
		var tf = RemoteTransform3D.new()
		drivers.add_child(tf)
		tf.position = Vector3(0,0,driver_offset).rotated(Vector3.UP,TAU/(players.size())*p)
		tf.remote_path = tf.get_path_to(players[p])
		tf.update_rotation = false
		tf.update_scale = false
		tf.use_global_coordinates = true
		players[p].travel.node3d= self
		global_position = players[p].travel.cur_space.global_position
func update_space(delta):
	var p:Player= turn_order.get_cur()
	if p in players:
		for p2 in players:
			if p != p2:
				p2.process_camera(delta)
			p2.travel.cur_space = p.travel.cur_space
			p2.travel.next_space = p.travel.next_space
			p2.travel.prev_space = p.travel.prev_space
func on_turn_start():
	var p:Player= turn_order.get_cur()
	if p in players:
		await get_tree().create_timer(1.25).timeout
		await Define.outer_party.focus_on_viewport(p.player_id)
		p.board_control_allowed = true
func on_turn_end():
	update_space(0)
	var p:Player= turn_order.get_cur()
	if p in players:
		p.board_control_allowed = false
		await Define.outer_party.finish_focusing()
		await get_tree().create_timer(1.25).timeout
