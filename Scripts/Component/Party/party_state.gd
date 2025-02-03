#region New
extends Node2D
class_name Party
enum Section {
	FADE_TO_ROLL=0,
	ROLL=1,
	FADE_TO_ACTION=2,
	ACTION=3,
	FADE_TO_MINIGAME=4,
	MINIGAME=5,
	FADE_TO_RESULTS=6,
	RESULTS=7,
	FADE_TO_FINAL_RESULTS=8,
	FINAL_RESULTS=9,
	END_OF_TURN=10,
	
	OPEN_GAME=21,
	LOAD_GAME=22,
	NEW_GAME=23,
}
enum MinigameType {
	FREE_FOR_ALL,
	n1v3,
	n2v2,
	n3v1,
	WINNER_TAKE_ALL,
}
@onready var players =  $Board/Players.get_children()
@onready var sfx =  $Board/SFX
@onready var space_parent = $Board/Spaces

@export_storage var time_passed: float
@export_storage var time_since_reroll: float = 0.0
@export_storage var time_since_section_change: float = 0.0
@export_storage var party_section: Section = Section.OPEN_GAME
@export_storage var turns_so_far: Array = []
@export_storage var cur_turn: int = 0
@export_storage var turns_to_play: int = 20
@export_storage var turns_passed: int = 0:
	set(value):
		turns_passed = value
@export_storage var minigame_type: int = 0
@export_storage var loading = false
func set_all_children_owner(node):
	if not node.owner == self and node != self:
		node.set_owner(self)
	for child in node.get_children():
		set_all_children_owner(child)
func save_board():
	var scene :=PackedScene.new()
	set_all_children_owner(self)
	var result = scene.pack(self)
	if result == OK:
		var error = ResourceSaver.save(scene,"user://board.scn")
		if error != OK:
			push_error("An error occurred while saving the scene to disk.")
func load_board():
	if FileAccess.file_exists("user://board.scn"):
		remove_from_group("party")
		name = "deleted"
		self.queue_free()
		var bd = await ResourceLoader.load("user://board.scn").instantiate()
		Define.party =bd
		bd.loading = true
		bd.players =  bd.get_node("Board/Players").get_children()
		bd.sfx =  bd.get_node("Board/SFX")
		bd.add_to_group("party")
		get_parent().add_child(bd)
		bd.name = "party_state"
		await bd.get_tree().process_frame
		await bd.get_tree().process_frame
		bd.loading = false
		return true
	return false


var waiting:Dictionary
var event_queue: Array
signal event_queue_moved
func wait_for_event_sig(event:Event,sig:Signal):
	event_queue.append(event)
	var nam = str(sig.get_object_id())+":"+sig.get_name()
	waiting[nam] = true
	await sig
	waiting.erase(nam)
	event_queue.erase(event)
	event_queue_moved.emit()

func wait_for_event_func(event:Event,callable:Callable,args:Array):
	event_queue.append(event)
	
	var nam =str(callable.get_object_id())+":"+callable.get_method()
	waiting[nam] = true
	var ret = await callable.callv(args)
	waiting.erase(nam)
	event_queue.erase(event)
	event_queue_moved.emit()
	return ret
func wait_for_empty_queue(event:Event = null):
	while event_queue.size()>0:
		if event_queue[0] != event:
			await  event_queue_moved
	return
func is_waiting():
	return event_queue.size() > 0
func in_action():
	var result = party_section == Section.ACTION or (party_section == Section.FADE_TO_ACTION and time_since_section_change >= 0.500)
	
	return result
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	board_logic(delta)
	if party_section == Section.ROLL or party_section == Section.FADE_TO_ACTION:
		queue_redraw()
	pass

