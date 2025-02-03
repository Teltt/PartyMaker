extends Camera3D

@export_range(0,3) var player_id = 0
@onready var map_box = get_parent().get_parent().get_node("Control/NinePatchRect")
var really_ready = false
# Called when the node enters the scene tree for the first time.
func _ready():
	var my_viewport = get_parent()
	my_viewport.world_2d = %SubViewport.world_2d
	my_viewport.world_3d = %SubViewport.world_3d

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var my_player = Define.party.players[player_id]
	my_player.camera = self
	if not really_ready:
		global_transform = my_player.cam_target.global_transform
		really_ready = true
	pass
