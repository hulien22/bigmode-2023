extends Node2D
class_name Door

signal door_selected()

func init():
	$AnimatedSprite2D.frame = 0

func _on_button_pressed():
	SfxHandler.play_sfx(SfxHandler.DOOR_PICK_SFX, self, 1)
	door_selected.emit()

func _on_button_mouse_entered():
	SfxHandler.play_sfx(SfxHandler.DOOR_SFX, self, 1)
	$AnimatedSprite2D.frame = 1

func _on_button_mouse_exited():
	SfxHandler.play_sfx(SfxHandler.DOOR_SFX, self, 1)
	$AnimatedSprite2D.frame = 0