func board_logic(delta_t: float) -> void:
	if party_section == Section.LOAD_GAME:
		if await load_board():
			return
		time_since_section_change+= delta_t
		if time_since_section_change > 0.160:
			
			party_section = Section.ROLL
	if in_action():
		time_since_section_change += delta_t
		if party_section == Section.FADE_TO_ACTION and time_since_section_change >= 0.700:
			time_since_section_change = 0
			party_section = Section.ACTION
			for event:Event in get_tree().get_nodes_in_group("event"):
				await Event.activate_event_chain(players[0],Define.ACTIVATION.ACT_START_TURN,event)
			var readystart_sound = sfx.get_node("ReadyStart")
			readystart_sound.play()
		event_process(delta_t)
		var everybody_ready = true
		if is_waiting():
			return
		for event in get_tree().get_nodes_in_group("event"):
			if event.is_active():
				everybody_ready = false
				break
		for p in  players:
			if not p.is_ready_to_end():
				everybody_ready = false
		if everybody_ready:
			#game.sys_assets.sfx_horn.stop()
			time_since_section_change = 0.0
			party_section = Section.END_OF_TURN
	elif party_section == Section.END_OF_TURN:
		if is_waiting():
			event_tick.emit()
			event_handle_player.emit()
			for e in get_tree().get_nodes_in_group("event"):
				e.reset_tick()
			return
		for event in get_tree().get_nodes_in_group("event"):
			await Event.activate_event_chain(Define.dummy,Define.ACTIVATION.ACT_END_TURN,event)
		while event_queue.size() >0:
			await  event_queue_moved
		party_section = Section.FADE_TO_MINIGAME
	elif party_section == Section.ROLL:
		time_since_section_change += delta_t
		time_since_reroll += delta_t
		var roll_sound = sfx.get_node("DiceRoll")
		if time_since_reroll > 0.400:
			for p in players:
				if p.cpu_controlled:
					Input.action_press(p.controls.player+p.controls.a)
				if not p.rolled_ready:
					p.spaces_rolled = p.roll_unreliable(p.roll_reliable())
			time_since_reroll = 0
		event_process(delta_t)
		var ready = true
		for p in players:
			if not p.rolled_ready:
				ready = false
		if not ready:
			if not roll_sound.playing:
				roll_sound.playing = true
		if ready:
			roll_sound.stream_paused = true
			for p in players:
				p.spaces_rolled = p.roll_unreliable(p.spaces_rolled)
				p.capsule_mgr.capsule_thrown = false
				p.capsule_mgr.hold.reset()
				p.travel.spaces_left_to_move = p.spaces_rolled
			time_since_section_change = 0.0
			time_since_reroll = 0.0
			party_section = Section.FADE_TO_ACTION
	elif party_section == Section.FADE_TO_ACTION and time_since_section_change < 4.000:
		for p in players:
			p.rolled_ready = false
		for p in players:
			p.travel.landed = false
		time_since_section_change += delta_t
	elif party_section == Section.FADE_TO_MINIGAME:
		time_since_section_change += delta_t
		var blue_players = 0
		for p in players:
			if p.travel.red_or_blue == 0:
				blue_players += 1
		minigame_type = blue_players
		if time_since_section_change >= 0.160:
			time_since_section_change = 0
			party_section = Section.MINIGAME
	elif party_section == Section.MINIGAME:
		time_since_section_change += delta_t
		if time_since_section_change >= 0.260:
			time_since_section_change = 0
			party_section = Section.FADE_TO_RESULTS
	elif party_section == Section.FADE_TO_RESULTS:
		time_since_section_change += delta_t
		if time_since_section_change >= 0.160:
			time_since_section_change = 0
			turns_passed+=1
			party_section = Section.RESULTS
			party_section = Section.RESULTS
	elif party_section == Section.RESULTS:
		pass
	elif party_section == Section.FADE_TO_ROLL:
			time_since_section_change += delta_t
			if time_since_section_change >= 1.160:
				for p in players:
					p.sprite_id = Define.PlayerSprite.SPRITE_DEFAULT
					p.spaces_rolled = p.roll_reliable()
				time_since_section_change = 0
				party_section = Section.ROLL
				save_board()
	if (
			turns_passed >= turns_to_play and
			party_section != Section.FADE_TO_FINAL_RESULTS and
			party_section != Section.FINAL_RESULTS
		):
			party_section = Section.FINAL_RESULTS
signal event_tick
signal player_tick
signal event_handle_player
signal handle_player
func event_process(delta_t):
	if in_action():
		event_tick.emit()
		event_handle_player.emit()
	if is_waiting():
		event_queue[0].reset_tick()
		return
	#player_tick.emit()
	#handle_player.emit()
	#if is_waiting():
	#	return
	for e in get_tree().get_nodes_in_group("event"):
		e.reset_tick()
