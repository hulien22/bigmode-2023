extends Node

var FACE1 = preload("res://art/d6face1.png")
var FACE2 = preload("res://art/d6face2.png")
var FACE3 = preload("res://art/d6face3.png")
var FACE4 = preload("res://art/d6face4.png")
var FACE5 = preload("res://art/d6face5.png")
var FACE6 = preload("res://art/d6face6.png")
#var FACE1 = Image.load_from_file("res://art/sketchd6_1.png")
#var FACE2 = Image.load_from_file("res://art/sketchd6_2.png")
#var FACE3 = Image.load_from_file("res://art/sketchd6_3.png")
#var FACE4 = Image.load_from_file("res://art/sketchd6_4.png")
#var FACE5 = Image.load_from_file("res://art/sketchd6_5.png")
#var FACE6 = Image.load_from_file("res://art/sketchd6_6.png")

var FACES = [FACE1.get_image(), FACE2.get_image(), FACE3.get_image(), FACE4.get_image(), FACE5.get_image(), FACE6.get_image()]

func construct_die(dice_faces:Array) -> ImageTexture:
	assert(dice_faces.size() == 6)
	var img1:Image = stack_images([FACES[dice_faces[0]-1], FACES[dice_faces[1]-1], FACES[dice_faces[2]-1]])
	var img2:Image = stack_images([FACES[dice_faces[3]-1], FACES[dice_faces[4]-1], FACES[dice_faces[5]-1]])
	img1.rotate_90(COUNTERCLOCKWISE)
	img2.rotate_90(COUNTERCLOCKWISE)
	
	return ImageTexture.create_from_image(stack_images([img1, img2]));

func stack_images(imgs:Array) -> Image:
	var data: PackedByteArray = PackedByteArray()
	for i in imgs.size():
		data.append_array(imgs[i].get_data())
	
	return Image.create_from_data(
		imgs[0].get_width(),
		imgs[0].get_height() * imgs.size(),
		false,
		imgs[0].get_format(),
		data)

func generate_random_die() -> Array:
	var a = []
	for i in 6:
		a.append(randi_range(1,6))
	return a


const DICE_COLORS: Array[Color] = [
	Color.CORNFLOWER_BLUE, Color.CHARTREUSE, Color.HOT_PINK, 
	Color.TOMATO, Color.CADET_BLUE, Color.DARK_GREEN, 
	Color.MEDIUM_SLATE_BLUE, Color.NAVAJO_WHITE, Color.KHAKI,
	Color.ORANGE, Color.LIME, Color.MEDIUM_ORCHID]
func generate_random_die_color() -> Color:
	return DICE_COLORS[randi_range(0, DICE_COLORS.size() - 1)]
