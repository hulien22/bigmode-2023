extends Node2D

signal gg_go_next()

func _ready():
	$NextButton.connect("pressed", _on_nextbtn_pressed)
	$NextButton.set_disabled(false)

func _on_nextbtn_pressed():
	gg_go_next.emit()

func init(r: Relic):
	$NextButton.set_text("Skip")
	$Text.text = "You find a chest with some cool treasure inside!"
	$relic.relic = r
	$relic.update_sprite()
	$relic.show()
	$RelicButton.show()

func _on_relic_button_pressed():
	GameState.player.add_new_relic($relic.relic.type)
	Events.emit_signal("relics_updated")
	$RelicButton.hide()
	$relic.hide()
	$NextButton.set_text("Next")
	$Text.text = "You loot the chest!"


func _on_relic_button_mouse_entered():
	$relic._on_color_rect_mouse_entered()


func _on_relic_button_mouse_exited():
	$relic._on_color_rect_mouse_exited()