func _draw():
	var pcol = [
		Color(0.95, 0.65, 0.15, 0.45),
		Color(0.45, 0.65, 0.35, 0.45),
		Color(0.8, 0.15, 1, 0.45),
		Color(0.1, 0.1, 0.1, 0.43)
	]
	var opcol = [
		Color(0.95, 0.65, 0.15, 1),
		Color(0.45, 0.65, 0.35, 1),
		Color(0.8, 0.15, 1, 1),
		Color(0.1, 0.1, 0.1, 1)
	]
	var poffset = [
		Vector2(-32,-32),
		Vector2(0,-32),
		Vector2(-32,0),
		Vector2(0,0),
		Vector2(0,0),
	]
	var hud_pos = [    Vector2(1152 / 32 * 1.75, 642 / 32 * 2),    Vector2(1152 - (1152 / 32 * 3), 642 / 32 * 2),    Vector2(1152 / 32 * 1.75, 642 - (642 / 32 * 6)),    Vector2(1152 - (1152 / 32 * 3), 642 - (642 / 32 * 6))]
	#if party_section == Section.ROLL:
		#var pos = Vector2(640 / 2, 480 / 2)
		#for p in players:
			#draw_texture_rect(Define.bmp_dice, Rect2(p.position - Vector2(8, 64) + poffset[p.player_id], Vector2(32, 32)), false, Color(1.0, 1.0, 1.0, min(1.0, time_since_section_change)))
			#draw_string(
				#Define.system_font,
				#p.position - Vector2(12, 36) + poffset[p.player_id], str(p.spaces_rolled),
				#1,40, 40,opcol[p.player_id],
			#)
	
	pass # Replace with function body.
#endregion
#region Old
#
#extends Node2D
#enum Section {
	#ROLL=1,
	#FADE_TO_ACTION=2,
	#ACTION=3,
	#FADE_TO_MINIGAME=4,
	#MINIGAME=5,
	#FADE_TO_RESULTS=6,
	#RESULTS=7,
	#FADE_TO_FINAL_RESULTS=8,
	#FINAL_RESULTS=9,
	#FADE_TO_ROLL=10,
	#
	#OPEN_GAME=11,
	#LOAD_GAME=12,
	#NEW_GAME=13,
#}
#enum MinigameType {
	#FREE_FOR_ALL,
	#n1v3,
	#n2v2,
	#n3v1,
	#WINNER_TAKE_ALL,
#}
#@onready var spaces = $Board/Spaces.get_children()
#@onready var capsules = [
	#$Board/Capsules/P1.get_children(),
	#$Board/Capsules/P2.get_children(),
	#$Board/Capsules/P3.get_children(),
	#$Board/Capsules/P4.get_children(),
	#$Board/Capsules/Natural.get_children()
#]
#@onready var players =  $Board/Players.get_children()
#@onready var sfx =  $Board/SFX
#
#
#var time_passed: float
#var time_since_reroll: float = 0.0
#var time_since_section_change: float = 0.0
#var party_section: Section = Section.OPEN_GAME
#var turns_so_far: Array = []
#var cur_turn: int = 0
#var turns_to_play: int = 20
#var turns_passed: int = 0:
	#set(value):
		#turns_passed = value
#var minigame_type: int = 0
#var load_scene_cache = {
	#
#}
#func load_from_cache(filepath):
	#if load_scene_cache.has(filepath):
		#return load_scene_cache[filepath].instantiate()
	#load_scene_cache[filepath] = load(filepath)
	#return load_scene_cache[filepath].instantiate()
## Called when the node enters the scene tree for the first time.
#func _ready():
	#
	#pass # Replace with function body.
#
#
#var waiting:Dictionary
#var event_queue: Array
#func wait_for_event_sig(event:Event,sig:Signal):
	#event_queue.append(event)
	#var nam = str(sig.get_object_id())+":"+sig.get_name()
	#waiting[nam] = true
	#await sig
	#waiting.erase(nam)
	#event_queue.erase(event)
	#pass
#
#func wait_for_event_func(event:Event,callable:Callable,args:Array):
	#event_queue.append(event)
	#
	#var nam =str(callable.get_object_id())+":"+callable.get_method()
	#waiting[nam] = true
	#var ret = await callable.callv(args)
	#waiting.erase(nam)
	#event_queue.erase(event)
	#return ret
#func is_waiting():
	#return event_queue.size() > 0
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#
	#board_logic(delta)
	#input_processing(delta)
	#if party_section == Section.ROLL or party_section == Section.FADE_TO_ACTION:
		#queue_redraw()
	#pass
