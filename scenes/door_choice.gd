extends Node2D
class_name DoorChoice

signal door_selected(game_state:GameState.GameScene)

var doors:Array[GameState.GameScene] = []

func _ready():
	$OneDoor/door.connect("door_selected", door_picked.bind(0))
	$TwoDoors/door.connect("door_selected", door_picked.bind(0))
	$TwoDoors/door2.connect("door_selected", door_picked.bind(1))

func init(d: Array[GameState.GameScene]):
	if d.size() == 1:
		#TODO set the icons of the doors first
		$OneDoor.visible = true
	else:
		$TwoDoors.visible = true
	doors = d

func door_picked(i: int):
	door_selected.emit(doors[i])
