extends Node

var player: Player

func _ready():
	reset_game_state()

func reset_game_state():
	player = Player.new()
	player.init_warrior()
