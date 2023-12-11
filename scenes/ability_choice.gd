extends Node2D
class_name AbilityChoice

signal gg_go_next()

# combat ability boxes (player has list of their current abilities)
var ability_boxes:Array[AbilityBox] = []

func _ready():
	$NextButton.connect("pressed", _on_nextbtn_pressed)
	$NextButton.set_disabled(false)
#	init([], [Global.abilities[0],Global.abilities[2],Global.abilities[4]])

func init(ab: Array[AbilityBox], new_ab: Array[Ability]):
	ability_boxes = ab
	$Abilities/ability_box1.init(0, new_ab[0])
	$Abilities/ability_box2.init(0, new_ab[1])
	$Abilities/ability_box3.init(0, new_ab[2])
	
	$Abilities/ability_box1.connect("ability_clicked", _on_new_ability_clicked.bind(1))
	$Abilities/ability_box2.connect("ability_clicked", _on_new_ability_clicked.bind(2))
	$Abilities/ability_box3.connect("ability_clicked", _on_new_ability_clicked.bind(3))
	
	_go_back_to_selection(0, 0)


func _on_new_ability_clicked(_unused, val):
	$Abilities/ability_box1.disconnect("ability_clicked", _on_new_ability_clicked)
	$Abilities/ability_box2.disconnect("ability_clicked", _on_new_ability_clicked)
	$Abilities/ability_box3.disconnect("ability_clicked", _on_new_ability_clicked)
	
	$Abilities/ability_box1.modulate.a = 0.5
	$Abilities/ability_box2.modulate.a = 0.5
	$Abilities/ability_box3.modulate.a = 0.5
	
	match val:
		1:
			$Abilities/ability_box1.connect("ability_clicked", _go_back_to_selection.bind(1))
			$Abilities/ability_box1.modulate.a = 1
		2:
			$Abilities/ability_box2.connect("ability_clicked", _go_back_to_selection.bind(2))
			$Abilities/ability_box2.modulate.a = 1
		3:
			$Abilities/ability_box3.connect("ability_clicked", _go_back_to_selection.bind(3))
			$Abilities/ability_box3.modulate.a = 1
	
	for ab in ability_boxes:
		ab.connect("ability_clicked", _on_ability_clicked.bind(val))
		ab.set_enabled(true)
	$Text.text = "Pick an ability to swap with"
	$NextButton.set_disabled(true)


func _go_back_to_selection(_unused, val):
	$Abilities/ability_box1.modulate.a = 1
	$Abilities/ability_box2.modulate.a = 1
	$Abilities/ability_box3.modulate.a = 1
	
	match val:
		1:
			$Abilities/ability_box1.disconnect("ability_clicked", _go_back_to_selection)
		2:
			$Abilities/ability_box2.disconnect("ability_clicked", _go_back_to_selection)
		3:
			$Abilities/ability_box3.disconnect("ability_clicked", _go_back_to_selection)
		
	if val > 0:
		$Abilities/ability_box1.connect("ability_clicked", _on_new_ability_clicked.bind(1))
		$Abilities/ability_box2.connect("ability_clicked", _on_new_ability_clicked.bind(2))
		$Abilities/ability_box3.connect("ability_clicked", _on_new_ability_clicked.bind(3))
		for ab in ability_boxes:
			ab.disconnect("ability_clicked", _on_ability_clicked)
			ab.set_enabled(false)
	$Text.text = "Pick a new ability!"
	$NextButton.set_disabled(false)
	$NextButton.set_text("Skip")
	$Abilities.show()
	

func _on_ability_clicked(val, selected_val):
	var new_ability: Ability
	match selected_val:
		1:
			new_ability = $Abilities/ability_box1.ability
			$Abilities/ability_box1.disconnect("ability_clicked", _go_back_to_selection)
		2:
			new_ability = $Abilities/ability_box2.ability
			$Abilities/ability_box2.disconnect("ability_clicked", _go_back_to_selection)
		_:
			new_ability = $Abilities/ability_box3.ability
			$Abilities/ability_box3.disconnect("ability_clicked", _go_back_to_selection)
	
	GameState.player.abilities[val - 1] = new_ability 
	ability_boxes[val - 1].init(val, new_ability)
	for ab in ability_boxes:
		ab.disconnect("ability_clicked", _on_ability_clicked)
		ab.set_enabled(false)
	
	$Abilities.hide()
	$Text.text = "New ability gained!"
	
	$NextButton.set_disabled(false)
	$NextButton.set_text("Next")


func _on_nextbtn_pressed():
	gg_go_next.emit()
