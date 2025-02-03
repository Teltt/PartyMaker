extends CapsuleBase

var time_since_reroll = 0.0
var roll = 0
var deactivate = false
var time_until_deactivating = 0.0

func reset():
	super()
	time_since_reroll = 0.0
	roll = 0
	deactivate = false
	time_until_deactivating = 0.0

func finish():
	queue_free()
signal rolled
var prev_board_control = true
func activate(activation_type: int, pl: Player) -> Result:
	if activation_type == Define.ACTIVATION.ACT_INIT_PRESENT:
		set_visible(true)
		var party = Define.party
		active = true
		position = pl.global_position
		my_player = pl
		
		my_player.travel.landed = false
		prev_board_control = pl.board_control_allowed
		my_player.board_control_allowed = false
		pl.wait_for_event_sig(self,rolled)
		return REVERT_NO_SKIP
	return GO_NO_SKIP

func handle_player(delta_t: float,player: Player):
	super(delta_t, player)

func tick(delta_t: float):
	super(delta_t)
	if active:
		time_since_reroll += delta_t
		my_player.process_camera(delta_t)
		position = my_player.position
		if not deactivate and time_since_reroll >= 0.0180:
			roll = randi_range(1, 10)
			time_since_reroll = 0.0


		if Input.is_action_just_pressed(my_player.controls.player+my_player.controls.a) and not deactivate:
			my_player.travel.spaces_left_to_move += roll
			deactivate = true
		if deactivate:
			my_player.board_control_allowed = prev_board_control
			time_until_deactivating += delta_t

		$Dice/Label3D.text = str(roll)
		if time_until_deactivating > 1.0:
			active = false
			rolled.emit()
			finish()
func _draw():
	super()
	#draw_texture_rect(Define.mush_dice,Rect2( - Vector2(0, 64), Vector2(32, 32)),false)
#
	#draw_string(Define.system_font,
		#- Vector2(0, 34),
		#str(roll),
		#HORIZONTAL_ALIGNMENT_CENTER,40,40,
		#Color(0, 0, 0, max(0.0, 1.0 - time_until_deactivating))
	#)
