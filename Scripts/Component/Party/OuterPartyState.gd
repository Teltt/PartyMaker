extends Node2D
class_name OuterParty
@onready var camera = get_parent().get_node("Camera2D")
@onready var event_camera = get_parent().get_node("SubViewportContainer5/SubViewport/Camera2D")
@onready var placement_based =$UI/PlacementBased.get_children()
@onready var team_based =$UI/TeamBased.get_children()
@onready var confirm =$UI/Confirm.get_child(0)
@onready var load =$UI/Load_Game.get_child(0)
@onready var new_game =$UI/New_Game.get_child(0)
# Called when the node enters the scene tree for the first time.
func _ready():
	Define.outer_party = self
	pass # Replace with function body.
var focus_stack:Array = []
var focusing_on:int = -1
func focus_on_viewport(id:int,push_to_stack=true):
	for c in 5:
		get_parent().get_child(c).visible = true
	id = clampi(id,-1,4)
	if push_to_stack:
		focus_stack.push_back(focusing_on)
	focusing_on = id
	var camera = get_parent().get_node("Camera2D")
	var viewport = get_parent().get_child(id)
	var tween = camera.create_tween()
	tween.set_parallel(true)
	if id == -1:
		for c in 5:
			get_parent().get_child(c).visible = true
		tween.tween_property(camera,"position",Vector2(0,0),1.0)
		tween.tween_property(camera,"zoom",Vector2(1.0,1.0),1.0)
		tween.tween_property(camera,"scale",Vector2(1.0,1.0),1.0)
	else:
		tween.tween_property(camera,"position",viewport.position,1.0)
		if id == 4:
			tween.tween_property(camera,"zoom",Vector2(1.0,1.0),1.0)
			tween.tween_property(camera,"scale",Vector2(1.0,1.0),1.0)
		else:
			tween.tween_property(camera,"zoom",Vector2(2.0,2.0),1.0)
			tween.tween_property(camera,"scale",Vector2(0.5,0.5),1.0)
	await  tween.finished
	tween.kill()
	if id != -1:
		for c in 5:
			if c != id:
				get_parent().get_child(c).visible = false

