extends Node

var abilities_file: Resource = preload("res://abilities.json");
var data
var abilities: Array[Ability];
var monster_abilities: Array[Ability];

func _ready():
	var file = FileAccess.open(abilities_file.resource_path, FileAccess.READ)
	data = JSON.parse_string(file.get_as_text())
	load_abilities()

func load_abilities():
	for a in data.abilities:
		assert(a.size() >= 3)
		abilities.append(Ability.new(a[0],a[1],a[2]))
	for a in data.monster_abilities:
		assert(a.size() >= 3)
		monster_abilities.append(Ability.new(a[0],a[1],a[2]))

func get_upgraded_ability(a:Ability) -> Ability:
	for x in abilities:
		if x.name_ == a.name_ + "+":
			return x
	print_debug("could not find upgraded ability for ", a.name_)
	return a
