extends Node2D

signal gg_go_next()

func _ready():
	$NextButton.connect("pressed", _on_nextbtn_pressed)
	$NextButton.set_disabled(false)

func _on_nextbtn_pressed():
	gg_go_next.emit()

func init():
	var rels = GameState.generate_new_boss_relics()
	$Relic1/relic.relic = rels[0]
	$Relic1/relic.update_sprite()
	$Relic2/relic.relic = rels[1]
	$Relic2/relic.update_sprite()
	$Relic3/relic.relic = rels[2]
	$Relic3/relic.update_sprite()
	$Relic1.show()
	$Relic2.show()
	$Relic3.show()
	$NextButton.set_text("Skip")

func _on_relic_button_mouse_entered(extra_arg_0):
	match extra_arg_0:
		1:
			$Relic1/relic._on_color_rect_mouse_entered()
		2:
			$Relic2/relic._on_color_rect_mouse_entered()
		_:
			$Relic3/relic._on_color_rect_mouse_entered()


func _on_relic_button_mouse_exited(extra_arg_0):
	match extra_arg_0:
		1:
			$Relic1/relic._on_color_rect_mouse_exited()
		2:
			$Relic2/relic._on_color_rect_mouse_exited()
		_:
			$Relic3/relic._on_color_rect_mouse_exited()

func _on_relic_button_pressed(extra_arg_0):
	$Relic1.hide()
	$Relic2.hide()
	$Relic3.hide()
	$NextButton.set_text("Next")
