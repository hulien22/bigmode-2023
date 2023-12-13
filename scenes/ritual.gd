extends Node2D

signal gg_go_next()

func _ready():
	$NextButton.connect("pressed", _on_nextbtn_pressed)
	$NextButton.set_disabled(false)

func _on_nextbtn_pressed():
	gg_go_next.emit()

func init():
	$NextButton.set_text("Skip")
	$Text.text = "You find a ritual circle glowing with power\n\nYour dice tremble in fear\n\nSacrifice a die?"

func sacrificed_die():
	$NextButton.set_text("Continue")
	if randi_range(0,3) <= 2 || GameState.player.has_relic(Relic.TYPE.GREED): #75% chance
		$Text.text = "The die disappears in a blast of dark energy\n\nYou feel a surge of power strengthen you\n\nMax health increased!"
		GameState.player.max_health += 5
		GameState.player.health += 5
		Events.emit_signal("health_updated")
	else:
		$Text.text = "The die disappears in a blast of golden energy\n\nA pile of gold appears in front of you\n\nGained 10 coins!"
		GameState.player.coins += 10
		Events.emit_signal("coins_updated")
		
