extends Node2D

signal gg_go_next()

func _ready():
	$NextButton.connect("pressed", _on_nextbtn_pressed)

func _on_nextbtn_pressed():
	gg_go_next.emit()

func init():
	$NextButton.text = "Skip"
	$Text.text = "You find a ritual circle glowing with power\n\nYour dice tremble in fear\n\nSacrifice a die?"

func sacrificed_die():
	$NextButton.text = "Continue"
	$Text.text = "The die disappears in a blast of dark energy\n\nYou feel the power enter you and strengthen you\n\nMax health increased!"
	GameState.player.max_health += 5
	GameState.player.health += 5
	Events.emit_signal("health_updated")
