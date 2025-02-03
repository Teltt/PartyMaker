extends Node3D
class_name EventInternal
class Result:
	var revert:bool = false
	var skip_siblings:bool = false
	var skip_parent:bool = false
	func _init(_revert=false,_skip_siblings=false,_skip_parent = false) -> void:
		revert = _revert
		skip_siblings = _skip_siblings
		skip_parent = _skip_parent
static var GO_NO_SKIP = Result.new(false,false,false)
static var GO_SKIP_SIB = Result.new(false,true,false)
static var GO_SKIP_PARENT = Result.new(false,false,true)
static var GO_SKIP_RELATIVE = Result.new(false,true,true)
static var REVERT_NO_SKIP = Result.new(true,false,false)
static var REVERT_SKIP_SIB = Result.new(true,true,false)
static var REVERT_SKIP_PARENT = Result.new(true,false,true)
static var REVERT_SKIP_RELATIVE = Result.new(true,true,true)
@export_storage var after_children:bool = false
@export_storage var before_parent:bool = false
@export_storage var event_name:String = "Event"
@export var params:EventParams:
	set(val):
		if not is_node_ready():
			await  ready
		params = val
		if is_instance_valid(params) and not (Engine.is_editor_hint() or not Define.party.loading):
			after_children = params.after_children
			before_parent = params.before_parent
			event_name = params.event_name
		

signal reorganize
@export_storage var time_since_activation: float = 0.0
@export_storage var frames_ticked: int = 0
var all_children = []
var order = []
var highest_parent:EventInternal = null
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	top_level = true
	add_to_group("event")
	reorganize.connect(func():
	
		var party = Define.party
		remove_from_group("event")
		if is_queued_for_deletion():
			return
		var new_highest_parent = get_highest_parent()
		if not is_instance_valid(highest_parent):
			highest_parent = new_highest_parent
			highest_parent.get_all_children()
		else:
			highest_parent.get_all_children()
			highest_parent = new_highest_parent
			highest_parent.get_all_children()
		if not highest_parent.is_in_group("event") and is_instance_valid(highest_parent):
			highest_parent.add_to_group("event")
		)
	child_order_changed.connect(func():
		reorganize.emit()
		)	
	script_changed.connect(func():
		reorganize.emit()
		)
	tree_exiting.connect(func():
		reorganize.emit()
		)
	tree_exited.connect(func():
		reorganize.emit()
		)
	reorganize.emit()
func get_highest_parent():
	var highest_parent = self
	while true:
		var new_highest_parent = highest_parent.get_parent()
		if is_instance_valid(new_highest_parent) and not new_highest_parent == null and new_highest_parent is Event:
			highest_parent = new_highest_parent
			continue
		break
	return highest_parent
func get_all_children():
	all_children = [self]
	
	var party = Define.party
	for child in get_children():
		if is_instance_valid(child) and child is EventInternal:
			all_children.append_array(child.get_all_children())
	if highest_parent == self:
		get_activation_order(all_children)
	return all_children
func get_activation_order(chil):
	var traversed = chil.duplicate()
	order = chil.duplicate()
	while traversed.size() > 0:
		var cur_event = traversed.pop_front()

		var cur_parent = cur_event.get_parent()
		if cur_parent is EventInternal:
			var parent_event = cur_parent
			var cur_event_order = order.find(cur_event)
			if cur_event.before_parent or parent_event.after_children:
				if cur_event_order+1 < order.size():
					order.erase(parent_event)
					order.insert(cur_event_order+1,parent_event)
				else:
					order.push_back(parent_event)
				print(order)
			else:
				if cur_event_order >= 0 and cur_event_order < order.size():
					order.erase(parent_event)
					order.insert(cur_event_order,parent_event)
				else:
					order.push_front(parent_event)
			
	for child in all_children:
		if is_instance_valid(child) and child is EventInternal:
			child.order = (order)
static func activate_event_chain(player:Player,act_cond:int,activated:EventInternal):
	var revert_operations = false
	var party = Define.party
	var temp_order = activated.order.duplicate()
	while not temp_order.is_empty():
		var event:Event = temp_order.pop_front()
		if is_instance_valid(event):
			var result:Result = await player.wait_for_event_func(event,event.activate,[act_cond, player]) 
			revert_operations = revert_operations or result.revert
			for p in party.players:
				p.cpu_mgr.cpu_activate(act_cond,p,event)
			if result.skip_parent or result.skip_siblings:
				temp_order = temp_order.filter(func(ele:Event):
					return not ((ele.is_ancestor_of(event) and result.skip_parent) or (event in ele.all_children and result.skip_siblings)))
	return revert_operations
@export_storage var ticked = false
@export_storage var handled_player:Dictionary
@export_storage var active: bool = false
signal sig_unpaused 
signal sig_paused
@export_storage var paused: bool = false:
	set(val):
		var prev = paused
		paused = val
		set_process(not paused)
		#set_physics_process(not paused)
		set_process_input(not paused)
		if not val and val != prev:
			sig_unpaused.emit()
		if val and val != prev:
			sig_paused.emit()
			
func is_active():
	for event in order:
		if is_instance_valid(event) and event is EventInternal:
			if event.active:
				return true
	return false
func reset_tick():
	for event in order:
		if is_instance_valid(event) and event is EventInternal:
			event.ticked = false
			event.handled_player.clear()

func can_tick():
	var party = Define.party
	var s = self
	var waiting = party.is_waiting()
	if waiting and not s == party.event_queue[0]:
		paused = true
		party.event_queue_moved.connect(on_event_queue_moved,CONNECT_ONE_SHOT)
		await sig_unpaused
		
func on_event_queue_moved():
	var party = Define.party
	var s = self
	var waiting = party.is_waiting()
	if not waiting or s == party.event_queue[0]:
		paused = false
		return
	party.event_queue_moved.connect(on_event_queue_moved,CONNECT_ONE_SHOT)
	await sig_unpaused
func _process(delta: float) -> void:
	#queue_redraw()
	if Engine.is_editor_hint():
		paused = false
		return
	var party = Define.party
	var s = self
	await  can_tick()
	paused = true
	await party.event_tick
	paused = false
	await  can_tick()
	delta = get_process_delta_time()
	if s is Event:
		if not s.ticked:
			s.tick(delta)
		await  can_tick()
		paused = true
		await party.event_handle_player
		paused = false
		await  can_tick()
		delta = get_process_delta_time()
		for p in party.players:
			if not p in s.handled_player:
				s.handle_player(delta,p)
				await  can_tick()
				delta = get_process_delta_time()
