extends Node2D
class_name AbilityBox

signal ability_clicked(val)

var value:int
var ability:Ability
var init_scale = 0.76
var enabled:bool = false

func init(v:int, a:Ability):
	value = v
	ability = a
	updateSprites()

func updateSprites():
	$AnimatedSprite2D.frame = value - 1
	$Label.text = ability.name_
	update_color()
	set_enabled(false)

func set_enabled(en:bool):
	enabled = en
	$ColorRect.disabled = !enabled
	update_color()

func update_color():
	if enabled:
		modulate = Color.WHITE;
	else:
		modulate = Color.LIGHT_GRAY;

func _on_color_rect_mouse_entered():
	if enabled:
		scale = Vector2.ONE * 1.2 * init_scale
		z_index = 1
		SfxHandler.play_sfx(SfxHandler.PAPER_SFX, self, 1)

func _on_color_rect_mouse_exited():
	scale = Vector2.ONE * init_scale
	z_index = 0

func _on_color_rect_pressed():
	ability_clicked.emit(value)
