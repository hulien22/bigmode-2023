extends Node

enum GameScene {INTRO, COMBAT}

var game_scene: GameScene
var level: int = 0
var player: Player

func _ready():
	reset_game_state()

func reset_game_state():
	game_scene = GameScene.INTRO
	player = Player.new()
	player.init_warrior()

