extends Node2D
class_name ToolTip

enum DISPLAY {DICE_FACES, ABILITY}

var last_time_touching: float = 0;
var time_before_show: float = 0;
var last_touch_object: Object = null;
var boundary_box:Vector2 = Vector2(300,200); # width, height
var padding:Vector2 = Vector2(2,2);

func _process(delta):
	if last_touch_object == null:
		return

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		visible = false;
		last_touch_object = null;
		return
	
	# check if mouse is colliding with collideable object.
	# if collides then wait min time while still touching same object to start showing
	if (boundary_box):
		var mouse_posn = get_global_mouse_position();
		var border = get_viewport_rect().size - padding
		var posnx = mouse_posn.x;
		var posny = mouse_posn.y;
		if (posnx + boundary_box.x > border.x):
			posnx -= boundary_box.x
		if (posny + boundary_box.y > border.y):
			posny -= boundary_box.y
		global_position = Vector2(posnx, posny);

	if !visible:
		last_time_touching += delta;
		if last_time_touching > time_before_show:
			last_time_touching = 0;
			visible = true;

func _ready():
	visible = false;
	Events.connect("tooltip_obj_entered", tooltip_obj_entered)
	Events.connect("tooltip_obj_clicked", tooltip_obj_clicked)
	Events.connect("tooltip_obj_exited", tooltip_obj_exited)


func tooltip_obj_entered(obj: Object, time_to_show_sec:float, display:DISPLAY):
	if obj != last_touch_object:
		hide_all()
		visible = false;
		last_touch_object = obj;
		last_time_touching = 0;
		time_before_show = time_to_show_sec;
		match display:
			DISPLAY.DICE_FACES:
				$DieSprite.texture = obj.face_texture
				$DieSprite.visible = true
				$DieSprite.modulate = obj.die_color
				boundary_box = Vector2(300,200);
			DISPLAY.ABILITY:
				$ColorRect.visible = true
				var a:Ability = obj.ability
				$Label.text = a.name_ + "\n" + a.desc_
				$Label.visible = true
				boundary_box = Vector2(300,200);

func tooltip_obj_clicked(obj: Object, time_to_show_sec:float, display:DISPLAY):
	if obj != last_touch_object:
		tooltip_obj_entered(obj, time_to_show_sec, display)
	else:
		tooltip_obj_exited(obj)

func tooltip_obj_exited(obj: Object):
	if obj == last_touch_object:
		visible = false;
		last_touch_object = null;
		last_time_touching = 0;

func hide_all():
	$DieSprite.visible = false
	$ColorRect.visible = false
	$Label.visible = false
