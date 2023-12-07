extends Node
class_name Ability

var name_: String;
var desc_: String;
var effects_: Array[AbilityEffect];

func _init(name: String, desc: String, effects: Array):
	name_ = name;
	desc_ = desc;
	effects_ = [];
	for e in effects:
		assert(e.size() >= 3);
		effects_.append(AbilityEffect.new(e[0],e[1],str(e[2])))

func is_upgradeable() -> bool:
	return !name_.ends_with("+")
