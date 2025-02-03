extends Node3D
class_name Amount_MGR
## An amount manager.
@export var mesh:Mesh
@onready var mesh_instance:MultiMeshInstance3D= $MultiMeshInstance3D
@export_storage var amount: int = 0
@export_storage var amount_change: int = 0
@export_storage var passed_time: float = 0.0
@export_range(0.1,3.0) var default_timer = Define.TIME_PER_COIN_GAINED 
@export_storage var time_per_tick: float = 0.0
@export_storage var amount_per_tick: float = 1.0
## PRIVATE
var active: bool = false

func _ready() -> void:
	mesh_instance.multimesh = MultiMesh.new()
	mesh_instance.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	mesh_instance.multimesh.mesh = mesh

func prepare_change(amountChange: int, amountPerTick: float = 3.0, time_multiplier: float = 1.0) -> void:
	if amount + amountChange < 0:
		amount_change += amountChange - (amount+amountChange)
	else:
		amount_change += amountChange
	amount_per_tick = amountPerTick
	time_per_tick = default_timer * time_multiplier
	passed_time = 0.0
	active = true
	
func _process(delta: float) -> void:
	if active:
		passed_time += delta
		if passed_time > time_per_tick and active:
			var amountToGive = 0
			if amount_change < 0:
				amountToGive = amount_change
				amount_change = min(amount_change + abs(amount_per_tick), 0)
				amountToGive -= amount_change
				amount = max(0, amount + amountToGive)
			elif amount_change > 0:
				amountToGive = amount_change
				amount_change = max(amount_change - abs(amount_per_tick), 0)
				amountToGive -= amount_change
				amount = max(0, amount + amountToGive)
			if amount_change == 0:
				active = false
			passed_time = 0.0
	else:
		pass
	handle_multi_mesh()
func handle_multi_mesh():
	var multimesh:MultiMesh = mesh_instance.multimesh
	if not active:
		multimesh.instance_count = 0
		return
	multimesh.instance_count = int(abs(amount_per_tick))

	var coin_height = time_per_tick *5-passed_time*5
	var direction = sign(amount_change)
	for i in multimesh.instance_count:
		var vector = Vector3(0,2+coin_height*remap(i,0,multimesh.instance_count,1.0,2.0),0)
		if direction == -1:
			vector.y = time_per_tick*5 - vector.y+time_per_tick*5+2
		multimesh.set_instance_transform(i,Transform3D(Basis.IDENTITY,vector))
		
func set_amount(new_amount: int) -> void:
	amount = new_amount
func get_amount() -> int:
	return amount

func is_active() -> bool:
	return active
