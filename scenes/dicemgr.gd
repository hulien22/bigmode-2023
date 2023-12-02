extends Node3D
class_name DiceManager

signal complete_roll(results) 

enum STATE {HIDDEN, DROPPING, SELECTING, ANIMATING}
var state: STATE = STATE.HIDDEN

const DIE_SCENE = preload("res://scenes/die.tscn")
var dice:Array

# TODO Tweak to further camera
#var dice_box_rect:Rect2 = Rect2(-9, -2.5, 10.5, 7.5)
var dice_box_rect:Rect2 = Rect2(-7, -2, 9.5, 6)

var die_spacing:float = 1.5

func _ready():
	$Camera3D2.connect("toggle_all", _on_toggle_all)
	$AnimTimer.connect("timeout", _on_animtimer_timeout)
#	for x in 5:
#		add_die()

func _process(delta):
#	if Input.is_action_just_pressed("Launch"):
#		add_die()

	if state == STATE.DROPPING:
		# Check if dice have stopped or not
		if are_all_dice_stopped():
			state = STATE.ANIMATING
			# Move dice over
			var next_die_posn:Vector3 = Vector3(dice_box_rect.position.x, 0.5, dice_box_rect.position.y)
			for d in dice:
				d.enable(false)
				d.rotate_upwards()
				d.animate_slide_to(next_die_posn)
				next_die_posn.x += die_spacing
				if (next_die_posn.x > dice_box_rect.end.x):
					next_die_posn.x = dice_box_rect.position.x
					next_die_posn.z += die_spacing
			# Trigger state transition after all animations complete
			$AnimTimer.start(0.5)

func can_drop() -> bool:
	return state == STATE.HIDDEN || state == STATE.SELECTING

func drop_all_dice():
	if can_drop():
		state = STATE.DROPPING
		$Camera3D2.enable_mouse_events(false)
		for d in dice:
			d.enable(true)
			d.visible = true;
			d.drop()

#todo die type? or type of die or smth
func add_die(faces:Array, die_color:Color):
	var d = DIE_SCENE.instantiate()
	d.init(faces, die_color)
	d.enable(false)
	d.visible = false;
	$Dice.add_child(d)
	dice.push_back(d)

func are_all_dice_stopped() -> bool:
	for d in dice:
		if !d.is_stopped():
			return false
	return true

func _on_toggle_all(val, set_locked):
	for d in dice:
		if d.get_top_val() == val && d.is_locked() != set_locked:
			d.toggle_locked()

func _on_animtimer_timeout():
	state = STATE.SELECTING
	$Camera3D2.enable_mouse_events(true)
	var results:Array = [0, 0, 0, 0, 0, 0]
	for d in dice:
		results[d.get_top_val() - 1] += 1
	complete_roll.emit(results)

func reset_dice():
	for d in dice:
		d.reset_die()

func fade_away_dice():
	for d in dice:
		d.fade_away()
	state = STATE.HIDDEN