#
#func board_logic(delta_t: float) -> void:
	#if event_queue.size() > 0:
		#var event = event_queue[0]
		#event.tick(delta_t)
		#return
	#if party_section == Section.LOAD_GAME:
		#var f = FileAccess.open("user://board_save.json",FileAccess.READ)
		#if f.is_open():
			#turns_so_far = JSON.parse_string(f.get_as_text())
			#var turn = turns_so_far.back()
			#if is_instance_valid(turn):
				#party_section = Section.FADE_TO_ACTION
			#else:
				#for space in spaces:
					#space.queue_free()
				#for space in capsules[0]:
					#space.queue_free()
				#for space in capsules[1]:
					#space.queue_free()
				#for space in capsules[2]:
					#space.queue_free()
				#for space in capsules[3]:
					#space.queue_free()
				#for space in capsules[4]:
					#space.queue_free()
				#spaces.clear()
				#capsules[0].clear()
				#capsules[1].clear()
				#capsules[2].clear()
				#capsules[3].clear()
				#capsules[4].clear()
				#var save_spaces = turn["spaces"]
				#for save_space in save_spaces:
					#var space = load_from_cache(save_space["load_scene"])
					#
					#space.name = save_space["name"]
					#space.set_visible(save_space["visible"])
					#spaces.push_back(space)
				#var save_capsules_0 = turn["player_0"]["capsules"]
				#for save_space in save_capsules_0:
					#var space = load_from_cache(save_space["load_scene"])
					#space.name = save_space["name"]
					#space.set_visible(save_space["visible"])
					#capsules[0].push_back(space)
					#
				#var save_capsules_1 = turn["player_1"]["capsules"]
				#for save_space in save_capsules_1:
					#var space = load_from_cache(save_space["load_scene"])
					#space.name = save_space["name"]
					#space.set_visible(save_space["visible"])
					#capsules[1].push_back(space)
					#
				#var save_capsules_2 = turn["player_2"]["capsules"]
				#for save_space in save_capsules_2:
					#var space = load_from_cache(save_space["load_scene"])
					#space.name = save_space["name"]
					#space.set_visible(save_space["visible"])
					#capsules[2].push_back(space)
					#
				#var save_capsules_3 = turn["player_3"]["capsules"]
				#for save_space in save_capsules_3:
					#var space = load_from_cache(save_space["load_scene"])
					#space.name = save_space["name"]
					#space.set_visible(save_space["visible"])
					#capsules[3].push_back(space)
					#
				#var save_nat_capsules = turn["natural_capsules"]
				#for save_space in save_nat_capsules:
					#var space = load_from_cache(save_space["load_scene"])
					#space.name = save_space["name"]
					#space.set_visible(save_space["visible"])
					#capsules[4].push_back(space)
				#for i in spaces.size():
					#spaces[i].load_me(save_spaces[i])
				#for i in capsules[0].size():
					#capsules[0][i].load_me(save_capsules_0[i])
					#
				#for i in capsules[1].size():
					#capsules[1][i].load_me(save_capsules_1[i])
					#
				#for i in capsules[2].size():
					#capsules[2][i].load_me(save_capsules_2[i])
					#
				#
				#for i in capsules[3].size():
					#capsules[3][i].load_me(save_capsules_3[i])
				#
				#for i in capsules[4].size():
					#capsules[4][i].load_me(save_nat_capsules[i])
				#turns_passed = turn["turns_passed"]
				#for p in players:
					#p.coin_mgr.amount = turn["player_"+str(p.player_id)]["coins"]
					#p.star_mgr.amount= turn["player_"+str(p.player_id)]["stars"]
					#p.cur_space = spaces[turn["player_"+str(p.player_id)]["space"]]
					#p.position = str_to_var(turn["player_"+str(p.player_id)]["position"])
					#for i in 3:
						#if turn["player_"+str(p.player_id)].has("inventory_"+str(i)):
								#var save_capsule = turn["player_"+str(p.player_id)]["inventory_"+str(i)]
								#var capsule = load_from_cache(save_capsule["load_scene"])
								#capsule.name = save_capsule["name"]
								#capsule.set_visible(save_capsule["visible"])
								#capsule.load_me(save_capsule)
								#p.capsule_mgr.inventory[i] = capsule
								#
					#p.land_events_activated = turn["player_"+str(p.player_id)]["land_events"]
					#p.leave_events_activated= turn["player_"+str(p.player_id)]["leave_events"] 
					#p.enter_events_activated= turn["player_"+str(p.player_id)]["enter_events"] 
					#p.pass_events_activated= turn["player_"+str(p.player_id)]["pass_events"]
		#time_since_section_change+= delta_t
		#if time_since_section_change > 0.160:
			#for space in spaces:
				#($Board/Spaces).add_child(space)
			#for space in capsules[0]:
				#($Board/Capsules/P1).add_child(space)
				#space.my_player = players[0]
			#for space in capsules[1]:
				#($Board/Capsules/P2).add_child(space)
				#space.my_player = players[1]
			#for space in capsules[2]:
				#($Board/Capsules/P3).add_child(space)
				#space.my_player = players[2]
			#for space in capsules[3]:
				#($Board/Capsules/P4).add_child(space)
				#space.my_player = players[3]
			#for space in capsules[4]:
				#($Board/Capsules/Natural).add_child(space)
			#party_section = Section.ROLL
	#if party_section == Section.ACTION or (party_section == Section.FADE_TO_ACTION and time_since_section_change >= 0.500):
