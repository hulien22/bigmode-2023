extends Node

enum GameScene {INTRO, DOORS, COMBAT, LOOT, SELECT_ABILITY, DICE_SHOP, REST}

var game_scene: GameScene
var level: int = 0
var player: Player

var first_game = true

func _ready():
	reset_game_state()

func reset_game_state():
	game_scene = GameScene.INTRO
	player = Player.new()
	player.init_warrior()
	level = 0

func generate_next_doors() -> Array[GameScene]:
	if level == 0:
		return [GameScene.INTRO]
	if level == 1 && first_game:
		first_game = false
		return [GameScene.COMBAT, GameScene.COMBAT]
	#TODO check for chest spawn, boss spawn, etc
	return [GameScene.COMBAT, GameScene.COMBAT]
