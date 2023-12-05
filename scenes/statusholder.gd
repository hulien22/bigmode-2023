extends Node2D
class_name StatusHolder

const STATUSOBJ_SCENE = preload("res://scenes/statusobj.tscn")
# has idea of what statuses are there
var cur_statuses: Array[StatusObj] = []
var status_width: float = 90.0
var padding: float = 10.0

@export var dir:int = 1

func update_statuses(new_statuses: Array):
	# update our current statuses, keep track of which ones to play some kind of animation for
	# first check if any statuses are removed
#	print("update_statuses")
	var need_wait:bool = false
	var anim_time = 0.5
	for s in cur_statuses:
		if !StatusHolder.contains_type(new_statuses, s.type):
			need_wait = true
			s.anim_remove(anim_time)
	if need_wait:
#		print("wait for removal")
		var tmr = get_tree().create_timer(anim_time)
		await tmr.timeout
	
	# keep track of which statuses got updated and need animating on spawn
	var needs_anim: Array[bool] = []
	for i in new_statuses.size():
		needs_anim.append(was_updated(new_statuses[i].type, new_statuses[i].amount))
	
	# remove all cur status objects
	for s in cur_statuses:
		s.queue_free()
	cur_statuses.clear()
	
	need_wait = false
	for i in new_statuses.size():
		var obj = STATUSOBJ_SCENE.instantiate()
		obj.init(new_statuses[i])
		obj.position.x = i * (status_width + padding) * dir
		cur_statuses.append(obj)
		add_child(obj)
		if needs_anim[i]:
			obj.anim_spawn(anim_time)
			need_wait = true
	if need_wait:
#		print("wait for spawn")
		var tmr = get_tree().create_timer(anim_time)
		await tmr.timeout
	

func was_updated(t: AbilityEffect.TYPE, new_amount:int) -> bool:
	for s in cur_statuses:
		if s.type == t:
			return s.amount != new_amount
	# else didn't exist before, so is new
	return true

static func contains_type(statuses: Array, t: AbilityEffect.TYPE) -> bool:
	for s in statuses:
		if s.type == t:
			return true
	return false
