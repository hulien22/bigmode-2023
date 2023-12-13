extends Node2D

signal gg_go_next()

func _ready():
	$AnimatedSprite2D.frame = 0
	$AnimatedSprite2D.stop()

func _on_button_pressed():
	if $AnimatedSprite2D.frame < 7:
		$AnimatedSprite2D.frame += 1
	else:
		gg_go_next.emit()