#
		#time_since_section_change += delta_t
		#if party_section == Section.FADE_TO_ACTION and time_since_section_change >= 0.700:
			#time_since_section_change = 0
			#party_section = Section.ACTION
			#var readystart_sound = sfx.get_node("General/ReadyStart")
			#readystart_sound.play()
		#
		#for capsule in ($Board/Capsules/P1).get_children():
			#if is_waiting():
				#break
			#if not capsule.ticked:
				#capsule.tick(delta_t)
		#for capsule in ($Board/Capsules/P2).get_children():
			#if is_waiting():
				#break
			#if not capsule.ticked:
				#capsule.tick(delta_t)
		#for capsule in ($Board/Capsules/P3).get_children():
			#if is_waiting():
				#break
			#if not capsule.ticked:
				#capsule.tick(delta_t)
		#for capsule in ($Board/Capsules/P4).get_children():
			#if is_waiting():
				#break
			#if not capsule.ticked:
				#capsule.tick(delta_t)
		#for capsule in ($Board/Capsules/Natural).get_children():
			#if is_waiting():
				#break
			#if not capsule.ticked:
				#capsule.tick(delta_t)
		#for capsule in ($Board/Capsules/Events).get_children():
			#if is_waiting():
				#break
			#if not capsule.ticked:
				#capsule.tick(delta_t)
		#for space in spaces:
			#if is_waiting():
				#break
				#
			#if not space.ticked:
				#space.tick(delta_t)
		#
		#for p in players:
			#if is_waiting():
				#break
			#p.move_mgr.action_movement_logic(delta_t,p)
		#for p in players:
			#
			#if is_waiting():
				#break
			#if not p.ticked:
				#p.tick(delta_t)
		#
		#if is_waiting():
			#return
		#else:
			#for p in players:
				#p.ticked = false
			#for event in ($Board/Capsules/P1).get_children():
				#event.ticked = false
			#for event in ($Board/Capsules/P2).get_children():
				#event.ticked = false
			#for event in ($Board/Capsules/P3).get_children():
				#event.ticked = false
			#for event in ($Board/Capsules/P4).get_children():
				#event.ticked = false
			#for event in ($Board/Capsules/Natural).get_children():
				#event.ticked = false
			#for event in ($Board/Capsules/Events).get_children():
				#event.ticked = false
			#for event in spaces:
				#event.ticked = false
		#var everybody_ready = true
		#for p in  players:
			#if not p.landed or p.coin_mgr.active or p.star_mgr.active or p.move_mgr.active:
				#everybody_ready = false
		#
		#for capsule in ($Board/Capsules/P1).get_children():
			#if capsule.active:
				#everybody_ready = false
		#for capsule in ($Board/Capsules/P2).get_children():
			#if capsule.active:
				#everybody_ready = false
		#for capsule in ($Board/Capsules/P3).get_children():
			#if capsule.active:
				#everybody_ready = false
		#for capsule in ($Board/Capsules/P4).get_children():
			#if capsule.active:
				#everybody_ready = false
		#for capsule in ($Board/Capsules/Natural).get_children():
			#if capsule.active:
				#everybody_ready = false
		#for space in spaces:
			#if space.active:
				#everybody_ready = false
		#if everybody_ready:
			##game.sys_assets.sfx_horn.stop()
			#time_since_section_change = 0.0
			#party_section = Section.FADE_TO_MINIGAME
	#
	#elif party_section == Section.ROLL:
		#time_since_section_change += delta_t
		#time_since_reroll += delta_t
		#var roll_sound = sfx.get_node("General/DiceRoll")
		#
		#if time_since_reroll > 0.090:
			#for p in players:
				#if p.cpu_controlled:
					#Input.action_press(p.controls.player+p.controls.a)
				#if not p.really_ready:
					#p.spaces_rolled = randi_range(1, 15)
					##p.really_ready = true
			#time_since_reroll = 0
		#
		#
		#var ready = true
		#for p in players:
			#if not p.really_ready:
				#ready = false
		#if not ready:
			#if not roll_sound.playing:
				#roll_sound.playing = true
		#if ready:
			#roll_sound.stream_paused = true
			#for p in players:
				#p.capsule_mgr.capsule_thrown = false
				#p.capsule_mgr.hold.reset()
				#p.spaces_left_to_move = p.spaces_rolled
			#
			#time_since_section_change = 0.0
			#time_since_reroll = 0.0
			#
			#party_section = Section.FADE_TO_ACTION
	#
	#elif party_section == Section.FADE_TO_ACTION and time_since_section_change < 4.000:
		#for p in players:
			#p.really_ready = false
		#
		#for p in players:
			#p.landed = false
		#
		#time_since_section_change += delta_t
	#
	#elif party_section == Section.FADE_TO_MINIGAME:
		#time_since_section_change += delta_t
		#var blue_players = 0
		#for p in players:
			#if p.red_or_blue == 0:
				#blue_players += 1
		#
		#minigame_type = blue_players
		#
		#if time_since_section_change >= 0.160:
			#time_since_section_change = 0
			#party_section = Section.MINIGAME
	#
	#elif party_section == Section.MINIGAME:
		#time_since_section_change += delta_t
		#
		#if time_since_section_change >= 0.260:
			#time_since_section_change = 0
			#party_section = Section.FADE_TO_RESULTS
	#
	#elif party_section == Section.FADE_TO_RESULTS:
		#time_since_section_change += delta_t
		#
		#if time_since_section_change >= 0.160:
			#time_since_section_change = 0
			#turns_passed+=1
			#party_section = Section.RESULTS
			#var turn: = {}
			#
			#var star_height_multiplier: = -30.0
			#var coin_height_multiplier: = -2.0
			#var save_spaces = []
			#for space in spaces:
				#save_spaces.push_back(space.save({}))
			#turn["spaces"] = save_spaces
			#for p in players:
				#var player = {}
				#player["coins"] = p.coin_mgr.amount
				#player["position"] = var_to_str(p.position)
				#player["stars"] = p.star_mgr.amount
				#player["space"] = spaces.find(p.cur_space)
				#for i in 3:
					#if is_instance_valid(p.capsule_mgr.inventory[i]):
						#player["inventory_"+str(i)] = p.capsule_mgr.inventory[i].save({})
				#player["land_events"] = p.land_events_activated
				#player["leave_events"] = p.leave_events_activated
				#player["enter_events"] = p.enter_events_activated
				#player["pass_events"] = p.pass_events_activated
				#var capsules = []
				#for capsule in $Board/Capsules.get_child(p.player_id).get_children():
					#capsules.push_back(capsule.save({}))
				#player["capsules"] = capsules
				#turn["player_"+str(p.player_id)] = player
			#
			#var capsules = []
			#for capsule in $Board/Capsules.get_child(4).get_children():
				#capsules.push_back(capsule.save({}))
			#turn["natural_capsules"] = capsules
			#turn["turns_passed"] = turns_passed
			#turn["turns_to_play"] = turns_to_play
			#turns_so_far.push_back(turn)
			#var f = FileAccess.open("user://board_save.json",FileAccess.WRITE)
			#if f.is_open():
				#f.store_string(JSON.stringify(turns_so_far))
				#f.close()
			#party_section = Section.RESULTS
	#elif party_section == Section.RESULTS:
		#pass
