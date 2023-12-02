extends Node2D
class_name Status

var type: AbilityEffect.TYPE
var amount: int = 0

func _init(t:AbilityEffect.TYPE, a: int):
	type = t;
	amount = a

func get_status_name():
	return ""

func add_amount(a: int):
	if a < 0 || amount < 0:
		amount = -1
	else:
		amount += a

func remove_amount(a: int):
	if a < 0 || amount < 0:
		amount = -1
	else:
		amount -= a

func as_string():
	return str(type) + " " + str(amount)
