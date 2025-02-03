extends Control
var time:float = 5.0
@export var text:String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visibility_layer = get_parent().visibility_layer
	$Label.text = text
	get_tree().create_timer(time).timeout.connect(queue_free)
	position = Vector2(200,get_parent().get_child_count()*60)
func _process(delta: float) -> void:
	$Label.text = text
	position = position.move_toward(Vector2(200,get_index()*60),delta*200.0)
