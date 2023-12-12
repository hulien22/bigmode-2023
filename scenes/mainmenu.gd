extends Node2D

func _ready():
	$PlayWarrior.set_disabled(false)
	print("menu ready!")



# Called when the node enters the scene tree for the first time.
#func _ready():
#	$SubViewportContainer/SubViewport/DiceMgr.line_up_dice_after_roll = false
##	$SubViewportContainer/SubViewport/DiceMgr.line_up_dice_after_roll = false
#	$SubViewportContainer/SubViewport/DiceMgr.dice_box_rect = Rect2(-7, -1.5, 4, 5.5)
#	$SubViewportContainer/SubViewport/DiceMgr.connect("complete_roll", complete_roll)
#	$SubViewportContainer/SubViewport/DiceMgr.mouse_handler.remove_on_select = false
#	$SubViewportContainer/SubViewport/DiceMgr.dice.clear()
#	for i in 5:
#		$SubViewportContainer/SubViewport/DiceMgr.add_die(DiceConstructor.generate_random_die(), DiceConstructor.generate_random_die_color())
#	$SubViewportContainer/SubViewport/DiceMgr.drop_all_dice()
#
#func complete_roll(_v):
#	$SubViewportContainer/SubViewport/DiceMgr.throw_all_dice()


func _on_play_btn_mouse_exited():
	$Desc.text = ""

func _on_play_warrior_mouse_entered():
	$Desc.text = "A balanced fighter\nEmploys a variety of combat techniques\nStarts with Trusty Shield"

func _on_play_rogue_mouse_entered():
	$Desc.text = "(Coming soon)\nA nimble trickster\nUses daggers and poisons\nStarts with Lockpicks"

func _on_play_wizard_mouse_entered():
	$Desc.text = "(Coming soon)\nA powerful spellcaster\nHas a large arsenal of spells\nStarts with Oaken Staff"

@export var COMBAT_SCENE: PackedScene
func _on_play_warrior_pressed():
	get_tree().change_scene_to_packed(COMBAT_SCENE)
#	var s = COMBAT_SCENE.instantiate()
#	get_tree().root.add_child(s)
#	queue_free()

