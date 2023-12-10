extends Camera3D
class_name MouseHandler

signal toggle_all(val, set_locked) 

var remove_on_select:bool = false

var mouse = Vector2()

var is_mouse_down:bool = false
var is_right_mouse_down:bool = false

var enable_mouse = false;
var last_obj_rid = 0
var last_obj

func enable_mouse_events(en:bool):
	enable_mouse = en;
	process_mouse_hover({})

func _process(delta):
	if !enable_mouse:
		return
	
	mouse = get_viewport().get_mouse_position()
	var selection = get_selection()
	process_mouse_hover(selection)
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if !is_mouse_down:
			is_mouse_down = true
			
			var die = selection.get("collider", null)
			if die:
				match GameState.game_scene:
					GameState.GameScene.COMBAT:
						if Input.is_key_pressed(KEY_SHIFT):
							toggle_all.emit(die.get_top_val(), !die.is_locked())
						else:
							die.toggle_locked()
					GameState.GameScene.DICE_SHOP:
						if GameState.player.coins < 5:
							print("not enough money")
							#TODO play err sound?
							return
						GameState.player.coins -= 5
						GameState.player.dice.append([die.faces, die.die_color])
						last_obj = null
						last_obj_rid = 0
						die.queue_free()
						Events.emit_signal("coins_updated")
					GameState.GameScene.RITUAL:
						last_obj = null
						last_obj_rid = 0
						Events.emit_signal("sacrificed_die", die.index)
						die.queue_free()
					GameState.GameScene.REST:
						last_obj = null
						last_obj_rid = 0
						GameState.player.health = min(GameState.player.health + die.get_top_val(), GameState.player.max_health)
						Events.emit_signal("health_updated")
						die.queue_free()
						
				SfxHandler.play_sfx(SfxHandler.GROUND_SFX, self, 1)
	elif is_mouse_down:
		is_mouse_down = false
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		if !is_right_mouse_down:
			is_right_mouse_down = true
			var die = selection.get("collider", null)
			if die:
				Events.emit_signal("tooltip_obj_clicked", die, 0, ToolTip.DISPLAY.DICE_FACES)
				SfxHandler.play_sfx(SfxHandler.PAPER_HIT_SFX, self, 1)
	elif is_right_mouse_down:
		is_right_mouse_down = false

func process_mouse_hover(selection: Dictionary):
	var sel_rid = selection.get("collider_id", 0)
	if sel_rid != last_obj_rid:
		var obj = selection.get("collider", null)
		if obj:
			obj.mouse_entered()
		if last_obj_rid > 0 && last_obj:
			last_obj.mouse_exited()
		last_obj_rid = sel_rid
		last_obj = obj
	

func get_selection() -> Dictionary:
	var worldspace = get_world_3d().direct_space_state
	var start = project_ray_origin(mouse)
	var end = project_position(mouse, 1000)
	var result = worldspace.intersect_ray(PhysicsRayQueryParameters3D.create(start, end, 0b0010))
	return result
#	print(start, end, result)

#(0, 9.588713, 0)
#(171.9381, -990.4113, 512.9725)
#{ "position": (1.345882, 1.760999, 4.015402), "normal": (0.000001, 1, -0.000001), "collider_id": 29225911496, "collider": die:<RigidBody3D#29225911496>, "shape": 0, "rid": RID(4110283702277) }
