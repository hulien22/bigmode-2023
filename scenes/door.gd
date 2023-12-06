extends Node2D
class_name Door

signal door_selected()

func init():
	$AnimatedSprite2D.frame = 0

func _on_button_pressed():
	door_selected.emit()

func _on_button_mouse_entered():
	$AnimatedSprite2D.frame = 1

func _on_button_mouse_exited():
	$AnimatedSprite2D.frame = 0