func finish_focusing():
	var f = focus_stack.pop_back()
	if f == null:
		f = -1
	focus_on_viewport(f,false)
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()
	var party = Define.party
	var party_section =  party.party_section
	var minigame_type = party.minigame_type
	var camera = get_parent().get_node("Camera2D")
	
	%TurnNumber.text = "Turn:"+str(party.turns_passed)
	for p in party.players:
		if is_instance_valid(p.camera):
			p.camera.map_box.set_visible(p.map_mode)
	if party_section == party.Section.OPEN_GAME:
		for i in range(4):
			placement_based[i].type = 1
			party.players[i].cpu_controlled = placement_based[i].value == 0
		%TurnNumber.set_visible(false)
		if load.value == 1:
			party.party_section = party.Section.LOAD_GAME
			$UI/Load_Game.set_visible(false)
			$UI/New_Game.set_visible(false)
			$UI/WhomstPlaying.set_visible(false)
			$UI/Confirm.set_visible(true)
			$UI.set_visible(false)
			%TurnNumber.set_visible(true)
		if new_game.value == 1:
			party.party_section = party.Section.FADE_TO_ROLL
			$UI/Load_Game.set_visible(false)
			$UI/New_Game.set_visible(false)
			$UI/WhomstPlaying.set_visible(false)
			$UI/Confirm.set_visible(true)
			%TurnNumber.set_visible(true)
	elif party_section == party.Section.FADE_TO_RESULTS:
		confirm.value = 0
		for i in range(2):
			team_based[i].value = 0
			team_based[i].reset()
		
		for i in range(4):
			placement_based[i].value = 0
			if party.minigame_type == party.MinigameType.WINNER_TAKE_ALL:
				placement_based[i].type = 1
			else:
				placement_based[i].type = 2
			placement_based[i].reset()
	elif party_section == party.Section.RESULTS:
			$UI.set_visible(true)
			if minigame_type == party.MinigameType.WINNER_TAKE_ALL:
				$UI/PlacementBased.set_visible(true)
				$UI/TeamBased.set_visible(false)
				$UI/FreeForAll.set_visible(false)
				$UI/WinnerTakeAll.set_visible(true)
				$UI/n1v3.set_visible(false)
				$UI/n2v2.set_visible(false)
				$UI/n3v1.set_visible(false)
			elif minigame_type == party.MinigameType.n1v3:
				$UI/PlacementBased.set_visible(false)
				$UI/TeamBased.set_visible(true)
				$UI/FreeForAll.set_visible(false)
				$UI/WinnerTakeAll.set_visible(false)
				$UI/n1v3.set_visible(true)
				$UI/n2v2.set_visible(false)
				$UI/n3v1.set_visible(false)
			elif minigame_type == party.MinigameType.n2v2:
				$UI/PlacementBased.set_visible(false)
				$UI/TeamBased.set_visible(true)
				$UI/FreeForAll.set_visible(false)
				$UI/WinnerTakeAll.set_visible(false)
				$UI/n1v3.set_visible(false)
				$UI/n2v2.set_visible(true)
				$UI/n3v1.set_visible(false)
			elif minigame_type == party.MinigameType.n3v1:
				$UI/PlacementBased.set_visible(false)
				$UI/TeamBased.set_visible(true)
				$UI/FreeForAll.set_visible(false)
				$UI/WinnerTakeAll.set_visible(false)
				$UI/n1v3.set_visible(false)
				$UI/n2v2.set_visible(false)
				$UI/n3v1.set_visible(true)
			elif party.minigame_type == party.MinigameType.FREE_FOR_ALL:
				$UI/PlacementBased.set_visible(true)
				$UI/TeamBased.set_visible(false)
				$UI/FreeForAll.set_visible(true)
				$UI/WinnerTakeAll.set_visible(false)
				$UI/n1v3.set_visible(false)
				$UI/n2v2.set_visible(false)
				$UI/n3v1.set_visible(false)
			for p in party.players:
				if minigame_type == party.MinigameType.WINNER_TAKE_ALL:
					if placement_based[p.player_id].value == 1:
						p.sprite_id = Define.PlayerSprite.SPRITE_HAPPY
					else:
						p.sprite_id = Define.PlayerSprite.SPRITE_SHOCKED
				elif minigame_type == party.MinigameType.FREE_FOR_ALL:
					if placement_based[p.player_id].value == 1:
						p.sprite_id = Define.PlayerSprite.SPRITE_HAPPY
					elif placement_based[p.player_id].value == 2:
						p.sprite_id = Define.PlayerSprite.SPRITE_DEFAULT
					elif placement_based[p.player_id].value == 3 or placement_based[p.player_id].value == 4:
						p.sprite_id = Define.PlayerSprite.SPRITE_MIFFED
					elif placement_based[p.player_id].value == 5:
						p.sprite_id = Define.PlayerSprite.SPRITE_DESPAIR
				else:
					if team_based[p.travel.red_or_blue].value == 1:
						p.sprite_id = Define.PlayerSprite.SPRITE_HAPPY
					else:
						p.sprite_id = Define.PlayerSprite.SPRITE_MIFFED
			
			if confirm.value == 1:
				for p in party.players:
					if minigame_type == party.MinigameType.WINNER_TAKE_ALL:
						if placement_based[p.player_id].value == 1:
							p.coin_mgr.amount = max(0, p.coin_mgr.amount + 9)
						else:
							p.coin_mgr.amount = max(0, p.coin_mgr.amount - 1)
					elif minigame_type == party.MinigameType.FREE_FOR_ALL:
						if placement_based[p.player_id].value == 1:
							p.coin_mgr.amount = max(0, p.coin_mgr.amount + 10)
						elif placement_based[p.player_id].value == 2:
							p.coin_mgr.amount = max(0, p.coin_mgr.amount + 6)
						elif placement_based[p.player_id].value == 3:
							p.coin_mgr.amount = max(0, p.coin_mgr.amount + 3)
						elif placement_based[p.player_id].value == 5:
							p.coin_mgr.amount = max(0, p.coin_mgr.amount - 1)
					elif minigame_type == party.MinigameType.n1v3 || minigame_type == party.MinigameType.n3v1:
						if team_based[p.travel.red_or_blue].value == 1:
							if minigame_type == party.MinigameType.n1v3:
								if p.travel.red_or_blue == 0:
									p.coin_mgr.amount = max(0, p.coin_mgr.amount + 9)
								else:
									p.coin_mgr.amount = max(0, p.coin_mgr.amount + 9)
							elif minigame_type == party.MinigameType.n3v1:
								if p.travel.red_or_blue == 1:
									p.coin_mgr.amount = max(0, p.coin_mgr.amount + 9)
								else:
									p.coin_mgr.amount = max(0, p.coin_mgr.amount + 9)
						else:
							if minigame_type == party.MinigameType.n1v3:
								if p.travel.red_or_blue == 0:
									p.coin_mgr.amount = max(0, p.coin_mgr.amount - 1)
								else:
									p.coin_mgr.amount = max(0, p.coin_mgr.amount - 1)
							elif minigame_type == party.MinigameType.n3v1:
								if p.travel.red_or_blue == 1:
									p.coin_mgr.amount = max(0, p.coin_mgr.amount - 1)
								else:
									p.coin_mgr.amount = max(0, p.coin_mgr.amount - 1)
					else:
						if team_based[p.travel.red_or_blue].value == 1:
							p.coin_mgr.amount = max(0, p.coin_mgr.amount + 6)
						else:
							p.coin_mgr.amount = max(0, p.coin_mgr.amount - 1)
				
				party.time_since_section_change = 0
				party.party_section = party.Section.FADE_TO_ROLL
	elif party_section == party.Section.FADE_TO_ROLL:
			$UI.set_visible(false)
	elif party_section == party.Section.FINAL_RESULTS:
			$UI.set_visible(true)
			$UI/PlacementBased.set_visible(false)
			$UI/TeamBased.set_visible(false)
			$UI/Confirm.set_visible(false)
			$UI/FreeForAll.set_visible(false)
			$UI/WinnerTakeAll.set_visible(false)
			$UI/n1v3.set_visible(false)
			$UI/n2v2.set_visible(false)
			$UI/n3v1.set_visible(false)
			%ControlGuide.set_visible(false)
