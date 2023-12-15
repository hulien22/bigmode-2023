extends Node2D
class_name NumberModifier

func init_fire():
	$Label.text = "(+1)"
	$Label.modulate = Color("d60a0a")

func init_freeze():
	$Label.text = "(-1)"
	$Label.modulate = Color("0460ff")
