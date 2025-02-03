@tool
extends Node

const TIME_PER_COIN_GAINED = 0.55
const TIME_PER_COIN_LOST = 0.55
const TIME_PER_STAR_GAINED = 1.5
const TIME_PER_STAR_LOST = 1.75


const SAVENAME_AMOUNT_MGR:StringName = "_Amount"
const SAVENAME_COIN_AMOUNT_MGR:StringName = "Coin_Amount"
const SAVENAME_STAR_AMOUNT_MGR:StringName = "Star_Amount"
const SAVENAME_BANK_COIN_AMOUNT_MGR:StringName = "Goomba_Coin_Amount"

enum PlayerSprite {
	SPRITE_DEFAULT,
	SPRITE_HAPPY,
	SPRITE_DESPAIR,
	SPRITE_SHOCKED,
	SPRITE_MIFFED
}
const PLAYERS_PARTICIPATING = 4



enum ACTIVATION {
	
	ACT_LAND = 1,
	## Not revertible
	ACT_PASS = 2,
	## Not revertible
	ACT_ENTER = 4,
	ACT_LEAVE = 8,
	ACT_INIT_PRESENT = 16,
	ACT_INIT_SPACE = 32,
	ACT_REPLACE = 64,
	## Not revertible
	ACT_FINISH = 128,
	## Not revertible
	ACT_START_TURN = 256,
	## Not revertible
	ACT_END_TURN = 512,
	ACT_EVENT = 1024,
	ACT_EVENT_LAND = 1025,
	ACT_EVENT_PASS = 1025,
}	
const opcol = [
	Color(0.95, 0.65, 0.15, 1),
	Color(0.45, 0.95, 0.35, 1),
	Color(0.8, 0.15, 1, 1),
	Color(0.8, 0.8, 0.8, 1)
]
const capsule_player_color= [
			Color(0.95, 0.65, 0.15, 1),
			Color(0.45, 0.95, 0.35, 1),
			Color(0.8, 0.15, 1, 1),
			Color(0.1, 0.1, 0.1, 1),
			Color(1, 1, 1, 1)
		]
@onready var system_font = preload("res://Resource/Graphics/Schoolwork-Regular.ttf")
@onready var bmp_red_space = preload("res://Resource/Graphics/RedSpace.png")
@onready var bmp_blue_space = preload("res://Resource/Graphics/BlueSpace.png")
@onready var bmp_star = preload("res://Resource/Graphics/StarSpace.png")
@onready var bmp_dice = preload("res://Resource/Graphics/DiceBlock.png")
@onready var bmp_coin = preload("res://Resource/Graphics/Coin.png")
@onready var party:Party = get_tree().get_first_node_in_group("Party")
@onready var dummy = get_tree().get_first_node_in_group("Dummy"):
	get:
		return get_tree().get_first_node_in_group("Dummy")
var outer_party:OuterParty
var event_cam:Camera3D
