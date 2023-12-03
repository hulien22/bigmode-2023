extends Node2D
class_name StatusObj

# just the node2d representation of a status
var type: AbilityEffect.TYPE
var amount:int

# Called when the node enters the scene tree for the first time.
func init(s: Status):
	type = s.type
	amount = s.amount
	match type:
		AbilityEffect.TYPE.VULNERABLE:
			$holder/Icon.frame = 13
		AbilityEffect.TYPE.STRENGTH:
			$holder/Icon.frame = 16
		_:
			$holder/Icon.frame = 10
	$holder/Value.text = str(amount)

func anim_remove(t: float):
	var tween = get_tree().create_tween()
	var new_posn = $holder.position
	new_posn.y += 10
	tween.set_parallel()
	tween.tween_property($holder, "position", new_posn, t)
	tween.tween_property($holder, "modulate:a", 0.0, t)

func anim_spawn(t:float):
	var tween = get_tree().create_tween()
	$holder.scale = Vector2.ONE * 1.5
	tween.tween_property($holder, "scale", Vector2.ONE, t)

