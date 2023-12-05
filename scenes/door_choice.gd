extends Node2D
class_name DoorChoice

signal door_selected(door)

func _ready():
	$OneDoor/door.connect("door_selected", door_picked.bind(0))
	$TwoDoors/door.connect("door_selected", door_picked.bind(0))
	$TwoDoors/door2.connect("door_selected", door_picked.bind(1))

func init(num_doors:int):
	if num_doors == 1:
		$OneDoor.visible = true
	else:
		$TwoDoors.visible = true

func door_picked(i: int):
	door_selected.emit(i)
