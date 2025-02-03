extends CapsuleBase

func reset():
	super()

func finish():
	super()
signal rolled
func activate(activation_type: int, pl: Player) -> Result:
	if activation_type == Define.ACTIVATION.ACT_INIT_SPACE:
		super(activation_type,pl)
		
		active = true
		$AnimationPlayer.play("scrub")
		$AnimationPlayer.animation_finished.connect(scrub,CONNECT_ONE_SHOT)
	return GO_NO_SKIP
func scrub(v=null):
	for path in my_space.next_space:
		var s = (path)
		if s.capsule:
			s.capsule.finish()
	for path in my_space.previous_space:
		var s = (path)
		if s.capsule:
			s.capsule.finish()
	active = false
	finish()
func handle_player(delta_t: float,player: Player):
	super(delta_t, player)

func tick(delta_t: float):
	super(delta_t)
func _draw():
	super()
