extends Node

@export var visual_instances:Array[VisualInstance3D]
@export var canvas_items:Array[CanvasItem]
@export var players:Array[Player]

func _ready() -> void:
	set_players(players)
func set_players(_players:Array[Player]):
	players = _players
	set_visual_instances(visual_instances)
	set_canvas_items(canvas_items)
func set_canvas_items(_vis_instances:Array[CanvasItem]):
	for v in canvas_items:
		v.set_visibility_layer_bit(1-1,true)
		v.set_visibility_layer_bit(2-1,true)
		v.set_visibility_layer_bit(3-1,true)
		v.set_visibility_layer_bit(4-1,true)
		v.set_visibility_layer_bit(5-1,true)
		v.set_visibility_layer_bit(6-1,true)
	canvas_items=_vis_instances
	var four_exists = false
	for v in _vis_instances:
		v.set_visibility_layer_bit(1-1,false)
		v.set_visibility_layer_bit(2-1,false)
		v.set_visibility_layer_bit(3-1,false)
		v.set_visibility_layer_bit(4-1,false)
		v.set_visibility_layer_bit(5-1,false)
		v.set_visibility_layer_bit(6-1,false)
		for p in players:
			v.set_visibility_layer_bit(p.player_id+1,true)
		
func set_visual_instances(_vis_instances:Array[VisualInstance3D]):
	for v in visual_instances:
		v.set_layer_mask_value(1,true)
		v.set_layer_mask_value(2,true)
		v.set_layer_mask_value(3,true)
		v.set_layer_mask_value(4,true)
		v.set_layer_mask_value(5,true)
		v.set_layer_mask_value(6,true)
	visual_instances=_vis_instances
	var four_exists = false
	for v in _vis_instances:
		v.set_layer_mask_value(1,false)
		v.set_layer_mask_value(2,false)
		v.set_layer_mask_value(3,false)
		v.set_layer_mask_value(4,false)
		v.set_layer_mask_value(5,false)
		v.set_layer_mask_value(6,false)
		for p in players:
			v.set_layer_mask_value(p.player_id+2,true)
		
