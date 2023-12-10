extends Resource
class_name AbilityEffect

enum TARGET { PLAYER, MONSTER, NOONE }
enum TYPE {
	DAMAGE,				#0
	SHIELD,				#1
	VULNERABLE,			#2
	STRENGTH,			#3
	LIMITED_USES,		#4
	HEAL,				#5
	SELF_DMG,			#6
	DISABLE_ABILITY1,	#7 
	DISABLE_ABILITY2,	#8
	DISABLE_ABILITY3,	#9 
	DISABLE_ABILITY4,	#10 
	DISABLE_ABILITY5,	#11
	DISABLE_ABILITY6,	#12
	DISABLE_ABILITYR,	#13
}

var target_: TARGET;
var type_: TYPE;
var value_: String;

func _init(target: int, type: int, value: String):
	target_ = target;
	type_ = type;
	value_ = value;

func process_value(x:int, f:int) -> int:
	var expr = Expression.new()
	expr.parse(value_, ["x", "f"])
	# todo replace other things
	return expr.execute([x, f])

func is_status_inflict() -> bool:
	match type_:
		TYPE.VULNERABLE:
			return true
		TYPE.DISABLE_ABILITY1:
			return true
		TYPE.DISABLE_ABILITY2:
			return true
		TYPE.DISABLE_ABILITY3:
			return true
		TYPE.DISABLE_ABILITY4:
			return true
		TYPE.DISABLE_ABILITY5:
			return true
		TYPE.DISABLE_ABILITY6:
			return true
		TYPE.DISABLE_ABILITYR:
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
		TYPE.DISABLE_ABILITY1:
			return "Disabled 1: Can't use your 1st ability"
		TYPE.DISABLE_ABILITY2:
			return "Disabled 2: Can't use your 2nd ability"
		TYPE.DISABLE_ABILITY3:
			return "Disabled 3: Can't use your 3rd ability"
		TYPE.DISABLE_ABILITY4:
			return "Disabled 4: Can't use your 4th ability"
		TYPE.DISABLE_ABILITY5:
			return "Disabled 5: Can't use your 5th ability"
		TYPE.DISABLE_ABILITY6:
			return "Disabled 6: Can't use your 6th ability"
		TYPE.DISABLE_ABILITYR:
			return "Disabled R: Can't use a random ability"
		_:
			return ""
		
