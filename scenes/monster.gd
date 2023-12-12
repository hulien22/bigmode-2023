extends Resource
class_name Monster

enum MonsterType {
	SLIME, BAT, CULTIST, SHEEP,
	FARMER, BIRDMAN, GOBLIN,
	BATWITHBAT, NYRAT, ARCHER, GHOST,
	MIMIC, YOYOKID, BERSERKER,
	GIANT, PYRO, YETI, KRAKEN,
	GOOSE, HYPNOSNAIL, COOLGUY,
	TWINDRAGON, PIRAT, GUNHOLDER
}

var name_: String
var health: int
var max_health: int
var block: int = 0
var starting_abilities: Array[Ability]
var repeat_abilities: Array[Ability]
var image: CompressedTexture2D
var coins_dropped:int = 2

# elite has 25% more health and uses upgraded abilities?
var is_elite:bool = false

func init_slime():
	max_health = 10
	health = 10
	name_ = "Slime"
#	starting_abilities = [Global.monster_abilities[2]]
	repeat_abilities = [Global.get_monster_ability_by_name("Bite"), Global.get_monster_ability_by_name("Engulf"), Global.get_monster_ability_by_name("Curl Up")]
	image = preload("res://art/characters/slime.png")
	coins_dropped = 2
#	repeat_abilities = [Global.monster_abilities[3]]

func init_monster(m:MonsterType):
	is_elite = false
	match m:
		MonsterType.SLIME:
			max_health = 10
			health = 10
			name_ = "Slime"
			repeat_abilities = [
				Global.get_monster_ability_by_name("Bite"),
				Global.get_monster_ability_by_name("Engulf"),
				Global.get_monster_ability_by_name("Curl Up")]
			image = preload("res://art/characters/slime.png")
			coins_dropped = 2
		MonsterType.BAT:
			max_health = 8
			health = 8
			name_ = "Bat"
			repeat_abilities = [
				Global.get_monster_ability_by_name("Fly"),
				Global.get_monster_ability_by_name("Fly-By"),
				Global.get_monster_ability_by_name("Screech"),
				Global.get_monster_ability_by_name("Bite")]
			image = preload("res://art/characters/bat.png")
			coins_dropped = 2
		MonsterType.CULTIST:
			max_health = 13
			health = 13
			name_ = "Cultist"
			repeat_abilities = [
				Global.get_monster_ability_by_name("Chant"),
				Global.get_monster_ability_by_name("Stab"),
				Global.get_monster_ability_by_name("Burn"),
				Global.get_monster_ability_by_name("Stab")]
			image = preload("res://art/characters/cultist.png")
			coins_dropped = 2
		MonsterType.SHEEP:
			max_health = 12
			health = 12
			name_ = "Shhh-eep"
			repeat_abilities = [
				Global.get_monster_ability_by_name("Snooze"),
				Global.get_monster_ability_by_name("Fluff Up"),
				Global.get_monster_ability_by_name("Headbutt")]
			image = preload("res://art/characters/sheep.png")
			coins_dropped = 2
		MonsterType.FARMER:
			max_health = 15
			health = 15
			name_ = "Farmer"
			repeat_abilities = [
				Global.get_monster_ability_by_name("Burn"),
				Global.get_monster_ability_by_name("Tri-Attack"),
				Global.get_monster_ability_by_name("Harvest")]
			image = preload("res://art/characters/farmer.png")
			coins_dropped = 3
		MonsterType.BIRDMAN:
			max_health = 17
			health = 17
			name_ = "Birdman"
			repeat_abilities = [
				Global.get_monster_ability_by_name("Peck"),
				Global.get_monster_ability_by_name("Fly"),
				Global.get_monster_ability_by_name("Imprison")]
			image = preload("res://art/characters/birdman.png")
			coins_dropped = 3
		MonsterType.GOBLIN:
			max_health = 18
			health = 18
			name_ = "Gobbo"
			starting_abilities = [
				Global.get_monster_ability_by_name("Set Traps")
			]
			repeat_abilities = [
				Global.get_monster_ability_by_name("Trip"),
				Global.get_monster_ability_by_name("Bash"),
				Global.get_monster_ability_by_name("Cower")]
			image = preload("res://art/characters/gobbo.png")
			coins_dropped = 3
		MonsterType.BATWITHBAT:
			max_health = 24
			health = 24
			name_ = "Bat with bat"
			repeat_abilities = [
				Global.get_monster_ability_by_name("Wind Up"),
				Global.get_monster_ability_by_name("Fly Ball"),
				Global.get_monster_ability_by_name("Wind Up"),
				Global.get_monster_ability_by_name("Homerun")]
			image = preload("res://art/characters/batwithbat.png")
			coins_dropped = 4
		MonsterType.NYRAT:
			max_health = 28
			health = 28
			name_ = "NY Rat"
			repeat_abilities = [
				Global.get_monster_ability_by_name("Poison Spray"),
				Global.get_monster_ability_by_name("Crunch"),
				Global.get_monster_ability_by_name("Subway Surf"),
				Global.get_monster_ability_by_name("Cardboard Box")]
			image = preload("res://art/characters/nyrat.png")
			coins_dropped = 4
		MonsterType.ARCHER:
			max_health = 27
			health = 27
			name_ = "Archer"
			starting_abilities = [
				Global.get_monster_ability_by_name("He Shot First")
			]
			repeat_abilities = [
				Global.get_monster_ability_by_name("Duck"),
				Global.get_monster_ability_by_name("Net Arrow"),
				Global.get_monster_ability_by_name("Duck"),
				Global.get_monster_ability_by_name("Barrage")]
			image = preload("res://art/characters/archer.png")
			coins_dropped = 4
		MonsterType.GHOST:
			max_health = 25
			health = 25
			name_ = "Ghost"
			repeat_abilities = [
				Global.get_monster_ability_by_name("Vanish"),
				Global.get_monster_ability_by_name("Lick"),
				Global.get_monster_ability_by_name("Haunt"),
				Global.get_monster_ability_by_name("Wither Touch")]
			image = preload("res://art/characters/ghost.png")
			coins_dropped = 4
	


func get_next_move(turn: int) -> Ability:
	if turn < starting_abilities.size():
		if is_elite:
			return Global.get_upgraded_monster_ability(starting_abilities[turn])
		return starting_abilities[turn]
	
	var ab:Ability = repeat_abilities[(turn - starting_abilities.size()) % repeat_abilities.size()]
	if is_elite:
		return Global.get_upgraded_monster_ability(ab)
	return ab

func set_elite():
	is_elite = true
	name_ += "+"
	max_health *= 1.5
	health = max_health
	coins_dropped = floor(1.5 * coins_dropped)

