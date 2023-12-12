extends Node2D
class_name PostItButton

signal pressed()
signal mouse_entered()
signal mouse_exited()

@export
var text:String = ""
@export
var disabled:bool = false

func _ready():
	$Node2D2/Text.text = text
	$Node2D2/Button.set_disabled(disabled)

func set_text(t: String):
	text = t
	$Node2D2/Text.text = text

func set_disabled(d:bool):
	disabled = d
	$Node2D2/Button.set_disabled(disabled)
	if disabled:
		$Node2D2.modulate = Color("bebebe")
	else:
		$Node2D2.modulate = Color.WHITE

func _on_button_pressed():
	pressed.emit()
	SfxHandler.play_sfx(SfxHandler.PAPER_FLIP_SFX, self, 1.2)
	_on_button_mouse_exited()

func _on_button_mouse_entered():
	if !disabled:
		SfxHandler.play_sfx(SfxHandler.PAPER_FLICK_SFX, self, 0.9)
		$Node2D2.scale = Vector2.ONE * 1.1
	mouse_entered.emit()

func _on_button_mouse_exited():
	$Node2D2.scale = Vector2.ONE
	mouse_exited.emit()
