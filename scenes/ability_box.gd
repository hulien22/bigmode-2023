extends Node2D
class_name AbilityBox

signal ability_clicked(val)

var value:int
var ability:Ability
var enabled:bool = false

func init(v:int, a:Ability):
	value = v
	ability = a
	updateSprites()

func updateSprites():
	$Display/AnimatedSprite2D.frame = value - 1
	$Display/Label.text = ability.name_
	var extras:String = ""
	for e in ability.effects_:
		var s: String = AbilityEffect.get_status_desc(e.type_)
		if !s.is_empty():
			extras += "\n" + s
	$Display/Description/Label2.text = ability.desc_
	if !extras.is_empty():
		$Display/Description/Label2.text += "\n---" + extras
	
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

var has_mouse = false
func _on_color_rect_mouse_entered():
	if enabled:
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