#
				#
		#
	#elif party_section == Section.FADE_TO_ROLL:
			#time_since_section_change += delta_t
			#if time_since_section_change >= 1.160:
				#for p in players:
					#p.sprite_id = Define.PlayerSprite.SPRITE_DEFAULT
					#p.spaces_rolled = randi_range(1, 10)
				#
				#time_since_section_change = 0
				#party_section = Section.ROLL
		#
	#if (
			#turns_passed >= turns_to_play and
			#party_section != Section.FADE_TO_FINAL_RESULTS and
			#party_section != Section.FINAL_RESULTS
		#):
			#party_section = Section.FINAL_RESULTS
#
#func input_processing(delta_t):
	#
	#if event_queue.size() > 0:
		#var event = event_queue[0]
		#for p in players:
			#event.handle_player(delta_t,p)
		#return
	#for p in players:
		#for capsule in $Board/Capsules/P1.get_children():
			#if is_waiting():
				#break
			#if capsule.handled_player.has(p):
				#continue
			#capsule.handle_player(delta_t,p)
		#for capsule in $Board/Capsules/P2.get_children():
			#if is_waiting():
				#break
			#if capsule.handled_player.has(p):
				#continue
			#capsule.handle_player(delta_t,p)
		#for capsule in $Board/Capsules/P3.get_children():
			#if is_waiting():
				#break
			#if capsule.handled_player.has(p):
				#continue
			#capsule.handle_player(delta_t,p)
		#for capsule in $Board/Capsules/P4.get_children():
			#if is_waiting():
				#break
			#if capsule.handled_player.has(p):
				#continue
			#capsule.handle_player(delta_t,p)
		#for capsule in $Board/Capsules/Natural.get_children():
			#if is_waiting():
				#break
			#if capsule.handled_player.has(p):
				#continue
			#capsule.handle_player(delta_t,p)
		#for capsule in $Board/Capsules/Events.get_children():
			#if is_waiting():
				#break
			#if capsule.handled_player.has(p):
				#continue
			#capsule.handle_player(delta_t,p)
		#for space in $Board/Spaces.get_children():
			#if is_waiting():
				#break
			#if space.handled_player.has(p):
				#continue
			#space.handle_player(delta_t,p)
		#
		#if is_waiting():
			#break
		#if not p.handled_input:
			#p.handle_input(delta_t)
	#if is_waiting():
		#return
	#for p in players:
		#p.handled_input = false
	#for event in ($Board/Capsules/P1).get_children():
		#event.handled_player.clear()
	#for event in ($Board/Capsules/P2).get_children():
		#event.handled_player.clear()
	#for event in ($Board/Capsules/P3).get_children():
		#event.handled_player.clear()
	#for event in ($Board/Capsules/P4).get_children():
		#event.handled_player.clear()
	#for event in ($Board/Capsules/Natural).get_children():
		#event.handled_player.clear()
	#for event in ($Board/Capsules/Events).get_children():
		#event.handled_player.clear()
	#for event in spaces:
		#event.handled_player.clear()
			#
