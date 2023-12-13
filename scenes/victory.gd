extends Node2D

signal gg_go_home()

func _ready():
	$MainMenu.set_disabled(false)

func _on_main_menu_pressed():
	gg_go_home.emit()
