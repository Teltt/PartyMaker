
class_name CapsuleMgr
extends Node3D
@export var player:Player
@export var throw_label:Label
@export var to_throw: int = 0
@onready var throw_effect:MeshInstance3D = $ThrowEffect
@export var inventory: Array[EventInternal]
var thrown_cap: CapsuleBase
var thrown_space: Space = null
var throw_space: Space = null
var next_space: Space = null
var initial_position: Vector3 = Vector3(99999, 99999, 99999)
var final_position: Vector3 = Vector3(-99999, -99999, -99999)
var distance: float = 1.0
var passed_time: float = 0.0
var travel_time: float = 0.75
var fade_time: float = 1.05
var initial_radius: float = 0.0333333
var final_radius: float = 1.0
var capsule_landed: bool = false
var capsule_thrown: bool = false
var throw_active: bool = false
var passed_time_next_selection: float = 0.1500
var throwPresent_mode:bool = false 
var hold:HoldInfo = HoldInfo.new()
func _ready():
	inventory.clear()
	for c in get_children():
		if c is CapsuleBase:
			inventory.push_back(c)
	inventory.resize(3)
		
func add_to_inventory(add:PackedScene):
	var find =inventory.find(null)
	if find > -1:
			inventory[find] = add.instantiate()
			inventory[find].set_visible(false)
func set_to_throw(id: int = -1) -> void:
	if id > -1 and id < 3:
		to_throw = id
	else:
		for i in range(3):
			if is_instance_valid(inventory[i].my_type):
				to_throw = i
				return

func thrown_capsule(initial_pos: Vector3, final_pos: Vector3) -> void:
	
	initial_position = initial_pos
	final_position = final_pos
	distance = (final_pos - initial_pos).length()
	passed_time = 0.0
	thrown_cap = inventory[to_throw]
	throw_active = true
func sort_inventory(a,b):
	if not is_instance_valid(b):
		return true
	return false
func tick(delta_t: float, p: Player) -> void:
	
	if throwPresent_mode and throw_space:
		$ThrowTarget.set_visible(true)
		$ThrowTarget.global_position = throw_space.global_position
		$ThrowTarget.set_instance_shader_parameter("color",Vector4(p.color.r,p.color.g,p.color.b,0.45))
	else:
		$ThrowTarget.set_visible(false)
	for i in inventory:
		if is_instance_valid(i) and not i.get_parent() == self:
			add_child(i)
	for c in get_children():
		if c is CapsuleBase and c not in inventory:
			remove_child(c)
	var party = Define.party
	if not is_instance_valid(inventory[to_throw]):
		to_throw = 0 if inventory.count(null) >= 3 else to_throw
	inventory.sort_custom(sort_inventory)
	if not is_instance_valid(self.throw_space):
		self.throw_space = p.travel.cur_space
		self.next_space = p.travel.cur_space
	if throw_active:
		passed_time += delta_t
		if passed_time > travel_time + fade_time:
			throw_active = false
			capsule_landed = false

	if not capsule_thrown and throwPresent_mode:
		passed_time_next_selection += delta_t
		if passed_time_next_selection >= 0.35:
			passed_time_next_selection = 0
			var pos = p.travel.cur_space.position
			if pos.distance_to(next_space.position) < 1.6 * 9:
				throw_space = next_space
		var pos = throw_space.position
		if pos.distance_to(p.position) >= 1.6 * 9:
			throw_space = p.travel.cur_space
	if throw_active:
		passed_time += delta_t
		var v4 = Vector4(1.0,1.0,1.0, max(1.0 - (passed_time - travel_time) * 2,0.0))
		throw_effect.set_instance_shader_parameter("albedo",v4)
		throw_effect.set_visible(v4.w>0)
		if passed_time <= travel_time and not capsule_landed:
			#thrown_cap.modulate.a = min(passed_time,travel_time)/travel_time
			throw_effect.set_visible(true)
			var second_multiplier = max(0.0, passed_time /( travel_time))
			
			var ss =initial_position+(initial_position.direction_to(final_position) * second_multiplier * distance)
			throw_effect.position = ss
			thrown_cap.position = ss
			if throw_effect.position != final_position:
				throw_effect.look_at(final_position)
			throw_effect.scale = Vector3.ONE * remap(passed_time,0,travel_time,initial_radius,final_radius)*0.5
		if passed_time > travel_time and not capsule_landed:
			capsule_landed = true
			thrown_cap.set_visible(true)
			thrown_cap.visible =(true)
			throw_effect.set_instance_shader_parameter("albedo",Vector4(1.0,1.0,1.0, 1.0))
			thrown_cap.attach(p,throw_space)
		if passed_time > travel_time + fade_time:
			throw_effect.set_visible(false)
			throw_active = false
			capsule_landed = false
	
	
	#queue_redraw()
	#
