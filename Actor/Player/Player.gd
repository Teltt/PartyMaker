extends Node3D
class_name Player
## The Id of this player, useful for accessing in arrays
@export_range(0,4) var player_id = 0
## unused
@export_storage var sprite_id: int = -1
## is this player human
@export var cpu_controlled = true
## the input action strings
@export var controls :PlayerControl
## this controls how the player travels around the board
@export var travel:Travel
##variable for fine turning controls during events 
@export_storage var can_travel = true
##variable for fine turning controls during events 
@export_storage var can_start_travel = true
var camera :Camera3D = null
##Where the player's camera goes to
@onready var cam_target:Node3D = $Marker3D/CamTarget
## the player color
@export_storage var color:Color
@export_storage var capsule_color:Color
##the initial starting space
@export var initial_space: Space = null
@export_storage var joystick_pos: Vector2 = Vector2.ZERO
##variable for fine turning controls during events 
@export_storage var board_control_allowed = true
##variable for fine turning controls during events 
@export_storage var auto_move_camera = true
##is the player viewing the map
@export_storage var map_mode = false
@export_storage var spaces_rolled: int = 0
##has the player rolled
@export_storage var rolled_ready: bool = false

#Tracks the player's coins
@onready var coin_mgr:Amount_MGR = $Coins
#Tracks the player's stars
@onready var star_mgr:Amount_MGR = $Stars
var capsule_mgr: CapsuleMgr:
	get:
		return $CapsuleMgr
##CPU player controller
@export var cpu_mgr: CPUMGR = CPUMGR.new()
func _ready() -> void:
	cpu_mgr.player = self
	if player_id != 4:
		color = Define.opcol[player_id]
		capsule_color = Define.capsule_player_color[player_id]
		$CSGCylinder3D.set_instance_shader_parameter("color",color)
		#$CSGCylinder3D.position.x = -0.5+remap(player_id,0,3,0.0,1.0)
		#$CSGCylinder3D.position.z = -0.5+remap(player_id,0,3,0.0,1.0)
		ready_ui()
	else:
		$Node2D.set_visible(false)
	if not Define.party.loading:
		travel.cur_space = initial_space
	if travel.cur_space:
		position = travel.cur_space.position
	capsule_mgr = $CapsuleMgr
signal sig_unpaused 
signal sig_paused
@export_storage var __paused: bool = false:
	set(val):
		var prev = __paused
		__paused = val
		set_process(not __paused)
		#set_physics_process(not __paused)
		set_process_input(not __paused)
		if not val and val != prev:
			sig_unpaused.emit()
		if val and val != prev:
			sig_paused.emit()
func on_event_queue_moved():
	var party = Define.party
	var s = self
	var waiting = party.is_waiting() and not s == party.event_queue[0]
	if not waiting:
		__paused = false
		return
	party.event_queue_moved.connect(on_event_queue_moved,CONNECT_ONE_SHOT)
func _physics_process(_delta: float) -> void:
	if cpu_controlled:
		cpu_mgr.cpu_tick(_delta)
	if player_id == 4:
		return
	tick_ui(_delta)
	$Line.end =  travel.cur_space.get_closest_path_to_angle(joystick_pos.angle()).global_position if not travel.moving else travel.next_space.global_position
	#queue_redraw()
func _process(delta: float) -> void:
	if player_id == 4:
		return
	var party = Define.party
	if can_tick2():
		tick(delta)
	if can_tick2():
		handle_input(delta)
	if can_travel and can_tick2() and check_section(Party.Section.ACTION):
			if board_control_allowed and not capsule_mgr.throwPresent_mode:
				var is_down = Input.is_action_just_pressed(controls.player+controls.a)
				if not map_mode and is_down and can_start_travel:
					travel.active_travel(delta)
			travel.travel(delta)
var ticked = false
func tick(delta):
	ticked = true
	if event_queue.size() > 0:
		var event = event_queue[0]
		event.tick(delta)
		return
	if cpu_controlled:
		cpu_mgr.cpu_tick(delta)
	capsule_mgr.tick(delta, self)
	process_map_mode()
	if check_section(Party.Section.ACTION):
		if board_control_allowed and not capsule_mgr.throwPresent_mode:
			process_camera(delta)
const CAM_MOVE_SPEED = 15.0
func switch_map_mode():
	if not cpu_controlled and not map_mode and auto_move_camera == true :
			map_mode = not map_mode
			auto_move_camera = not auto_move_camera
	elif not cpu_controlled  and map_mode and auto_move_camera == false:
			map_mode = not map_mode
			auto_move_camera = not auto_move_camera
func process_map_mode():
	if check_section(Party.Section.ACTION):
		if board_control_allowed and not capsule_mgr.throwPresent_mode and can_tick2():
			if Input.is_action_just_pressed(controls.player+controls.y):
				switch_map_mode()
func process_camera(delta):
	if check_section(Party.Section.ACTION):
		if is_instance_valid(camera):
			if map_mode:
				camera.position += Vector3(joystick_pos.x,0,joystick_pos.y) *CAM_MOVE_SPEED*delta
			elif auto_move_camera:
				if camera.position.distance_to(cam_target.position)> CAM_MOVE_SPEED*5:
					camera.global_transform = camera.global_transform.interpolate_with(cam_target.global_transform,0.125)
				else:
					camera.global_transform = Math.move_to(camera.global_transform,cam_target.global_transform,CAM_MOVE_SPEED*delta*60.0)
