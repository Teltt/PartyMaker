@tool
@icon("res://Resource/Graphics/StarSpace.png")
extends Space
class_name StarBlueSpace
@export_storage var hosted_star_this_cycle = false
@export var hosting_star = true
@export var star_space_siblings : Array[NodePath] = []

func _process(delta):
	super(delta)
	if hosting_star:
		$StarSpace.set_visible(true)
		$Space.set_visible(false)
	else:
		$StarSpace.set_visible(false)
		$Space.set_visible(true)
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
	if activation_type == Define.ACTIVATION.ACT_PASS or  activation_type == Define.ACTIVATION.ACT_EVENT_PASS:
		if pl.coin_mgr.amount >= 20 and hosting_star:
			pl.coin_mgr.prepare_change(-20,-20,-0.5) 
			pl.star_mgr.prepare_change(1,1,2.5) 
			hosting_star = false
			hosted_star_this_cycle = true
			var found_star_space = false
			for star_space_path in star_space_siblings:
				var star_space = get_node(star_space_path)
				if star_space.hosted_star_this_cycle or star_space.hosting_star: 
					continue
				else:
					found_star_space = true
					star_space.hosting_star = true
					break
			if not found_star_space:
				var siblings_hosting_stars = []
				var siblings_not_hosting_stars = []
				for star_space_path in star_space_siblings:
					var star_space = get_node(star_space_path)
					star_space.hosted_star_this_cycle = false
					if star_space.hosting_star and not star_space.hosted_star_this_cycle:
						siblings_hosting_stars.push_back(star_space)
					else:
						siblings_not_hosting_stars.push_back(star_space)
				if siblings_not_hosting_stars.size() >0:
					var star_space = siblings_not_hosting_stars.pick_random()
					star_space.hosting_star = true
				else:
					hosting_star = true
					hosted_star_this_cycle = false
	if activation_type == Define.ACTIVATION.ACT_LAND or activation_type == Define.ACTIVATION.ACT_EVENT_LAND:
		pl.coin_mgr.prepare_change(3,1.0,0.5)
	return GO_NO_SKIP


## Do any persistent logic here
func tick(delta_t: float) -> void:
	if hosting_star:
		can_land = false
	else:
		can_land = true
	super(delta_t)

## A persistent function that handles each player
## Handle Player by Player Inputs here
## Functionally it's just a second tick function that operates on each Player
func handle_player(delta_t:float,player: Player) -> void:
	super(delta_t,player)
	pass

## Do drawing here and only here
func _draw() -> void:
	super()
	pass
