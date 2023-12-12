extends Node2D
class_name DamageNumbers

func init(dmg:int):
	$Label.text = "-" + str(dmg)

func _ready():
	var tmr = get_tree().create_timer(0.5)
	await tmr.timeout
	$Label.show()
	var tween = get_tree().create_tween()
	tween.set_parallel()
	var new_posn:Vector2 = $Label.position
	new_posn.y += 100
	new_posn.x += randf_range(-50,50)
	tween.tween_property($Label, "position", new_posn, 1)
	tween.tween_property($Label, "modulate:a", 0.0, 1)
	tween.set_parallel(false)
	tween.tween_callback(delete_self)

func delete_self():
	queue_free()
