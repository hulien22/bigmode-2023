extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Icon.position.x += 5
	
	if $Icon.position.x - $Icon.texture.get_width()/2 > 1920:
		$Icon.position.x -= 1920 + $Icon.texture.get_width()


func _on_button_pressed():
	print_debug("PRESSED")
