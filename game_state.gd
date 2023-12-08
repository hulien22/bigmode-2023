extends Node

enum GameScene {INTRO, DOORS, COMBAT, LOOT, SELECT_ABILITY, DICE_SHOP, REST, RITUAL, ABILITY_SHOP, CHEST, RELIC_SHOP}
# TODO separate rest into ability_upgrade and heal?
# could make heal - heal for value of 2 dice rolls?
const NONCOMBATSCENES:Array[GameScene] = [GameScene.REST, GameScene.DICE_SHOP, GameScene.RITUAL]

var game_scene: GameScene
var level: int = 0
var player: Player
var monsters_fought:Array[Monster.MonsterType] = []

var first_game = true

func _ready():
	reset_game_state()

func reset_game_state():
	game_scene = GameScene.INTRO
	player = Player.new()
	player.init_warrior()
	level = 0
	monsters_fought = []

func generate_next_doors() -> Array[GameScene]:
	# 0 based
	# -----------------------------------
	# 0 Combat
	# 1 Combat
	# 2 NonCombatOption / NonCombatOption
	# 3 Combat          / Elite
	# 4 Chest
	# 5 NonCombatOption / NonCombatOption
	# 6 Combat
	# 7 Combat          / Elite
	# 8 Rest            / NonCombatOption
	# 9 Boss
	# TODO Modulo these for later floors?
	
	# do smth special on first play through? to intro special dice early?
#	if level == 1 && first_game:
#		first_game = false
#		return [GameScene.COMBAT, GameScene.COMBAT]

	match level:
		0,1,6:
			return [GameScene.COMBAT]
		3,7:
			return [GameScene.COMBAT, GameScene.COMBAT]
		2,5:
			var a = randi_range(0, NONCOMBATSCENES.size()-1)
			var b = randi_range(0, NONCOMBATSCENES.size()-1)
			while a == b:
				b = randi_range(0, NONCOMBATSCENES.size()-1)
			return [NONCOMBATSCENES[a],NONCOMBATSCENES[b]]
		8:
			var a = 0
			var b = randi_range(1, NONCOMBATSCENES.size()-1)
			return [NONCOMBATSCENES[a],NONCOMBATSCENES[b]]
		#TODO check for chest spawn, boss spawn, elite spawns
	return [GameScene.COMBAT]



func generate_monster_to_fight() -> Monster.MonsterType:
	var ret: Monster.MonsterType
	ret = Monster.MonsterType.SLIME
	
	monsters_fought.append(ret)
	return ret
