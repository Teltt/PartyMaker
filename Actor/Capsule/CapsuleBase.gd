class_name CapsuleBase
extends Event



var my_space:Space:
	set(val):
		my_space = val
		if get_parent() != null:
			reparent(val)
			#self.set_owner(val)
		else:
			val.add_child(self)
			#self.set_owner(val)
@export var my_player:Player = null:
	set(val):
		my_player = val
		var p_arr:Array[Player] = [my_player]
		if is_instance_valid(my_player):
			$PlayerLayer.set_players(p_arr)
			player_id = my_player.player_id
var player_id: int = 4:
	set(val):
		player_id = val
		if player_id >= 0 and player_id <=4:
			if has_node("Sprite2D"):
				$Sprite2D.modulate = Define.capsule_player_color[player_id]
	
@export_storage var icon:Texture2D = null
@export_storage var price:int = 0
@export_storage var space_attach:bool = true
@export_storage var attaches:bool = true
@export var capsule_params:CapsuleParams:
	set(val):
		if not is_node_ready():
			await  ready
		capsule_params = val
		if is_instance_valid(capsule_params)  and (Engine.is_editor_hint() or not Define.party.loading):
			icon = capsule_params.icon
			price = capsule_params.price
			space_attach = capsule_params.space_attach
			if is_instance_valid(capsule_params.event_params) and not is_instance_valid(params):
				params = capsule_params.event_params
func _ready() -> void:
	if my_space == null:
		var parent = get_parent()
		if parent is Space:
			my_space = parent
	super()
	
func reset() -> void:
	super()

## Deletes this Capsule Event, activates the spaces finish event if it exists
func finish() -> void:
	await my_player.wait_for_event_func(self,self.activate,[Define.ACTIVATION.ACT_FINISH,my_player])
	super()
##Override this to determine whether the capsule attaches
func attach(pl:Player,space:Event=null):
		
	if space and attaches:
		my_space = space
		var revert = await pl.activate(Define.ACTIVATION.ACT_REPLACE, space)
		if not revert:
			my_space.capsule = self
			position = my_space.position
			var revert2 = await  pl.activate(Define.ACTIVATION.ACT_INIT_SPACE, space)
		else:
			my_player = pl
			finish()
## ABOUT THE FUNCTION
## When an Event like Landing or Passing
## happens it goes here to be processed initially
## any persistent logic should be handled in tick or tick player
## ABOUT THE RETURN VALUE
## returns a value to determine whether or not 
## code that changes the state is skipped 
## return false in order to not skip
func activate(activation_type: int, pl: Player) -> Result:
	var party = Define.party
	my_player = pl
	player_id = pl.player_id
	return GO_NO_SKIP

## Do any persistent logic here
func tick(delta_t: float) -> void:
	
	super(delta_t)

## A persistent function that handles each player
## Handle Player by Player Inputs here
## Functionally it's just a second tick function that operates on each Player
func handle_player(delta_t: float,player: Player) -> void:
	super(delta_t,player)
	pass
#
#func save(save_dictionary:Dictionary = {}) -> Dictionary:
	#save_dictionary["my_player"] = -1 if my_player == null else my_player.player_id
	#
	#save_dictionary = super(save_dictionary)
	#return save_dictionary
	#
#func load_me(save_dictionary:Dictionary) -> void:
	#var players = Define.party.players.duplicate()
	#players.append(Define.dummy)
	#my_player = null if save_dictionary["my_player"] == -1 else players[save_dictionary["my_player"]]
	#if my_player == null:
		#my_player = Define.dummy
	#super(save_dictionary)
	#pass

## Do drawing here and only here
func _draw() -> void:
	super()
	pass
