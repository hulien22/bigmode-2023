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

var type: MonsterType = MonsterType.SLIME
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
var is_boss:bool = false
var can_breath_attack: bool = false

#func init_slime():
#	max_health = 10
#	health = 10
#	name_ = "Slime"
##	starting_abilities = [Global.monster_abilities[2]]
#	repeat_abilities = [Global.get_monster_ability_by_name("Bite"), Global.get_monster_ability_by_name("Engulf"), Global.get_monster_ability_by_name("Curl Up")]
#	image = preload("res://art/characters/slime.png")
#	coins_dropped = 2
##	repeat_abilities = [Global.monster_abilities[3]]

func init_monster(m:MonsterType):
	is_elite = false
	is_boss = false
	can_breath_attack = false
	type = m
	starting_abilities = []
	repeat_abilities = []
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
			coins_dropped = 2
		MonsterType.BIRDMAN:
			max_health = 17
			health = 17
			name_ = "Birdman"
			repeat_abilities = [
				Global.get_monster_ability_by_name("Peck"),
				Global.get_monster_ability_by_name("Fly"),
				Global.get_monster_ability_by_name("Imprison")]
			image = preload("res://art/characters/birdman.png")
			coins_dropped = 2
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
			coins_dropped = 2
		MonsterType.COOLGUY:
			max_health = 24
			health = 24
			name_ = "Cool Guy"
			repeat_abilities = [
				Global.get_monster_ability_by_name("Dazzle"),
				Global.get_monster_ability_by_name("Cold Touch"),
				Global.get_monster_ability_by_name("Stunning Smile")]
			image = preload("res://art/characters/coolguy.png")
			coins_dropped = 2
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
			coins_dropped = 3
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
			coins_dropped = 3
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
			coins_dropped = 3
		MonsterType.MIMIC:
			max_health = 33
			health = 33
			name_ = "Mimic"
			repeat_abilities = [
				Global.get_monster_ability_by_name("Vanish"),
				Global.get_monster_ability_by_name("Lick"),
				Global.get_monster_ability_by_name("Haunt"),
				Global.get_monster_ability_by_name("Wither Touch"),
				Global.get_monster_ability_by_name("Hypnotize"),
				Global.get_monster_ability_by_name("Nosegrind"),
				Global.get_monster_ability_by_name("180"),
				Global.get_monster_ability_by_name("Ollie"),
				Global.get_monster_ability_by_name("Net Arrow"),
				Global.get_monster_ability_by_name("Duck"),
				Global.get_monster_ability_by_name("Barrage"),
				Global.get_monster_ability_by_name("Wind Up"),
				Global.get_monster_ability_by_name("Whirlwind"),
				Global.get_monster_ability_by_name("Smash"),
				Global.get_monster_ability_by_name("Poison Spray"),
				Global.get_monster_ability_by_name("Toughen Up"),
				Global.get_monster_ability_by_name("Imprison")]
			image = preload("res://art/characters/mimic.png")
			coins_dropped = 3
		MonsterType.YOYOKID:
			max_health = 31
			health = 31
			name_ = "Yo-Yo Kid"
			repeat_abilities = [
				Global.get_monster_ability_by_name("Hypnotize"),
				Global.get_monster_ability_by_name("Nosegrind"),
				Global.get_monster_ability_by_name("Ollie"),
				Global.get_monster_ability_by_name("180"),]
			image = preload("res://art/characters/yoyokid.png")
			coins_dropped = 3
		MonsterType.BERSERKER:
			max_health = 70
			health = 70
			name_ = "Berserker"
			starting_abilities = [
				Global.get_monster_ability_by_name("Time To Rage")]
			repeat_abilities = [
				Global.get_monster_ability_by_name("Whirlwind"),
				Global.get_monster_ability_by_name("Smash"),
				Global.get_monster_ability_by_name("Toughen Up")]
			image = preload("res://art/characters/viking.png")
			coins_dropped = 3
		MonsterType.GIANT:
			max_health = 60
			health = 30
			name_ = "Injured Giant"
			repeat_abilities = [
				Global.get_monster_ability_by_name("Stomp"),
				Global.get_monster_ability_by_name("Giant Regen")]
			image = preload("res://art/characters/giant.png")
			coins_dropped = 4
		MonsterType.PYRO:
			max_health = 12
			health = 12
			name_ = "Pyro"
			starting_abilities = [
				Global.get_monster_ability_by_name("Mage Armor")]
			repeat_abilities = [
				Global.get_monster_ability_by_name("Fireball!"),
				Global.get_monster_ability_by_name("Fireball!!"),
				Global.get_monster_ability_by_name("Fireball!!!"),
				Global.get_monster_ability_by_name("Prep Spells")]
			image = preload("res://art/characters/wizard.png")
			coins_dropped = 4
		MonsterType.YETI:
			max_health = 36
			health = 36
			name_ = "Yeti"
			repeat_abilities = [
				Global.get_monster_ability_by_name("Freeze Gaze"),
				Global.get_monster_ability_by_name("Snowball"),
				Global.get_monster_ability_by_name("Snow Fort")]
			image = preload("res://art/characters/yeti.png")
			coins_dropped = 4
		MonsterType.KRAKEN:
			max_health = 38
			health = 38
			name_ = "Kraken"
			repeat_abilities = [
				Global.get_monster_ability_by_name("Blinding Strike"),
				Global.get_monster_ability_by_name("Jet Off"),
				Global.get_monster_ability_by_name("Octo Whip"),
				Global.get_monster_ability_by_name("Entangle")]
			image = preload("res://art/characters/squid.png")
			coins_dropped = 4
		MonsterType.GOOSE:
			max_health = 36
			health = 36
			name_ = "Canada Goose"
			repeat_abilities = [
				Global.get_monster_ability_by_name("Poop"),
				Global.get_monster_ability_by_name("Fly"),
				Global.get_monster_ability_by_name("Poop"),
				Global.get_monster_ability_by_name("Fly"),
				Global.get_monster_ability_by_name("Vicious Bite")]
			image = preload("res://art/characters/goose.png")
			coins_dropped = 4
		MonsterType.HYPNOSNAIL:
			max_health = 30
			health = 30
			name_ = "Hypno-Snail"
			starting_abilities = [
				Global.get_monster_ability_by_name("Shell Armor")]
			repeat_abilities = [
				Global.get_monster_ability_by_name("Hypnotize"),
				Global.get_monster_ability_by_name("Head Flail")]
			image = preload("res://art/characters/snail.png")
			coins_dropped = 4
		MonsterType.BATWITHBAT:
			max_health = 37
			health = 37
			name_ = "Bat with bat"
			repeat_abilities = [
				Global.get_monster_ability_by_name("Wind Up"),
				Global.get_monster_ability_by_name("Fly Ball"),
				Global.get_monster_ability_by_name("Wind Up"),
				Global.get_monster_ability_by_name("Homerun")]
			image = preload("res://art/characters/batwithbat.png")
			coins_dropped = 4
		MonsterType.TWINDRAGON:
			is_boss = true
			can_breath_attack = true
			max_health = 30
			health = 30
			name_ = "Two-headed Dragon"
			starting_abilities = [
				Global.get_monster_ability_by_name("Cold Breath"),
				Global.get_monster_ability_by_name("Fire Breath")]
			repeat_abilities = [
				Global.get_monster_ability_by_name("Dragon Fear"),
				Global.get_monster_ability_by_name("Flame Claws"),
				Global.get_monster_ability_by_name("Fly"),
				Global.get_monster_ability_by_name("Icy Tail")]
			image = preload("res://art/characters/twoheaddragon.png")
			coins_dropped = 5
		MonsterType.PIRAT:
			is_boss = true
			max_health = 40
			health = 40
			name_ = "Pi-Rat-e"
			starting_abilities = [
				Global.get_monster_ability_by_name("Burlap Sack")]
			repeat_abilities = [
				Global.get_monster_ability_by_name("Trap"),
				Global.get_monster_ability_by_name("Leftovers"),
				Global.get_monster_ability_by_name("Steal"),
				Global.get_monster_ability_by_name("Sneak")]
			image = preload("res://art/characters/ratthief.png")
			coins_dropped = 5
		MonsterType.GUNHOLDER:
			is_boss = true
			max_health = 50
			health = 50
			name_ = "Gunholder"
			starting_abilities = [
				Global.get_monster_ability_by_name("All Seeing Eye")]
			repeat_abilities = [
				Global.get_monster_ability_by_name("Paralyze Gun"),
				Global.get_monster_ability_by_name("Fear Gun"),
				Global.get_monster_ability_by_name("Confuse Gun"),
				Global.get_monster_ability_by_name("Big Gun"),
				Global.get_monster_ability_by_name("Blind Gun"),
				Global.get_monster_ability_by_name("Heal Gun")]
			image = preload("res://art/characters/gunholder.png")
			coins_dropped = 5
	


func get_next_move(turn: int, last_mode_used: int) -> Ability:
	# bosses
	if type == MonsterType.TWINDRAGON:
		if turn == 0 || can_breath_attack:
			return starting_abilities.pick_random()
		return repeat_abilities.pick_random()
	if type == MonsterType.GUNHOLDER:
		if turn == 0:
			return starting_abilities[0]
		return repeat_abilities[last_mode_used]

	if type == MonsterType.MIMIC:
		if is_elite:
			return Global.get_upgraded_monster_ability(repeat_abilities.pick_random())
		return repeat_abilities.pick_random()
	
	if turn < starting_abilities.size():
		if is_elite:
			return Global.get_upgraded_monster_ability(starting_abilities[turn])
		return starting_abilities[turn]
	
	var ab:Ability = repeat_abilities[(turn - starting_abilities.size()) % repeat_abilities.size()]
	if is_elite:
		return Global.get_upgraded_monster_ability(ab)
	return ab

func set_elite():
	if is_boss:
		return
	is_elite = true
	name_ += "+"
	max_health *= 1.5
	health *= 1.5
	coins_dropped = floor(1.5 * coins_dropped)

