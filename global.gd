extends Node

var abilities_file: Resource = preload("res://abilities.json");
var data
var abilities: Array[Ability];
var monster_abilities: Array[Ability];
var disabled_ability: Ability
var depleted_ability: Ability
var common_abilities: Array[Ability];
var uncommon_abilities: Array[Ability];
var rare_abilities: Array[Ability];

func _ready():
	var file = FileAccess.open(abilities_file.resource_path, FileAccess.READ)
	data = JSON.parse_string(file.get_as_text())
	load_abilities()

func load_abilities():
	for a in data.abilities:
		assert(a.size() >= 4)
		abilities.append(Ability.new(a[0],a[1],a[2],a[3]))
		if !a[0].ends_with("+"):
			if a[3] == 1:
				common_abilities.append(abilities.back())
			elif a[3] == 2:
				uncommon_abilities.append(abilities.back())
			elif a[3] == 3:
				rare_abilities.append(abilities.back())
	for a in data.monster_abilities:
		assert(a.size() >= 3)
		monster_abilities.append(Ability.new(a[0],a[1],a[2]))
	disabled_ability = Ability.new("+Disabled+", "This ability has been disabled!", [])
	depleted_ability = Ability.new("+Depleted+", "You've used up all uses of this ability for this combat!", [])
	print("commons ", common_abilities.size())
	print("uncommons ", uncommon_abilities.size())
	print("rares ", rare_abilities.size())

	generate_abilities(3, 5)
	generate_abilities(3, 5)
	generate_abilities(3, 5)

func get_upgraded_ability(a:Ability) -> Ability:
	for x in abilities:
		if x.name_ == a.name_ + "+":
			return x
	print_debug("could not find upgraded ability for ", a.name_)
	return a

func get_ability_by_name(n:String) -> Ability:
	for x in abilities:
		if x.name_ == n:
			return x
	print_debug("could not find ability for ", n)
	return disabled_ability

func get_monster_ability_by_name(n:String) -> Ability:
	for x in monster_abilities:
		if x.name_ == n:
			return x
	print_debug("could not find monster ability for ", n)
	return disabled_ability

func get_upgraded_monster_ability(a:Ability) -> Ability:
	for x in monster_abilities:
		if x.name_ == a.name_ + "+":
			return x
	print_debug("could not find upgraded monster ability for ", a.name_)
	return a

func generate_abilities(num:int, level:int) -> Array[Ability]:
	var ret: Array[Ability] = []
	for i in num:
		var new_ability: Ability = null
		while new_ability == null || ret.has(new_ability):
			var chance = randi() % 100
			if chance < 5 + (level / 2):
				# generate rare
				new_ability = rare_abilities.pick_random()
			elif chance < 20 + (level / 2):
				new_ability = uncommon_abilities.pick_random()
			else:
				new_ability = common_abilities.pick_random()
		ret.append(new_ability)
	for i in ret.size():
		#check if we should upgrade them
		if (randi() % 100) < level:
			ret[i] = get_upgraded_ability(ret[i])
	return ret
