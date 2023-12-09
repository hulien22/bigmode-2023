extends Node2D
class_name AbilityBox

signal ability_clicked(val)

var value:int
var ability:Ability
var enabled:bool = false

func _init():
	ability = Ability.new("", "", [])

func init(v:int, a:Ability):
	value = v
	ability.copy_from(a)
	updateSprites()

func updateSprites():
	$Display/AnimatedSprite2D.frame = value
	$Display/Label.text = ability.name_
	$Display/Description/Label2.text = ability.desc_ + ability.get_effect_descs()
	
	update_color()
#	set_enabled(false)

func set_enabled(en:bool):
	enabled = en
	$ColorRect.disabled = !enabled
	update_color()

func update_color():
	if enabled:
		modulate = Color.LIGHT_GREEN;
		modulate.a = 1
	else:
		modulate = Color.WHITE;
#		modulate.a = 0.8

var has_mouse = false
func _on_color_rect_mouse_entered():
#	if enabled:
	$Display.scale = Vector2.ONE * 1.2
	z_index = 1
	SfxHandler.play_sfx(SfxHandler.PAPER_SFX, self, 1)
#	Events.emit_signal("tooltip_obj_entered", self, 0.5, ToolTip.DISPLAY.ABILITY)
	$Display/Description.visible = true

func _on_color_rect_mouse_exited():
	$Display.scale = Vector2.ONE
	z_index = 0
#	Events.emit_signal("tooltip_obj_exited", self)
	$Display/Description.visible = false

func _on_color_rect_pressed():
	ability_clicked.emit(value)
	$Display/Description.visible = false
	SfxHandler.play_sfx(SfxHandler.PAPER_HIT_SFX, self, 1)
