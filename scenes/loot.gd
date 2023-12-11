extends Node2D

signal gg_go_next()
signal add_coins(amt)

var coins:int = 0
var relic = null

func _ready():
	$NextButton.connect("pressed", _on_nextbtn_pressed)
#	init([], [Global.abilities[0],Global.abilities[2],Global.abilities[4]])

func init(num_coins: int, r):
	coins = num_coins
	$Coins.scale = Vector2.ONE
	$Coins/Text2.text = str(coins) + " coins"
	$Coins.visible = coins > 0
	# TODO relics
	if r:
		$Relic.show()
	else:
		$Relic.hide()
	update_btn_text()
	$NextButton.set_disabled(false)

func update_btn_text():
	if coins > 0 || relic != null:
		$NextButton.set_text("Skip")
	else:
		$NextButton.set_text("Next")

func _on_nextbtn_pressed():
	gg_go_next.emit()


func _on_button_mouse_entered():
	$Coins.scale = Vector2.ONE * 1.5


func _on_button_mouse_exited():
	$Coins.scale = Vector2.ONE

func _on_button_pressed():
	add_coins.emit(coins)
	$Coins.visible = false
	coins = 0
	update_btn_text()
