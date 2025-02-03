extends Node
class_name Travel
@export var p:Player
@export var node3d:Node3D
@export var pass_sfx:AudioStreamPlayer
@export var land_sfx:AudioStreamPlayer
@export_storage var moving: bool = false
@export_storage var entered: bool = false
@export_storage var passed:bool = true
@export_storage var red_or_blue: int = -1
@export_storage var landed: bool = false
@export_storage var spaces_left_to_move: int = 0
@export_storage var pass_events_activated: int = 0
@export_storage var land_events_activated: int = 0
@export_storage var enter_events_activated: int = 0
@export_storage var leave_events_activated: int = 0
@export_storage var speed: float = 1.1666667
@export_group("Private from Editor")
@export var next_space: Space
@export var cur_space: Space
@export var prev_space: Space
func active_travel(delta):
	if (spaces_left_to_move > 0): 
		if not moving:
			var revert  = await p.activate(Define.ACTIVATION.ACT_LEAVE,cur_space)
			if not revert:
				speed = 6.0
				entered = false
				moving = true
				var angle = p.joystick_pos.angle()
				next_space = cur_space.get_closest_path_to_angle(angle)
			leave_events_activated += 1
		elif moving:
			speed =move_toward(speed,11,delta*60*3.0)
		
func travel(delta):
	if moving:
		var next_pos = next_space.global_position
		var distance = node3d.global_position.distance_to(next_pos)
		if distance <= 0:
			passed = false
		else:
			node3d.global_position = node3d.global_position.move_toward(next_space.global_position,speed*delta)
		distance = node3d.global_position.distance_to(next_pos)
		var enter_event_happened = false
		if distance< 0.5 and not entered and passed:
			await p.activate(Define.ACTIVATION.ACT_ENTER,cur_space)
			entered = true
			passed = false
			enter_event_happened = true
			enter_events_activated += 1
		if not passed and entered and moving and distance <= speed * delta and not enter_event_happened:
			prev_space = cur_space
			cur_space = next_space
			next_space = cur_space.get_default_path()
			if not cur_space.must_go:
				moving = false
				passed = true
				if not landed:
					await p.activate(Define.ACTIVATION.ACT_PASS,cur_space)
					pass_sfx.play()
					pass_events_activated += 1
			else:
				var angle = p.joystick_pos.angle()
				next_space = cur_space.get_closest_path_to_angle(angle)
				if not landed:
					passed = true
					await p.activate(Define.ACTIVATION.ACT_PASS,cur_space)
					pass_sfx.play()
					pass_events_activated += 1
			if cur_space.is_landable() and spaces_left_to_move > 0:
				spaces_left_to_move -= 1
			if spaces_left_to_move <= 0:
				var revert = await  p.activate(Define.ACTIVATION.ACT_LAND,cur_space)
				if not revert:
					passed = true
					land_sfx.play()
					landed = true
					red_or_blue = 1 if cur_space.blue == true else 0
				else:
					spaces_left_to_move += 1
				land_events_activated += 1
func force_move_to_next_space():
	if cur_space:
		var next_space = cur_space.get_default_path()
		if next_space:
			next_space = next_space
			moving = true
			entered = false
			passed = true
			p.activate(Define.ACTIVATION.ACT_EVENT_PASS, cur_space)
func immediate_land(active_pass = true):
	entered = false
	next_space = cur_space.get_default_path()
	if cur_space.is_landable():
		var revert = await p.activate(Define.ACTIVATION.ACT_LAND,cur_space)
		if not revert:
			spaces_left_to_move = 0
			landed = true
		land_events_activated += 1
	else:
		if active_pass:
			var revert = await p.activate(Define.ACTIVATION.ACT_PASS,cur_space)
			if not revert:
				spaces_left_to_move = 1
			pass_events_activated += 1
		node3d.global_position = cur_space.global_position
