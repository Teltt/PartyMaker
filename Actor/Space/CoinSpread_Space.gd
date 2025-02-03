@tool
extends Space
var coin_capsule = preload("res://Actor/Capsule/Free_Coin.tscn")
var throwing = []
func fill_with_coins():
	var islands = get_island_list().filter(
		func(ele):
			return not self in ele
	)
	var capsule_managers =[CapsuleMgr.new(),CapsuleMgr.new(),CapsuleMgr.new(), CapsuleMgr.new(),CapsuleMgr.new()]
	for i in capsule_managers.size():
		var island = islands.pick_random()
		var space = island.pick_random()
		capsule_managers[i].throw_space = space
		capsule_managers[i].next_space = self
		
		capsule_managers[i].inventory.resize(3)
		for c in range(3):
			capsule_managers[i].inventory[c] = null
		capsule_managers[i].add_to_inventory(coin_capsule)
		capsule_managers[i].thrown_cap = capsule_managers[i].inventory[0]
		capsule_managers[i].thrown_capsule(self.position,space.position)
		var dummy = Define.dummy
		
		add_child(capsule_managers[i])
	throwing.append_array(capsule_managers)
func tick(delta_t:float):
	if not active:
		return
	var dummy = Define.dummy
	for i in throwing.size():
		throwing[i].tick(delta_t,dummy)
	var prev_throwing = throwing
	throwing = throwing.filter(func(ele):
		return ele.throw_active)
	for t in prev_throwing:
		if t not in throwing:
			t.queue_free()
	if throwing.is_empty():
		reset()
	
		
func get_island_list():
	var party = Define.party
	var spaces = party.space_parent.get_children().filter(
		func(ele):return ele is Space
	)
	
	var islands:Array = []
	var island_dict = {}
	var space_index= {}
	var s_index= {}
	for s in spaces.size():
		island_dict[s] = [spaces[s]]
		space_index[spaces[s]] = s
		s_index[spaces[s]] = s
	for s in spaces:
		for path in s.next_space:
			var next =s.get_node(path)
			
			if space_index[next] != space_index[s]:
				var filtered = island_dict[space_index[next]].filter(
					func (ele):
						return ele not in island_dict[space_index[s]]
				)
				island_dict[space_index[s]].append_array(island_dict[space_index[next]])

				island_dict[space_index[next]].clear()
			space_index[next] = space_index[s]
		for path in s.previous_space:
			var next =s.get_node(path)
			
			if space_index[next] != space_index[s]:
				var filtered = island_dict[space_index[next]].filter(
					func (ele):
						return ele not in island_dict[space_index[s]]
				)
				island_dict[space_index[s]].append_array(filtered)
				island_dict[space_index[next]].clear()
			space_index[next] = space_index[s]
	for i in island_dict.keys():
		if not island_dict[i].is_empty():
			islands.push_back(island_dict[i])
	return islands
			

## Resets Variables to default
func reset() -> void:
	super()

## Deletes this Space, Severs connections too
func finish() -> void:
	super()
	
## ABOUT THE FUNCTION
## When an Event like Landing or Passing
## happens it goes here to be processed initially
## any persistent logic should be handled in tick or tick player
## ABOUT THE RETURN VALUE
## returns a value to determine whether or not 
## code that changes the state is skipped 
## return false in order to not skip
func activate(activation_type: int, pl: Player = null) -> Result:
	if activation_type == Define.ACTIVATION.ACT_PASS:
		active = true
		fill_with_coins()
		super(activation_type,pl)
	return GO_NO_SKIP



## A persistent function that handles each player
## Handle Player by Player Inputs here
## Functionally it's just a second tick function that operates on each Player
func handle_player(delta_t: float,player: Player) -> void:
	super(delta_t,player)
	pass
	#
#func save(save_dictionary:Dictionary = {}) -> Dictionary:
	#save_dictionary = super(save_dictionary)
	#return save_dictionary
	#
#func load_me(save_dictionary:Dictionary) -> void:
	#for key in save_dictionary:
			#if save_dictionary[key] is String:
				#if not null == (str_to_var(save_dictionary[key])):
					#self[key] = str_to_var(save_dictionary[key])
				#else:
					#self[key] =(save_dictionary[key])
			#else:
					#self[key] =(save_dictionary[key])
	#super(save_dictionary)
	#pass

## Do drawing here and only here
func _draw() -> void:
	super()
	pass
