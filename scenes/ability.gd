extends Resource
class_name Ability

enum RARITY {BASIC, COMMON, UNCOMMON, RARE}

var name_: String;
var desc_: String;
var effects_: Array[AbilityEffect];
var rarity_:RARITY = RARITY.BASIC

func _init(name: String, desc: String, effects: Array, rarity: RARITY = RARITY.BASIC):
	name_ = name;
	desc_ = desc;
	effects_ = [];
	for e in effects:
		if typeof(e) == TYPE_ARRAY:
			assert(e.size() >= 3);
			effects_.append(AbilityEffect.new(e[0],e[1],str(e[2])))
		else:
			# effect
			effects_.append(AbilityEffect.new(e.target_,e.type_,e.value_))
	rarity_ = rarity

func is_upgradeable() -> bool:
	return !name_.ends_with("+")

func get_effect_descs() -> String:
	var extras:String = ""
	for e in effects_:
		var s: String = AbilityEffect.get_status_desc(e.type_)
		if !s.is_empty():
			extras += "\n" + s
	if extras.is_empty():
		return ""
	return "\n---" + extras

func copy_from(a: Ability):
	_init(a.name_, a.desc_, a.effects_, a.rarity_)
