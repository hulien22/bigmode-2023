class_name Monster

enum MonsterType {SLIME}

var name_: String
var health: int
var max_health: int
var block: int = 0
var starting_abilities: Array[Ability]
var repeat_abilities: Array[Ability]
var image: CompressedTexture2D
var coins_dropped:int = 2

func init_slime():
	max_health = 10
	health = 10
	name_ = "Slime"
	starting_abilities = [Global.monster_abilities[2]]
	repeat_abilities = [Global.monster_abilities[0], Global.monster_abilities[1], Global.monster_abilities[2]]
	image = preload("res://art/characters/slime.png")
	coins_dropped = 2
#	repeat_abilities = [Global.monster_abilities[3]]


func get_next_move(turn: int) -> Ability:
	if turn < starting_abilities.size():
		return starting_abilities[turn]
	return repeat_abilities[(turn - starting_abilities.size()) % repeat_abilities.size()]
