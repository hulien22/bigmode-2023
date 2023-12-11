extends Node2D
class_name RelicObject

var relic: Relic

func update_sprite():
	var extra_text:String = ""
	match relic.type:
		Relic.TYPE.TRUSTY_SHIELD:
			$Node2D/AnimatedSprite2D.frame = 15
		Relic.TYPE.TITAN_BELT:
			$Node2D/AnimatedSprite2D.frame = 13
		Relic.TYPE.CAT_SLIPPERS:
			$Node2D/AnimatedSprite2D.frame = 3
		Relic.TYPE.DWARVEN_MEAD:
			$Node2D/AnimatedSprite2D.frame = 6
		Relic.TYPE.CULTIST_HEAD:
			$Node2D/AnimatedSprite2D.frame = 4
		Relic.TYPE.BACKUP_PLANS:
			$Node2D/AnimatedSprite2D.frame = 0
		Relic.TYPE.SNAKE_FRIEND:
			$Node2D/AnimatedSprite2D.frame = 12
		Relic.TYPE.EVEN_STEVEN:
			$Node2D/AnimatedSprite2D.frame = 7
		Relic.TYPE.SACRED_POWER:
			$Node2D/AnimatedSprite2D.frame = 10
		Relic.TYPE.BRINGER_OF_DEATH:
			$Node2D/AnimatedSprite2D.frame = 2
		Relic.TYPE.DRAGON_QUEEN:
			$Node2D/AnimatedSprite2D.frame = 5
		Relic.TYPE.HIGH_ROLLER:
			$Node2D/AnimatedSprite2D.frame = 8
		Relic.TYPE.MORE_OPTIONS:
			$Node2D/AnimatedSprite2D.frame = 16
			extra_text = " (" + str(relic.value) + " / 3)"
		Relic.TYPE.SENTINEL_SHIELD:
			$Node2D/AnimatedSprite2D.frame = 11
		Relic.TYPE.MOMS_STEW:
			$Node2D/AnimatedSprite2D.frame = 9
		Relic.TYPE.TROLL_HEART:
			$Node2D/AnimatedSprite2D.frame = 14
		Relic.TYPE.BAG_OF_HOLDING:
			$Node2D/AnimatedSprite2D.frame = 1
		Relic.TYPE.COOL_GUY_GLASSES:
			$Node2D/AnimatedSprite2D.frame = 24
		Relic.TYPE.DEAL_WITH_THE_DEVIL:
			$Node2D/AnimatedSprite2D.frame = 17
		Relic.TYPE.RATIONS:
			$Node2D/AnimatedSprite2D.frame = 23
		Relic.TYPE.FRONTLOADED:
			$Node2D/AnimatedSprite2D.frame = 25
		Relic.TYPE.INFERNAL_ENGINE:
			$Node2D/AnimatedSprite2D.frame = 22
		Relic.TYPE.FROZEN_SUPERSUIT:
			$Node2D/AnimatedSprite2D.frame = 19
		Relic.TYPE.DRUNKEN_BRAWLER:
			$Node2D/AnimatedSprite2D.frame = 18
		Relic.TYPE.GREED:
			$Node2D/AnimatedSprite2D.frame = 20
		Relic.TYPE.MASOCHIST:
			$Node2D/AnimatedSprite2D.frame = 21
			extra_text = " (Bonus: " + str(relic.value) + ")"
	$Description/Label2.text = "~ " + relic.name_ + extra_text + " ~\n" + relic.description


func _on_color_rect_mouse_entered():
	$Node2D.scale = Vector2.ONE * 1.1
	$Description.show()
	
	SfxHandler.play_sfx(SfxHandler.PAPER_FLIP_ROUGH_SFX, self, 1)
#	SfxHandler.play_sfx(SfxHandler.PAPER_SHIFT_SFX, self, 1)

func _on_color_rect_mouse_exited():
	$Node2D.scale = Vector2.ONE
	$Description.hide()

func animate():
	var tween = get_tree().create_tween()
	$Node2D.scale = Vector2.ONE * 1.5
	tween.tween_property($Node2D, "scale", Vector2.ONE, 0.5)
	
