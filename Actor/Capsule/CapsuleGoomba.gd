class_name GoombaCapsule
extends CapsuleBase

@export_storage var landed: bool = false
@export_storage var total_coins: int = 0
@export_storage var donated: Array[bool] = [false, false, false, false]
const welcome_pt1: String = "Welcome to Charity,\n please donate "
const coins_str: String = " coins."
const welcome_notif: String = "Charity:Obtained "
const welcome_manager: String = "Charity:Accept these coins"
const goodbye: String = "Charity:Accept this refund."
const goodbye_notif:String = "Charity:Service Over."
 
func reset():
	super()
	donated = [false, false, false, false]
	landed = false
	total_coins = 0
func finish() -> void:
	super()

func activate(activation_type: int, pl: Player) -> Result:
	var party = Define.party
	if activation_type == Define.ACTIVATION.ACT_INIT_SPACE:
		super(activation_type, pl)
	if activation_type == Define.ACTIVATION.ACT_INIT_PRESENT:
		my_player = pl
		super(activation_type, pl)
	if activation_type == Define.ACTIVATION.ACT_PASS and !landed:
		if pl == my_player:
			pl.add_quick_message(5.0,welcome_manager)
			pl.coin_mgr.prepare_change(3,1, 1.0)
		elif not pl.coin_mgr.amount == 0:
				var donation = randi_range(2, 6)
				pl.coin_mgr.prepare_change(-donation,4,1.0)
				total_coins += donation
				pl.add_quick_message(5.0,welcome_pt1 + str(donation) + coins_str)
				my_player.add_quick_message(5.0,welcome_notif + str(donation) + coins_str)
				donated[pl.player_id] = true
	elif activation_type == Define.ACTIVATION.ACT_LAND:
		pl.coin_mgr.prepare_change(total_coins / 2,5,1.0)
		my_player.add_quick_message(5.0,goodbye_notif)
		pl.add_quick_message(5.0,goodbye)
		finish()
		landed = true
	elif activation_type == Define.ACTIVATION.ACT_REPLACE:
		my_player = pl
		if is_instance_valid(my_space.capsule):
			var original_owner = my_space.capsule.my_player
			var original_capsule =my_space.capsule
			if original_capsule is GoombaCapsule:
				var coins_to_give = original_capsule.total_coins
				total_coins += coins_to_give
	return GO_NO_SKIP

func handle_player(delta_t: float, player):
	super(delta_t,player)

func tick(delta_t):
	super(delta_t)
	$Bank.text = str(int(total_coins))
	$Bank.modulate = $Sprite2D.modulate