#func _draw() -> void:
	#if throw_active:
		#if passed_time <= travel_time:
			#var second_multiplier = max(0.0, passed_time /( travel_time))
			#var cur_radius = second_multiplier * final_radius
			#var first_multiplier = max(0.0, passed_time /( travel_time) * distance - cur_radius * 3.14)
			#var ff =  (unit_vector * first_multiplier)
			#var ss =(unit_vector * second_multiplier * distance)
			#var pa = perp_vector * cur_radius
			#draw_colored_polygon([ff, ss + pa, ss - pa], Color(1, 1, 1))
			#draw_circle(ss, cur_radius, Color(1, 1, 1))
		#elif passed_time > travel_time:
			#var second_multiplier = max(0.0, min(passed_time,travel_time) / ( travel_time))
			#var cur_radius = second_multiplier * final_radius
			#var first_multiplier =  max(0.0, distance - final_radius)
			#var ff =  (unit_vector * first_multiplier)
			#var ss =(unit_vector * second_multiplier)
			#ss = (ss-ff)/7*-1+ff
			#
			#var pa = perp_vector * cur_radius
			#draw_colored_polygon([ff, ss + pa, ss - pa], Color(1, 1, 1))
			#draw_circle(ss, cur_radius, Color(1, 1, 1))

func to_power(input: float, power: int) -> float:
	var output = input
	for i in range(power):
		output *= input
	return output

func handle_input(delta_t: float,player:Player):
		var p = player
		var a_pressed = Input.is_action_just_pressed(p.controls.player+p.controls.a)
		var b_pressed = Input.is_action_just_pressed(p.controls.player+p.controls.b)
		var l_pressed = Input.is_action_just_pressed(p.controls.player+p.controls.l)
		var r_pressed = Input.is_action_just_pressed(p.controls.player+p.controls.r)
		if not is_instance_valid(self.throw_space):
			self.throw_space = p.travel.cur_space
			self.next_space = p.travel.cur_space
		if l_pressed:
			to_throw = (to_throw -1)
			if to_throw < 0:
				to_throw = 2
		if r_pressed:
			to_throw = abs((to_throw +1) % 3)
		
		if not p.travel.moving and not p.map_mode and p.board_control_allowed:
			if throwPresent_mode and b_pressed:
				throwPresent_mode = false
				throw_label.text = ""
			elif not throwPresent_mode and b_pressed:
				throw_label.text = "throwing"
				throw_space = p.travel.cur_space
				next_space = throw_space
				throwPresent_mode = true
			if throwPresent_mode and not p.cpu_controlled:
				if  is_instance_valid(p.camera):
					p.camera.position =p.camera.position.lerp(throw_space.position+p.cam_target.global_position-p.global_position,0.25)
			if throwPresent_mode and a_pressed and not self.capsule_thrown:
				if self.to_throw >= 0 and self.to_throw < 3:
					var throw_me = self.inventory[self.to_throw]
					if  is_instance_valid(throw_me):
						self.throwPresent_mode = false
						self.capsule_thrown = true
						var revert = await p.activate(Define.ACTIVATION.ACT_INIT_PRESENT,throw_me)
						if not revert:
							self.thrown_cap = throw_me
							self.thrown_capsule(p.position, throw_space.position)
					self.inventory[self.to_throw] = null
			
			var joystick_dist = p.joystick_pos.distance_to(Vector2(0, 0))
			
			if throwPresent_mode and not self.capsule_thrown and joystick_dist > 0.2:
				var angle = p.joystick_pos.angle()
				var closest = null
				var diff_of_closest = TAU
				for i in throw_space.next_space.size():
					var throw_next = throw_space.next_space[i]
					var vector = throw_next.position - throw_space.position
					var to_angle = Vector2(vector.x,vector.z).angle()
					var diff = abs(angle_difference(angle, to_angle))
					if diff < diff_of_closest:
						closest = throw_next
						diff_of_closest = diff
				for i in throw_space.previous_space.size():
					var throw_prev = throw_space.previous_space[i]
					var vector = throw_prev.position - throw_space.position
					var to_angle =Vector2(vector.x,vector.z).angle()
					var diff = abs(angle_difference(angle, to_angle))
					if diff < diff_of_closest:
						closest = throw_prev
						diff_of_closest = diff
				if  is_instance_valid(closest):
					self.next_space = closest




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
