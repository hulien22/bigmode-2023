extends Node2D

@export var sprite_: CompressedTexture2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite2D.texture = sprite_
	$Sprite2D.position = Vector2.ZERO
	$Sprite2D.modulate.a = 1
	$AnimationPlayer.play("bop")

func init(sprite: CompressedTexture2D):
	sprite_ = sprite
	_ready();

func play_attack():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("attack")
	$AnimationPlayer.queue("bop")

func play_fade_die():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("fade_die")
	
