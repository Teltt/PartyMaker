extends Resource
class_name CapsuleParams
## the icon
@export var icon:Texture2D = null
##The price of the capsule
@export_range(-5,30) var price:int = 0
##Whether or not the capsule may be detected as a space's capsule
@export var space_attach:bool = true
##Whether or not the capsule may attach if Capsule.attach is called
@export var attaches:bool = true
## event_parameters
@export var event_params:EventParams
