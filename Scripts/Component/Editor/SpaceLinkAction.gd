@tool
extends EditorScript
class_name SpaceLinkAction
static func newe():
	if Engine.is_editor_hint():
		var clas = get_clas()
		return clas.new()
	return null
static func get_clas():
	return SpaceLinkAction
var space1
var space2
var board_editor
# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	if is_instance_valid(board_editor) and is_instance_valid(space1) and is_instance_valid(space2):
		if space1 == space2 or board_editor.link_exists(space1, space2):
			return
		space1.set_path(space2)
		get_editor_interface().mark_scene_as_unsaved()
	pass
