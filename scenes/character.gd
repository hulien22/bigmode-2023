extends Node2D

@export var sprite_: CompressedTexture2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite2D.texture = sprite_
	$AnimationPlayer.queue("bop")

func play_attack():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("attack")
	$AnimationPlayer.queue("bop")
