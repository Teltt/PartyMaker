extends CapsuleBase
class_name SniperCapsule

var target_player: Player = null
const STUN_TIME: float = 1.5
var is_stunning: bool = false

func reset():
	super()
	target_player = null
	is_stunning = false

func activate(activation_type: int, pl: Player) -> Result:
	var party = Define.party
	
	if activation_type == Define.ACTIVATION.ACT_INIT_SPACE:
		active = true
		my_player = pl
		super(activation_type, pl)
		check_for_players()
		
	
	return GO_NO_SKIP

func check_for_players():
	var party = Define.party
	for player in party.players:
		if player != my_player and player.travel.cur_space == my_space:
			target_player = player
			apply_effects()
			return
	active = false
	finish()

func handle_player(delta_t: float, player: Player):
	super(delta_t, player)
	
	if active and not is_stunning and player != my_player and player.travel.cur_space == my_space:
		target_player = player
		apply_effects()

func apply_effects():
	if target_player and my_player:
		var coins_to_steal = min(10, target_player.coin_mgr.amount)
		target_player.coin_mgr.prepare_change(-coins_to_steal)
		my_player.coin_mgr.prepare_change(coins_to_steal)
		stun_player()

func stun_player():
	if target_player:
		target_player.can_travel = false
		is_stunning = true
	apply_stun_effect()

func apply_stun_effect():
	await get_tree().create_timer(STUN_TIME).timeout
	end_stun()

func end_stun():
	if target_player:
		target_player.can_travel = true
		target_player.travel.force_move_to_next_space()
	is_stunning = false
	finish()


func tick(delta_t: float):
	super(delta_t)
func _draw():
	super()
