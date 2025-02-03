extends Node3D

@export var end:Vector3
@onready var path :CSGPolygon3D= $Line
@onready var tip = $Tip


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var len =  path.global_position.distance_to(end)
	if global_position != end:
		set_visible(true)
		look_at_from_position(global_position,(end))
		path.scale.z  = len
		tip.global_position = end
	else:
		set_visible(false)
