extends Node2D

signal gg_go_next()
signal add_coins(amt)

var coins:int = 0
var has_relic:bool = false

func _ready():
	$NextButton.connect("pressed", _on_nextbtn_pressed)
	$NextButton.set_disabled(false)
#	init([], [Global.abilities[0],Global.abilities[2],Global.abilities[4]])

func init(num_coins: int, r = null):
	coins = num_coins
	$Coins.scale = Vector2.ONE
	$Coins/Text2.text = str(coins) + " coins"
	$Coins.visible = coins > 0
	# TODO relics
	if r:
		$Relic/relic.relic = r
		$Relic/relic.update_sprite()
		$Relic.show()
		has_relic = true
	else:
		$Relic.hide()
		has_relic = false
	update_btn_text()
	$NextButton.set_disabled(false)

func update_btn_text():
	if coins > 0 || has_relic:
		$NextButton.set_text("Skip")
	else:
		$NextButton.set_text("Next")

func _on_nextbtn_pressed():
	gg_go_next.emit()


func _on_button_mouse_entered():
	$Coins.scale = Vector2.ONE * 1.5
	SfxHandler.play_sfx(SfxHandler.COIN_SFX, self, 0.6)


func _on_button_mouse_exited():
	$Coins.scale = Vector2.ONE

func _on_button_pressed():
	add_coins.emit(coins)
	$Coins.visible = false
	coins = 0
	update_btn_text()


func _on_relic_button_pressed():
	GameState.player.add_new_relic($Relic/relic.relic.type)
	Events.emit_signal("relics_updated")
	$Relic/RelicButton.hide()
	$Relic/relic.hide()
	has_relic = false
	update_btn_text()

func _on_relic_button_mouse_entered():
	$Relic/relic._on_color_rect_mouse_entered()

func _on_relic_button_mouse_exited():
	$Relic/relic._on_color_rect_mouse_exited()
