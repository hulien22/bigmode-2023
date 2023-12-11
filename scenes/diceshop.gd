extends Node2D

signal gg_go_next()

func _ready():
	$NextButton.connect("pressed", _on_nextbtn_pressed)
	$NextButton.set_disabled(false)

func _on_nextbtn_pressed():
	gg_go_next.emit()

