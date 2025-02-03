@tool
extends Event
class_name Space

## Tells the game whether to move on to the minigame if false
@export var space_params:SpaceParams:
	set(val):
		if not is_node_ready():
			await  ready
		space_params = val
		if is_instance_valid(space_params) and (Engine.is_editor_hint() or not Define.party.loading):
			blue = space_params.blue
			can_land = space_params.can_land
			must_go = space_params.must_go
			if is_instance_valid(space_params.event_params) and not is_instance_valid(params):
				params = space_params.event_params
@export_storage var blue: bool = true
@export_storage var can_land: bool = true
func is_landable():
	return not must_go and can_land
@export_storage var must_go:bool = false
var id: int = -1
@export var next_space: Array[Space] = []
@export var previous_space: Array[Space]= []
var capsule:CapsuleBase = null:
	set(val):
		capsule = val
		if not Engine.is_editor_hint():
			for c in get_children():
				if c is CapsuleBase and c != val and val != null:
					if c.space_attach:
						c.finish()
			if not val in get_children() and val != null:
				add_child(val)
			#val.set_owner(self)

var editor_is_selected = false
var editor_mouse_position = Vector2(0,0)

func _ready() -> void:
	super()
	
	if not Engine.is_editor_hint():
		if capsule == null:
			for c in get_children():
				if c is CapsuleBase:
					if c.space_attach:
						capsule = c
## Resets Variables to default
func reset() -> void:
	super()

## Deletes this Space, Severs connections too
## Activates the capsules finish event if it exists
func finish() -> void:
		if is_instance_valid(capsule):
			await capsule.my_player.wait_for_event_func(capsule,capsule.activate,[Define.ACTIVATION.ACT_FINISH,capsule.my_player,self])
			Define.party.capsules[capsule.my_player.player_id].erase(capsule)
			capsule.queue_free()
		super()
	
## ABOUT THE FUNCTION
## When an Event like Landing or Passing
## happens it goes here to be processed initially
## any persistent logic should be handled in tick or tick player
## ABOUT THE RETURN VALUE
## returns a value to determine whether or not 
## code that changes the state is skipped 
## return false in order to not skip
func activate(activation_type:int, pl: Player) -> Result:
	super(activation_type,pl)
	return GO_NO_SKIP


## Do any persistent logic here
## ticks whether or not active is true
func tick(delta_t: float) -> void:
	super(delta_t)

## A persistent function that handles each player
## Handle Player by Player Inputs here
## Functionally it's just a second tick function that operates on each Player
func handle_player(delta_t: float,player: Player) -> void:
	super(delta_t,player)
	pass
#func save(save_dictionary:Dictionary = {}) -> Dictionary:
	#save_dictionary = super(save_dictionary)
	#save_dictionary["blue"] = blue
	#save_dictionary["can_land"] = can_land
	#save_dictionary["previous_space"] = previous_space
	#save_dictionary["next_space"] = next_space
	#return save_dictionary
	#
	#
#func load_me(save_dictionary:Dictionary) -> void:
	#pass
## Do drawing here and only here
func _draw() -> void:
	super()
	if Engine.is_editor_hint():
		#if editor_is_selected:
		#	draw_dashed_line(Vector2.ZERO, editor_mouse_position,Color(1,1,1),2)
		pass
	pass




## Used to Modify Connections at Runtime
func set_path(connect_to: Space, set_previous: bool = true) -> void:
	next_space = next_space.duplicate()
	connect_to.previous_space = connect_to.previous_space.duplicate()
	next_space.push_back( connect_to)
	connect_to.previous_space.push_back((self))
func remove_path(remove_from:Space):
	
	next_space = next_space.duplicate()
	remove_from.previous_space = remove_from.previous_space.duplicate()
	if is_instance_valid(remove_from):
		next_space = next_space.filter(func(element):
			return (element) != remove_from
		)
	if is_instance_valid(remove_from):
		
		remove_from.previous_space = remove_from.previous_space.filter(func(element):
			return remove_from.element != self 
			)
# In your Space class or a suitable parent node/script:

func is_linked( space2: Space) -> bool:
	var space1 = self
	for path in space1.next_space:
		if path == space2:
			return true

	for path in space2.previous_space:
		if path == space1:
			return true

	return false

## Don't mess with this. It's a utility function
func get_default_path() -> Space:
	for i in next_space.size():
		return next_space[i]
	return self

## Don't mess with this. It's a utility function
func get_closest_path_to_angle(angle: float):
	var closest = next_space[0]
	var diff_of_closest = TAU
	for i in next_space.size():
		var next = next_space[i]
		if  is_instance_valid(next):
			var vector = next.position - position
			var to_angle = Vector2(vector.x,vector.z).angle()
			var diff = abs(get_angle_smallest_dif(angle, to_angle))
			if diff < diff_of_closest:
				closest = next
				diff_of_closest = diff
	return closest

## Don't mess with this. It's a necessary function
func _process(delta):
	super(delta)
	#if Engine.is_editor_hint():
		#editor_mouse_position = get_local_mouse_position()
	#queue_redraw()

#don't mess with this it's a nescessary function
func _exit_tree():
	if is_queued_for_deletion():
		var board = find_parent("Board")
		if is_instance_valid(board):
			for space in next_space:
				remove_path(space)
				space.remove_path(self)
			for space in previous_space:
				remove_path(space)
				space.remove_path(self)
				board.update_spaces()
				board.deselect_all()

## THESE ARE UTILITY FUNCTIONS DO NOT MESS WITH THEM
func get_angle_cw_dif(a1: float, a2: float) -> float:
	var fa1 = normalize_angle(a1)
	var fa2 = normalize_angle(a2)
	if fa1 > fa2:
		fa1 -= TAU
	return fa2 - fa1

func get_angle_smallest_dif(a1: float, a2: float) -> float:
	var smallest_dif =  PI - abs(abs(normalize_angle(a1) - normalize_angle(a2)) - PI)
	var cw_dif = normalize_angle(get_angle_cw_dif(a1, a2))
	var ccw_dif = normalize_angle(PI * 2 - cw_dif)
	
	if abs(cw_dif) <= abs(ccw_dif):
		return cw_dif
	else:
		return ccw_dif
func normalize_angle(a: float) -> float:
	var fa = fmod(a, TAU)
	if fa > PI:
		fa -= TAU
	if fa < -PI:
		fa += TAU
	return fa
