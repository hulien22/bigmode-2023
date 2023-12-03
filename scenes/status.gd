class_name Status

var type: AbilityEffect.TYPE
var amount: int = 0
var reduce_at_newturn: bool = false

func _init(t:AbilityEffect.TYPE, a: int, autoreduce: bool):
	type = t;
	amount = a
	reduce_at_newturn = autoreduce

func get_status_name():
	return ""

func add_amount(a: int):
	amount += a

func as_string():
	return str(type) + " " + str(amount)

# func right click display tooltip

