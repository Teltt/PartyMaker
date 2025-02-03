extends Camera3D


# Called when the node enters the scene tree for the first time.
func _ready():
	Define.event_cam = self
	var my_viewport = get_parent()
	my_viewport.world_2d = %SubViewport.world_2d
	my_viewport.world_3d = %SubViewport.world_3d

	pass # Replace with function body.
