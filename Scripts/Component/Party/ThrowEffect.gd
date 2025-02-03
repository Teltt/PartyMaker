extends Node2D
var distance: float = 1.0
var passed_time: float = 0.0
var travel_time: float = 0.75
var fade_time: float = 0.5
var initial_radius: float = 1.0
var final_radius: float = 30.0
var lag_distance: float = 5.0
var landed: bool = false
var thrown: bool = false
var active: bool = false
var initial_position: Vector3 = Vector3(99999, 99999,99999)
var final_position: Vector3 = Vector3(-99999, -99999,-99999)
var unit_vector: Vector3= Vector3(99999, 99999,99999)
var perp_vector: Vector3 = Vector3(99999, 99999,99999)

func _ready():
		pass
