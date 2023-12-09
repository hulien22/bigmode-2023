extends Node

var abilities_file: Resource = preload("res://abilities.json");
var data
var abilities: Array[Ability];
var monster_abilities: Array[Ability];
var disabled_ability: Ability
var depleted_ability: Ability

func _ready():
	var file = FileAccess.open(abilities_file.resource_path, FileAccess.READ)
	data = JSON.parse_string(file.get_as_text())
	load_abilities()

func load_abilities():
	for a in data.abilities:
		assert(a.size() >= 4)
		abilities.append(Ability.new(a[0],a[1],a[2],a[3]))
	for a in data.monster_abilities:
		assert(a.size() >= 3)
		monster_abilities.append(Ability.new(a[0],a[1],a[2]))
	disabled_ability = Ability.new("+Disabled+", "This ability has been disabled!", [])
	depleted_ability = Ability.new("+Depleted+", "You've used up all uses of this ability for this combat!", [])

func get_upgraded_ability(a:Ability) -> Ability:
	for x in abilities:
		if x.name_ == a.name_ + "+":
			return x
	print_debug("could not find upgraded ability for ", a.name_)
	return a
