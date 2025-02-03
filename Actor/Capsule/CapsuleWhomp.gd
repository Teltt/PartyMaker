extends CapsuleBase
# Where do we start relative to where we were activated
const start_pos = Vector3(0, 6.66667,0)

@onready var whomp:MeshInstance3D= $Whomp
# How high above the space are we?
var cur_height = Vector3(0,6.66667,0)
# Did the whomp hit the ground?
var deactivate = false
# How much time has it taken to deactivate?
var time_until_deactivating = 0

# Resets all the values back to default
func reset():
	cur_height = Vector3(0, 6.66667,0)
	deactivate = false
	time_until_deactivating = 0

# Activates the capsule
func activate(activation_type: int, pl: Player) -> Result:
	var party = Define.party
	if activation_type == Define.ACTIVATION.ACT_INIT_SPACE:
		my_player = pl
		super(activation_type, pl)
		cur_height = start_pos
	
	if activation_type == Define.ACTIVATION.ACT_PASS and pl != my_player:
		
		active = true
		pl.travel.immediate_land(false)
		return REVERT_NO_SKIP
	return GO_NO_SKIP

# Handles controller input
func handle_player(delta_t: float,player: Player) -> void:
	super(delta_t, player)

# Where the capsule does logic every frame
func tick(delta_t: float) -> void:
	super(delta_t)
	var party = Define.party
	if not deactivate and active:
		# How fast do we move
		var move_speed = -6.66667
		cur_height += Vector3(0, move_speed * delta_t,0)
		if cur_height.y >= -16:
			deactivate = true
			for p in party.players:
				var p_pos = p.position
				var owner = my_player.player_id
				if AABB(position-Vector3.ONE*1.06667, Vector3(2.13333,2.13333,2.13333)).has_point(p_pos) and not my_player == p:
					await p.travel.immediate_land()

	if deactivate:
		var move_speed = -20
		cur_height.y = max(0.0, cur_height.y + (move_speed * delta_t))
		time_until_deactivating += delta_t
		whomp.position = cur_height
	if time_until_deactivating > 1.0 and deactivate:
		
		finish()

func _draw() -> void:
	super()
	#var pos = cur_height
	#if not deactivate:
		#draw_texture_rect(Define.whomp, Rect2(pos-Vector2.ONE*32, Vector2(64, 64)),false)
	#elif deactivate:
		#draw_texture_rect(Define.whomp, Rect2(pos-Vector2.ONE*32, Vector2(64, 64)),false, Color(1.0, 1.0, 1.0, max(0.0, 1.0 - time_until_deactivating)))
