@tool
extends EditorScript
class_name DeleteLinkAction
static func newe():
	if Engine.is_editor_hint():
		var clas = get_clas()
		return clas.new()
	return null
static func get_clas():
	return DeleteLinkAction
# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var selection= get_editor_interface().get_selection().get_selected_nodes()
	for node in selection:
		if node is Space:
			
			for space in node.next_space:
				node.remove_path(node.get_node_or_null(space))
				node.get_node_or_null(space).remove_path(node)
			for space in node.previous_space:
				node.remove_path(node.get_node_or_null(space))
				node.get_node_or_null(space).remove_path(node)
	get_editor_interface().mark_scene_as_unsaved()
