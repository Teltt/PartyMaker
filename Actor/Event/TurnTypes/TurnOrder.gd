extends Event
class_name TurnOrder
@export_storage var turn_order:Array[NodePath]
@export_storage var cur_turn:int = 0
@export_storage var rolls:Array[int] = [0,0,0,0]
@export_storage var initted:bool = false
@export_storage var turn_order_chosen:bool = false
@export var cam_target:Node3D
@export var dice:Array[NodePath]
## Resets Variables to default
func reset() -> void:
	super()
## ABOUT THE FUNCTION
## When an Event like Landing or Passing
## happens it goes here to be processed initially
## any persistent logic should be handled in tick or tick player
## ABOUT THE RETURN VALUE
## returns a value to determine whether or not 
## code that changes the state is skipped 
## return false in order to not skip
func activate(type:int, info: Player) -> Result:
	super(type,info)
	if type == Define.ACTIVATION.ACT_START_TURN:
		active = true
		if not initted:
			await init()
		cur_turn = 0
		start_turn()
		return GO_NO_SKIP
	return GO_NO_SKIP
signal sig_order_chosen
func init() -> void:
	awaiting = true
	Define.party.wait_for_event_sig(self,sig_order_chosen)
	Define.event_cam.global_transform = cam_target.global_transform
	await Define.outer_party.focus_on_viewport(5)
	for p in Define.party.players:
		p.board_control_allowed = false
	for d in dice.size():
		get_node(dice[d]).roll_reliable()
	await get_tree().create_timer(1.25).timeout
	initted = true
	awaiting = false
	await  sig_order_chosen
	for d in dice:
		get_node(d).set_visible(false)
var awaiting = false
## Do any persistent logic here
func tick(delta_t):
	super(delta_t)
	if awaiting:
		return
	if active and initted:
		awaiting = true
		await chose_turn_order()
		awaiting = false
	if active:
		pass
func chose_turn_order():
	if not turn_order_chosen:
		for p in Define.party.players:
			if rolls[p.player_id] ==0:
				if Input.is_action_just_pressed(p.controls.player+p.controls.a):
					rolls[p.player_id] = get_node(dice[p.player_id]).number
		if frames_ticked% 15 == 0:
			for d in dice.size():
				if rolls[d] ==0:
					get_node(dice[d]).roll_reliable()
		if rolls.all(func(ele):
			return ele != 0):
				var ma = find_max()
				turn_order.push_back(get_path_to(Define.party.players[ma]))
				rolls[ma] = -1
				ma = find_max()
				turn_order.push_back(get_path_to(Define.party.players[ma]))
				rolls[ma] = -1
				ma = find_max()
				turn_order.push_back(get_path_to(Define.party.players[ma]))
				rolls[ma] = -1
				ma = find_max()
				turn_order.push_back(get_path_to(Define.party.players[ma]))
				rolls[ma] = -1
				await Define.outer_party.finish_focusing()
				await get_tree().create_timer(1.25).timeout
				turn_order_chosen = true
				sig_order_chosen.emit()
var mid_turn = false
func get_cur()->Player:
	return get_node(turn_order[cur_turn])
signal start_sig
signal end_sig
func start_turn():
	start_sig.emit()
	mid_turn = true
	pass
func end_turn():
	if Define.party.is_waiting():
		return
	awaiting = true
	mid_turn = false
	end_sig.emit()
	cur_turn= wrapi(cur_turn+1,0,5)
	if cur_turn < 4:
		start_turn()
	else:
		active = false
	pass
	awaiting = false
func find_max():
	var ma = rolls[0]
	for r in rolls:
		ma = max(r,ma)
	return rolls.find(ma,0)
	
## A persistent function that handles each player
## Handle Player by Player Inputs here
## Functionally it's just a second tick function that operates on each Player
func handle_player(delta_t: float,player: Player) -> void:
	super(delta_t,player)
	pass



## Deletes this Capsule Event, activates the spaces finish event if it exists
func finish() -> void:
	super()
