@tool
@icon("res://Resource/Graphics/EventSpace.png")
extends Space

@onready var A = $Graphics/A
@onready var B = $Graphics/B
@onready var X = $Graphics/X
@onready var Y = $Graphics/Y
enum BUTTON  {
	A=0,
	B=1,
	X=2,
	Y=3
}
@onready var buttons = [
	A,B,X,Y
]
@onready var animation_player = $Graphics/AnimationPlayer

@onready var fail = $Graphics/Fail
@onready var success = $Graphics/Success
var expected_button = 0
var TIME = 5.0
const PRESSES = 5
var buttons_pressed = 0
var started = false
var focused_player = null
signal finished_operation
## Resets Variables to default
func reset() -> void:
	
	started = false
	buttons_pressed = 0
	focused_player = null
	super()

## Deletes this Space, Severs connections too
func finish() -> void:
	super()


## ABOUT THE FUNCTION
## When an Event like Landing or Passing
## happens it goes here to be processed initially
## any persistent logic should be handled in tick or tick player
## ABOUT THE RETURN VALUE
## returns a value to determine whether or not 
## code that changes the state is skipped 
## return false in order to not skip
func activate(activation_type: int, pl: Player = null) -> Result:
	var party = Define.party
	if activation_type == Define.ACTIVATION.ACT_LAND:
		$Graphics.set_visible(true)
		focused_player = pl
		Define.outer_party.focus_on_viewport(pl.player_id)
		party.wait_for_event_sig(self,finished_operation)
		expected_button = randi_range(BUTTON.A,BUTTON.Y)
		animation_player.play("PreEvent")
		await animation_player.animation_finished
		active = true
		
		super(activation_type,pl)
		started = true
		
	return GO_NO_SKIP
var awaiting = false
## Do any persistent logic here
func tick(delta_t: float) -> void:
	if awaiting and started:
		super(delta_t)
		for button in buttons.size():
			buttons[button].visible = button == expected_button
		return
	if started:
		awaiting = true
		await get_tree().create_timer(TIME).timeout
		awaiting = false
		if buttons_pressed < PRESSES:
			fail.set_visible(true)
		else:
			success.set_visible(true)
			focused_player.coin_mgr.prepare_change(10,1.0,0.5)
		started = false
		
		for button in buttons:
			button.visible = false
		Define.outer_party.finish_focusing()
		animation_player.play("PostEvent")
		await animation_player.animation_finished
		finished_operation.emit()
		$Graphics.set_visible(false)
		active = false
		
		reset()

## A persistent function that handles each player
## Handle Player by Player Inputs here
## Functionally it's just a second tick function that operates on each Player
func handle_player(delta_t: float,player: Player) -> void:
	if not started:
		super(delta_t,player)
		return
	if player != focused_player and started:
		super(delta_t,player)
		return
	if started and Input.is_action_just_pressed(player.controls.player+player.controls.a):
		if expected_button == BUTTON.A:
			buttons_pressed+=1
			expected_button =  randi_range(BUTTON.A,BUTTON.Y)
	
	if started and Input.is_action_just_pressed(player.controls.player+player.controls.b):
		if expected_button == BUTTON.B:
			buttons_pressed+=1
			expected_button =  randi_range(BUTTON.A,BUTTON.Y)

	if started and  Input.is_action_just_pressed(player.controls.player+player.controls.x):
		if expected_button == BUTTON.X:
			buttons_pressed+=1
			expected_button =  randi_range(BUTTON.A,BUTTON.Y)
	if started and  Input.is_action_just_pressed(player.controls.player+player.controls.y):
		if expected_button == BUTTON.Y:
			buttons_pressed+=1
			expected_button =  randi_range(BUTTON.A,BUTTON.Y)
	super(delta_t,player)
	pass
	
#func save(save_dictionary:Dictionary = {}) -> Dictionary:
	#save_dictionary = super(save_dictionary)
	#return save_dictionary
	#
#func load_me(save_dictionary:Dictionary) -> void:
	#for key in save_dictionary:
			#if save_dictionary[key] is String:
				#if not null == (str_to_var(save_dictionary[key])):
					#self[key] = str_to_var(save_dictionary[key])
				#else:
					#self[key] =(save_dictionary[key])
			#else:
					#self[key] =(save_dictionary[key])
	#super(save_dictionary)
	#pass

## Do drawing here and only here
func _draw() -> void:
	pass