func sort_players(a,b):
	if a.star_mgr.amount > b.star_mgr.amount:
		return true
	if a.star_mgr.amount < b.star_mgr.amount:
		return false
	if a.coin_mgr.amount > b.coin_mgr.amount:
		return true
	if a.coin_mgr.amount < b.coin_mgr.amount:
		return false
	
	return false if randi_range(0,1) >1 else true
func _draw():
		var party = Define.party
		var pcol = [
			Color(0.95, 0.65, 0.15, 0.45),
			Color(0.45, 0.95, 0.35, 0.45),
			Color(0.8, 0.15, 1, 0.45),
			Color(0.8, 0.8, 0.8, 0.43)
		]
		var opcol = [
			Color(0.95, 0.65, 0.15, 1),
			Color(0.45, 0.95, 0.35, 1),
			Color(0.8, 0.15, 1, 1),
			Color(0.8, 0.8, 0.8, 1)
		]
		var poffset = [
			Vector2(-32,-32),
			Vector2(0,-32),
			Vector2(-32,0),
			Vector2(0,0),
			
		]
		var hud_pos = [    Vector2(1152 / 32 * 1.75, 642/ 32 * 2),    Vector2(1152 - (1152 / 32 * 2.75), 642 / 32 * 2),    Vector2(1152 / 32 * 1.75, 642 - (642 / 32 * 4)),    Vector2(1152 - (1152 / 32 * 2.75), 642 - (642 / 32 * 4))]
#
		
		if party.party_section == party.Section.FINAL_RESULTS:
			var place_pos = [    Vector2(1152 / 32 * 16, 642/ 32 * 2), 
			Vector2(1152 / 32 * 16, 642 / 32 * 10),  
			Vector2(1152 / 32 * 16,  642 / 32 * 18),   
			Vector2(1152 / 32 * 16,(642 / 32 * 26))	
			]
			var players = party.players
			players.sort_custom(sort_players)
			for p in players.size():
				var pos = place_pos[p]
				
				draw_texture_rect(Define.bmp_dice,Rect2( pos- Vector2(640 / 32 * 1.5, 20), Vector2(640 / 16 * 2.5, 480 / 16 * 2.5)),false, opcol[players[p].player_id])
				draw_texture_rect(Define.bmp_star, Rect2(pos - Vector2(640 / 32 * 1.5, 0), Vector2(640 / 16, 480 / 16)),false)
				draw_string(
				Define.system_font,
				pos - Vector2(640 / 32 * 1.5, -28),str(players[p].star_mgr.amount), 1,40,40,Color(0, 0.4, 0.75, 255)
				)
				draw_texture_rect(Define.bmp_coin, Rect2(pos + Vector2(640 / 32 * 1.5, 0), Vector2(640 / 16, 480 / 16)),false)
				draw_string(
				Define.system_font,
				pos + Vector2(640 / 32 * 2.0, 28),str(players[p].coin_mgr.amount),1,40,40,Color(0, 0.4, 0.75, 255)
				)
				draw_string(
				Define.system_font,
				pos - Vector2(640 / 32 * 5.5, -28),str(p+1), 1,120,120,opcol[players[p].player_id]
				)
				pass
