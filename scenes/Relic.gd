extends Node
class_name Relic

var name_: String = ""
var description: String = ""
var animated_sprite_frame: int = 0

func _ready():
	$AnimatedSprite2D.frame = animated_sprite_frame

func process_relic(combat: Combat):
	assert(false) # don't call base class's version

func get_tooltip():
	pass
