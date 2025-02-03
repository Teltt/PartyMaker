extends Resource
class_name MoveMgrStruct
var vars: Dictionary= {}
var stage: int = -1
var stage_amount: int = -1
var dest_pos: Vector3 = Vector3(99999.0, 99999.0,99999.0)
var dest_drawsize: Vector3= Vector3(-1, -1,-1)
var dest_angle: float = 99999.0
var dest_space: Space = null
var active: bool = false
var deactivate: bool = false
var land_when_over: bool = false
var basis: int = Define.MoveEventBases.MO_BA_ARRIVAL
var initial_distance: float = 1.0
var move_speed: float = 85.0
var angle_move_speed: float = 10.0
var scale_speed: Vector3 = Vector3(1, 1,1)
var time_to_pass: float = 1.0
var passed_time_since_stage_change: float = 0.0
var passed_time: float = 0.0

func action_movement_logic(delta_t: float,player:Player) -> void:
		var p = player

		if self.deactivate:
			if self.dest_pos != Vector3(99999.0, 99999.0,99999.0):
				p.position = self.dest_pos

			if self.dest_angle != 99999.0:
				p.rotation = self.dest_angle
			else:
				p.rotation = 0.0

			if self.dest_drawsize != Vector3(-1, -1,-1):
				p.scale = self.dest_drawsize
			else:
				p.scale = Vector2(1, 1)

			if is_instance_valid(self.dest_space):
				var prev_cur_space = p.cur_space
				var prev_prev_space = p.prev_space
				var prev_next_space = p.next_space
				var prev_moving = p.moving
				p.prev_space = p.cur_space
				p.cur_space = self.dest_space
				p.next_space = p.cur_space.get_default_path()
				p.moving = false
				if p.cur_space.is_landable() and p.spaces_left_to_move > 0 and not self.land_when_over:
					p.spaces_left_to_move -= 1

				if p.spaces_left_to_move <= 0 or self.land_when_over:
					if p.cur_space.is_landable():
						var revert  = await p.activate(Define.ACTIVATION.ACT_EVENT_LAND,p.cur_space)
						if not revert:
							p.spaces_left_to_move = 0
							p.landed = true
						else:
							p.spaces_left_to_move += 1
							p.prev_space = prev_prev_space
							p.next_space = prev_next_space
							p.cur_space = prev_cur_space
							p.moving = prev_moving

						p.land_events_activated += 1

					else:
						var revert  = await p.activate(Define.ACTIVATION.ACT_EVENT_PASS,p.cur_space)
						if not revert:
							p.spaces_left_to_move = 1
						else:
							p.spaces_left_to_move += 1
							p.prev_space = prev_prev_space
							p.next_space = prev_next_space
							p.cur_space = prev_cur_space
							p.moving = prev_moving
						p.pass_events_activated += 1
				else:
					var revert = await p.activate(Define.ACTIVATION.ACT_EVENT_PASS,p.cur_space)
					if revert:
						p.spaces_left_to_move += 1
						p.prev_space = prev_prev_space
						p.next_space = prev_next_space
						p.cur_space = prev_cur_space
						p.moving = prev_moving
					p.pass_events_activated += 1

				p.position = p.cur_space.position
			self.active = false

		if self.active:
			#do nothing :) events should handle this anyway
			pass
		if not self.active:
			self.stage = -1
			self.stage_amount = -1
			self.dest_pos = Vector3(99999.0, 99999.0,99999.0)
			self.dest_drawsize = Vector3(-1, -1,-1)
			self.dest_angle = 99999.0
			self.dest_space = null
			self.active = false
			self.deactivate = false
			self.basis = Define.MoveEventBases.MO_BA_ARRIVAL
			self.initial_distance = 1.0
			self.move_speed = 45.0
			self.time_to_pass = 1.0
			self.passed_time = 0.0
			self.passed_time_since_stage_change = 0.0
