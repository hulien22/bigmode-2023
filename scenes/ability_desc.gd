extends Resource
class_name AbilityDesc

var ab: Ability

var has_limited_uses:bool = false
var limited_uses_left:int = 0

var is_disabled:bool = false

func _init(a:Ability):
	ab = a
	for e in ab.effects_:
		match e.type_:
			AbilityEffect.TYPE.LIMITED_USES:
				has_limited_uses = true
				limited_uses_left = int(e.value_)

