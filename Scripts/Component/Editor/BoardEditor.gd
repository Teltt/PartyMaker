@tool
extends Node3D
class_name BoardEditor
var mouse_position:Vector2
var shift_space_pressed:bool = false
var spaces = []
var selected_spaces = []
var awaiting = false
var camera:Camera3D
@export var edit_mode_on = false
@export var remove_link_button=false:
	set(value):
		remove_link_button = value
		if Engine.is_editor_hint() and remove_link_button == true:
			for space:Space in spaces:
				space.next_space = []
				space.previous_space=[]
			remove_link_button = false
func _ready():
	
	if Engine.is_editor_hint():
		camera = get_window().get_camera_3d()
		update_spaces()

func update_spaces():
	spaces.clear()
	for space in $Spaces.get_children():
		if space is Space and not space.is_queued_for_deletion():
			spaces.append(space)

func _process(delta):
	if awaiting:
		return
	if Engine.is_editor_hint() and edit_mode_on:
		update_spaces()
		handle_input()
	else:
		deselect_all()

func handle_input():
	var selected = false
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		selected =select_space()
		awaiting = true
		await get_tree().create_timer(0.1).timeout
	selected_spaces = EditorInterface.get_selection().get_selected_nodes().filter(
	func(ele):
		return ele is Space)
	if selected_spaces.size() > 2:
		selected_spaces.resize(2)
	if selected_spaces.size() == 2 and (shift_space_pressed or Input.is_key_pressed(KEY_SHIFT)):
			if Input.is_key_pressed(KEY_ALT):
				delete_link(selected_spaces[0], selected_spaces[1])
			else:
				create_link(selected_spaces[0], selected_spaces[1])
	
	
	awaiting = false

func select_space():
	if selected_spaces.size() >= 2:
		return false
	return false

func create_link(space1, space2):
	deselect_all()
	if Engine.is_editor_hint():
		if space1 == space2 or link_exists(space1, space2):
			return
		space1.set_path(space2)
	
func delete_link(space1, space2):
	space1.remove_path(space2)
	space2.remove_path(space1)
	deselect_all()

func link_exists(space1, space2):
	return space1.is_linked(space2)

func deselect_all():
	for space in selected_spaces:
		space.editor_is_selected = false
	selected_spaces.clear()
	if Engine.is_editor_hint():
		if edit_mode_on:
			EditorInterface.get_selection().clear()
func _input(event):
	if Engine.is_editor_hint():
		if event is InputEventMouseMotion:
			mouse_position = event.global_position
		if event is InputEventKey:
			shift_space_pressed = event.keycode == KEY_SHIFT and event.is_pressed()

func _draw():
	if Engine.is_editor_hint():
		var spaces = $Spaces.get_children()
		for space in spaces:
			if space is Space and not space.is_queued_for_deletion():
				for next in space.previous_space:
					var next_space = space.get_node_or_null(next)
					if not is_instance_valid(next_space):
						continue
					var normal = (space.position-next_space.position).normalized()
					var length = max(1.0,space.position.distance_to(next_space.position))
					
					var normal2 = normal.rotated(PI/2)*20.0
					call("draw_line",space.position+normal2-normal*length/2-normal*20,next_space.position+normal*length/2+normal*20,Color(0.9,0.4,0.9),3.0)
					
					call("draw_line",space.position-normal2-normal*length/2-normal*20,next_space.position+normal*length/2+normal*20,Color(0.9,0.4,0.9),3.0)
				for next in space.next_space:
					var next_space = space.get_node_or_null(next)
					if not is_instance_valid(next_space):
						continue
					var normal = -(space.position-next_space.position).normalized()
					var normal2 = normal.rotated(PI/2)*20.0
					call("draw_line",space.position,next_space.position,Color(0.3,0.8,0.9),3.0)
		pass
