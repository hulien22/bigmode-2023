extends Node
class_name AbilityEffect

enum TARGET { PLAYER, MONSTER }
enum TYPE { DAMAGE, SHIELD, VULNERABLE, STRENGTH }

var target_: TARGET;
var type_: TYPE;
var value_: String;

func _init(target: int, type: int, value: String):
	target_ = target;
	type_ = type;
	value_ = value;

func process_value(x:int) -> int:
	var expr = Expression.new()
	expr.parse(value_, ["x"])
	# todo replace other things
	return expr.execute([x])
