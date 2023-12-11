extends Node2D
class_name Door

signal door_selected()

func init(gs: GameState.GameScene):
	$AnimatedSprite2D.frame = 0
	$AnimatedSprite2D2.show()
	match gs:
		GameState.GameScene.COMBAT:
			$AnimatedSprite2D2.frame = 8
		GameState.GameScene.CHEST:
			$AnimatedSprite2D2.frame = 3
		GameState.GameScene.ABILITY_SHOP:
			$AnimatedSprite2D2.frame = 0
		GameState.GameScene.DICE_SHOP:
			$AnimatedSprite2D2.frame = 4
		GameState.GameScene.RITUAL:
			$AnimatedSprite2D2.frame = 7
		GameState.GameScene.ELITE:
			$AnimatedSprite2D2.frame = 6
		GameState.GameScene.BOSS:
			$AnimatedSprite2D2.frame = 1
		GameState.GameScene.REST:
			$AnimatedSprite2D2.frame = 2
		_:
			$AnimatedSprite2D2.hide()
		

func _on_button_pressed():
	SfxHandler.play_sfx(SfxHandler.DOOR_PICK_SFX, self, 1)
	door_selected.emit()

func _on_button_mouse_entered():
	SfxHandler.play_sfx(SfxHandler.DOOR_SFX, self, 1)
	$AnimatedSprite2D.frame = 1

func _on_button_mouse_exited():
	SfxHandler.play_sfx(SfxHandler.DOOR_SFX, self, 1)
	$AnimatedSprite2D.frame = 0
