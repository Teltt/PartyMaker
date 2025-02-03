extends Node2D
@export var id = 0
@export var player:Player

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
	pass

func _draw() -> void:
	var p = player
	if is_instance_valid(p.capsule_mgr.inventory[id]):
		if p.capsule_mgr.to_throw == id:
			draw_circle(Vector2.ZERO, 18,Color(0.5,0.5,0.5))
		draw_contained(p.capsule_mgr.inventory[id],
			Vector2.ZERO, 16, 0.0)
func draw_filled_pieslice(pos: Vector2, radius: float, start_angle: float, end_angle: float, color: Color):
	var num_segments = 12 
	var angle_range = end_angle - start_angle
	var angle_per_segment = angle_range / num_segments
	var vertices = []
	vertices.append(pos)
	for i in range(num_segments + 1):
		var angle = start_angle + i * angle_per_segment
		var vertex = Vector2(radius * cos(angle), radius * sin(angle)) + pos
		vertices.append(vertex)
	draw_colored_polygon(vertices, color)
func draw_contained(type, pos: Vector2, radius: float, angle: float):
	draw_filled_pieslice(pos, radius, angle + PI, PI, Color(195, 195, 250, 0.75))
	if is_instance_valid(type.icon):
		draw_texture_rect(type.icon,Rect2(pos-Vector2(16,20),Vector2(32,32)),false,Color.BEIGE)
	draw_filled_pieslice(pos, radius, angle, PI, Color(255,255,255,255))
	