func ready_ui():
	$Node2D/TextureRect.self_modulate = color
	pass
func tick_ui(_delta):
	$SpacesRolled.text = str(travel.spaces_left_to_move)
	$SpacesRolled.set_visible(check_section(Party.Section.ACTION ))
	$Dice/Label3D.text =str(spaces_rolled)
	$Dice.set_visible(check_section(Party.Section.ROLL) or check_section(Party.Section.FADE_TO_ROLL))
	$Node2D/TextureRect/Star/Label.text = str(int(star_mgr.amount))
	$Node2D/TextureRect/Coin/Label.text = str(int(coin_mgr.amount))
	$Node2D/Space.texture = Define.bmp_blue_space if travel.red_or_blue == 1 else Define.bmp_red_space
var handled_input = false
func handle_input(delta:float):
	handled_input = true
	if event_queue.size() > 0:
		var event = event_queue[0]
		event.handle_player(delta,self)
		return
	if check_section(Party.Section.ROLL):
		if Input.is_action_just_pressed(controls.player+controls.y):
			switch_map_mode()
		var is_down = Input.is_action_just_pressed(controls.player+controls.a)
		if is_down and not map_mode:
			if not rolled_ready:
				$SFX/DicePop.play()
			rolled_ready = true
		if board_control_allowed and not capsule_mgr.throwPresent_mode:
			process_camera(delta)
	joystick_pos = Input.get_vector(controls.player+controls.left,controls.player+controls.right,controls.player+controls.up,controls.player+controls.down)
	if check_section(Party.Section.ACTION):
		if board_control_allowed and can_tick2():
			capsule_mgr.handle_input(delta,self)
		else:
			capsule_mgr.throwPresent_mode = false
	else:
		capsule_mgr.throwPresent_mode = false
#region EventUtilities
func check_section(section:Party.Section):
	return Define.party.party_section == section
func is_ready_to_end():
	return not (not travel.landed or coin_mgr.active or star_mgr.active) and not Define.party.is_waiting()
func can_tick():
	var party = Define.party
	var s = self
	var waiting = party.is_waiting() and not s == party.event_queue[0]
	if waiting:
		__paused = true
		party.event_queue_moved.connect(on_event_queue_moved,CONNECT_ONE_SHOT)
		await sig_unpaused
		__paused = false
func can_tick2():
	var party = Define.party
	var s = self
	var waiting = party.is_waiting()
	return not waiting
var waiting:Dictionary
var event_queue: Array
func wait_for_event_sig(event:Event,sig:Signal):
	event_queue.append(event)
	var nam = str(sig.get_object_id())+":"+sig.get_name()
	waiting[nam] = true
	await sig
	waiting.erase(nam)
	event_queue.erase(event)
func wait_for_event_func(event:Event,callable:Callable,args:Array):
	event_queue.append(event)
	var nam =str(callable.get_object_id())+":"+callable.get_method()
	waiting[nam] = true
	var ret = await callable.callv(args)
	waiting.erase(nam)
	event_queue.erase(event)
	return ret
	
##activates events the most important function
func activate(cond:int,event:Event):
	return await Event.activate_event_chain(self,cond,event)
## is waiting for an event to finish
func is_waiting():
	return waiting.keys().size() > 0
func get_angle_cw_dif(a1: float, a2: float) -> float:
	var fa1 = normalize_angle(a1)
	var fa2 = normalize_angle(a2)
	if fa1 > fa2:
		fa1 -= TAU
	return fa2 - fa1
func get_angle_smallest_dif(a1: float, a2: float) -> float:
	var smallest_dif =  PI - abs(abs(normalize_angle(a1) - normalize_angle(a2)) - PI)
	var cw_dif = normalize_angle(get_angle_cw_dif(a1, a2))
	var ccw_dif = normalize_angle(PI * 2 - cw_dif)
	if abs(cw_dif) <= abs(ccw_dif):
		return cw_dif
	else:
		return ccw_dif
func normalize_angle(a: float) -> float:
	var fa = fmod(a, TAU)
	if fa > PI:
		fa -= TAU
	if fa < -PI:
		fa += TAU
	return fa
@export var roll_deviation = 2
@export var roll_min = 1
@export var roll_max = 12
func roll_reliable(_roll_min=roll_min,_roll_max=roll_max):
	return randi_range(_roll_min, _roll_max)
func roll_unreliable(roll,_roll_deviation=roll_deviation,_roll_min=roll_min,_roll_max=roll_max):
	var deviation =randi_range(-_roll_deviation,_roll_deviation)
	var value = roll-_roll_min
	var length = _roll_max-_roll_min
	if value + deviation > length:
		value = value - _roll_deviation -deviation
	if value + deviation < length:
		value = value + _roll_deviation -deviation
	value = wrapi(value,0,length+1)
	return int(value+_roll_min)
func add_quick_message(time,text):
	var scene = preload("res://Actor/Message/QuickMessage.tscn")
	scene =scene.instantiate()
	scene.time = time
	scene.text = text
	$QuickMessages.add_child(scene)

#endregion