#func _draw():
	#var pcol = [
		#Color(0.95, 0.65, 0.15, 0.45),
		#Color(0.45, 0.65, 0.35, 0.45),
		#Color(0.8, 0.15, 1, 0.45),
		#Color(0.1, 0.1, 0.1, 0.43)
	#]
	#var opcol = [
		#Color(0.95, 0.65, 0.15, 1),
		#Color(0.45, 0.65, 0.35, 1),
		#Color(0.8, 0.15, 1, 1),
		#Color(0.1, 0.1, 0.1, 1)
	#]
	#var poffset = [
		#Vector2(-32,-32),
		#Vector2(0,-32),
		#Vector2(-32,0),
		#Vector2(0,0),
		#Vector2(0,0),
	#]
	#var hud_pos = [    Vector2(1152 / 32 * 1.75, 642 / 32 * 2),    Vector2(1152 - (1152 / 32 * 3), 642 / 32 * 2),    Vector2(1152 / 32 * 1.75, 642 - (642 / 32 * 6)),    Vector2(1152 - (1152 / 32 * 3), 642 - (642 / 32 * 6))]
	#if party_section == Section.ROLL:
		#var pos = Vector2(640 / 2, 480 / 2)
		#for p in players:
			#draw_texture_rect(Define.bmp_dice, Rect2(p.position - Vector2(8, 64) + poffset[p.player_id], Vector2(32, 32)), false, Color(1.0, 1.0, 1.0, min(1.0, time_since_section_change)))
			#draw_string(
				#Define.system_font,
				#p.position - Vector2(12, 36) + poffset[p.player_id], str(p.spaces_rolled),
				#1,40, 40,opcol[p.player_id],
			#)
	#
#
	#pass # Replace with function body.
#endregion
