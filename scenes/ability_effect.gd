extends Resource
class_name AbilityEffect

enum TARGET { PLAYER, MONSTER, NOONE }
enum TYPE { DAMAGE, SHIELD, VULNERABLE, STRENGTH, LIMITED_USES, HEAL, SELF_DMG }
#             0       1         2          3           4         5      6

var target_: TARGET;
var type_: TYPE;
var value_: String;

var uses_left:int = 0

func _init(target: int, type: int, value: String):
	target_ = target;
	type_ = type;
	value_ = value;
	if type_ == TYPE.LIMITED_USES:
		uses_left = int(value_)

func process_value(x:int) -> int:
	var expr = Expression.new()
	expr.parse(value_, ["x"])
	# todo replace other things
	return expr.execute([x])

func is_status_inflict() -> bool:
	match type_:
		TYPE.VULNERABLE:
			return true
		_:
			return false

static func get_status_desc(t:TYPE) -> String:
	match t:
		TYPE.SHIELD:
			return "Shield: Blocks damage, lasts between turns"
		TYPE.VULNERABLE:
			return "Vulnerable: Take double damage"
		TYPE.STRENGTH:
			return "Strength: Deal extra damage"
		_:
			return ""
		
