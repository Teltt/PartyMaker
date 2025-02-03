extends RefCounted
class_name HoldInfo

var held_down: bool = false
var let_go: bool = false
var tried_let_go: bool = false
var allowed: bool = true
var passed_time_start_hold: float = 0.0
var passed_time_let_go: float = 0.0
var passed_time_allowed: float = 0.0
var time_hold_start: float = 0.070
var time_let_go: float = 0.350
var time_hold_allowed: float = 3.15

func try_let_go() -> void:
		if allowed and passed_time_start_hold >= time_hold_start:
			let_go = true
			passed_time_start_hold = 0.0
			passed_time_let_go = 0.0

		held_down = false
		tried_let_go = true

func cancel() -> void:
		allowed = false
		passed_time_allowed = 0.0

func hold_down() -> void:
		held_down = true

func tick_hold(delta_t: float) -> void:
		if not allowed:
			passed_time_allowed += delta_t
			tried_let_go = false
			let_go = false
			if passed_time_allowed >= time_hold_allowed:
				allowed = true
				passed_time_allowed = 0.0
		else:
			passed_time_allowed = 0.0

		if allowed and passed_time_start_hold >= time_hold_start and tried_let_go:
			try_let_go()
			if let_go:
				tried_let_go = false

		if let_go:
			passed_time_let_go += delta_t
			if passed_time_let_go >= time_let_go:
				let_go = false
				passed_time_let_go = 0
		else:
			passed_time_let_go = 0

		if held_down and not let_go:
			passed_time_start_hold += delta_t
		else:
			passed_time_start_hold = 0.0

func get_let_go() -> bool:
		return let_go

func get_held_down() -> bool:
		return held_down

func reset() -> void:
		held_down = false
		let_go = false
		tried_let_go = false
		allowed = true
		passed_time_start_hold = 0.0
		passed_time_let_go = 0.0
		passed_time_allowed = 0.0
