@tool
extends Node2D
@onready var editor:BoardEditor = get_parent().get_parent()

func _draw() -> void:
	
	if Engine.is_editor_hint():
		for s in editor.selected_spaces:
			if s.editor_is_selected:
				draw_dashed_line(editor.camera.unproject_position(s.global_position), editor.mouse_position,Color(1,1,1),2)
