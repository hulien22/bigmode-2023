extends Node

const GROUND_SFX = preload("res://sounds/ground.mp3")
const DICE_SFX = preload("res://sounds/dice.mp3")
const PAPER_SFX = preload("res://sounds/paper.mp3")
const PAPER_HIT_SFX = preload("res://sounds/paper_hit1.mp3")
const PAPER_FLIP_SFX = preload("res://sounds/paperflip1.mp3")
const PAPER_FLICK_SFX = preload("res://sounds/paperflick2.mp3")
const PAPER_FLIP_ROUGH_SFX = preload("res://sounds/roughflip.mp3")
const PAPER_SHIFT_SFX = preload("res://sounds/shift.mp3")
const DOOR_SFX = preload("res://sounds/softtock.mp3")
const DOOR_PICK_SFX = preload("res://sounds/lowtock.mp3")
const COIN_SFX = preload("res://sounds/coin.mp3")

func play_sfx(sound: AudioStream, parent: Node, impact:float):
	if sound == null or parent == null:
		return
	var s = AudioStreamPlayer.new()
#	var s = AudioStreamPlayer3D.new()
	s.stream = sound
	s.volume_db = clamp(remap(impact,0,300,-5,5), -5, 5)
	parent.add_child(s)
	
	s.connect("finished", Callable(free_obj).bind(s))
	s.play()

func free_obj(obj):
	obj.queue_free()
