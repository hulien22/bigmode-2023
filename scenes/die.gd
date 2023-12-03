extends RigidBody3D
class_name Die

enum DIE_STATE {THROWING, RESULT, LOCKED};

var state:DIE_STATE = DIE_STATE.RESULT;
var throw_time = 0.0
const MAX_THROW_TIME_SECS = 5.0
var stop_time = 0.0;
const TIME_TO_WAIT_SECS = 0.3;
var result = 1

var last_collision_time = 0.0
var can_play_collision_sound = true
const TIME_BETWEEN_COLLISION_SOUND = 0.1

var drop_height = 10;

var last_velocity:Vector3

var die_color = Color.WHITE
var faces = [1,2,6,5,3,4]
var face_texture:ImageTexture

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize();
#	faces.shuffle()
	set_die_faces(faces)
	$CollisionShape3D/MeshInstance3D.get_surface_override_material(0).albedo_color = die_color
#	$CollisionShape3D/MeshInstance3D.get_surface_override_material(0).albedo_color = Color(randf(), randf(), randf())
#	$RigidBody3D/CollisionShape3D/MeshInstance3D.material_override.albedo_color = colors[randi() % colors.size()]
	connect("body_entered", Callable(on_collision))
#	drop();

func init(f: Array, c: Color):
	faces = f
	die_color = c

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	if Input.is_action_just_pressed("Launch"):
#		throw()
	if state == DIE_STATE.THROWING:
		last_velocity = linear_velocity
		#check if stopped
		throw_time += delta
		if abs(linear_velocity.x) < 0.001 && abs(linear_velocity.y) < 0.001 && abs(linear_velocity.z) < 0.001 && \
			abs(angular_velocity.x) <  0.001 && abs(angular_velocity.y) <  0.001 && abs(angular_velocity.z) <  0.001:
			if stop_time > TIME_TO_WAIT_SECS:
#				print("Stopped", linear_velocity, angular_velocity)
				result = get_top_val() ### TODO have die controller call this instead
				state = DIE_STATE.RESULT
				stop_time = 0
			else:
				stop_time += delta
		elif throw_time > MAX_THROW_TIME_SECS:
#			print("Stopped -- TIMEOUT", linear_velocity, angular_velocity)
			result = get_top_val() ### TODO have die controller call this instead
			state = DIE_STATE.RESULT
		else:
			stop_time = 0 
	
	if !can_play_collision_sound:
		last_collision_time += delta
		if last_collision_time > TIME_BETWEEN_COLLISION_SOUND:
			can_play_collision_sound = true

func set_die_faces(f:Array):
	faces = f
	face_texture = DiceConstructor.construct_die(faces)
	$CollisionShape3D/MeshInstance3D.get_surface_override_material(0).albedo_texture = face_texture

func can_throw() -> bool:
	return state == DIE_STATE.RESULT

func is_stopped() -> bool:
	return state == DIE_STATE.RESULT || state == DIE_STATE.LOCKED
	
func is_locked() -> bool:
	return state == DIE_STATE.LOCKED

func throw():
	if !can_throw():
		return
	state = DIE_STATE.THROWING
	throw_time = 0
	apply_torque(Vector3(randf_range(-100,-50),randf_range(50,100),randf_range(-100,100)))
	apply_force(Vector3.UP * randf_range(400,800))
	apply_force(Vector3.LEFT * randf_range(-500,500))
	apply_force(Vector3.FORWARD * randf_range(-500,500))

func drop():
	if !can_throw():
		return
	state = DIE_STATE.THROWING
	can_play_collision_sound = false
	last_collision_time = 0
	throw_time = 0
	position.y = drop_height
	position.x = 0
	position.z = 0
	set_rotation(Vector3(randf_range(0,2 * PI),randf_range(0,2 * PI),randf_range(0,2 * PI)))
	apply_torque(Vector3(randf_range(-200,-50),randf_range(50,200),randf_range(-200,200)))
	apply_force(Vector3.DOWN * randf_range(400,800))
	apply_force(Vector3.LEFT * randf_range(-800,800))
	apply_force(Vector3.FORWARD * randf_range(-800,800))
	

func get_top_face() -> int:
	var topval = 3
	var min = 1 - transform.basis.y.y
	if 1 + transform.basis.y.y < min:
		topval = 4
		min = 1 + transform.basis.y.y
	if 1 - transform.basis.x.y < min:
		topval = 2
		min = 1 - transform.basis.x.y
	if 1 + transform.basis.x.y < min:
		topval = 5
		min = 1 + transform.basis.x.y
	if 1 - transform.basis.z.y < min:
		topval = 1
		min = 1 - transform.basis.z.y
	if 1 + transform.basis.z.y < min:
		topval = 6
		min = 1 + transform.basis.z.y
#	print("TOPVAL IS", topval)
	return topval

func get_top_val() -> int:
	match get_top_face():
		1:
			return faces[0]
		2:
			return faces[1]
		3:
			return faces[4]
		4:
			return faces[5]
		5:
			return faces[3]
		_:
			return faces[2]

func on_collision(body):
	if can_play_collision_sound:
		var impact = linear_velocity - last_velocity;
		if body.is_class("RigidBody3D") && global_position.y >= body.global_position.y:
			SfxHandler.play_sfx(SfxHandler.DICE_SFX, self, impact.length_squared())
		elif body.is_class("StaticBody3D"):
			SfxHandler.play_sfx(SfxHandler.GROUND_SFX, self, impact.length_squared() / 2)
#			SfxHandler.play_sfx(DICE_SFX, self, impact.length_squared() / 2)

		can_play_collision_sound = false
		last_collision_time = 0

func enable(en: bool):
	if state == DIE_STATE.LOCKED:
		freeze = true
#		collision_layer = 0b0010
	else:
		freeze = !en;
#		collision_layer = 0b0011
#	contact_monitor = en;
	if en:
		collision_mask = 0b0001
	else:
		collision_mask = 0

# TODO ALSO WANT TO FACE UPWARDS? try with up arrow die?
func rotate_upwards():
	var final_rotation = Vector3.ZERO
	match get_top_face():
		1:
			final_rotation = Vector3(-90, -90, 0)
		2:
			final_rotation = Vector3(0, 180 * sign(rotation_degrees.y), 90)
		3:
			final_rotation = Vector3(0, 90, 0)
		4:
			# bottom side can rotate 2 ways, choose closer
			if abs(rotation_degrees.z) > abs(rotation_degrees.x):
				final_rotation = Vector3(0, 90, 180 * sign(rotation_degrees.z))
			else:
				final_rotation = Vector3(180 * sign(rotation_degrees.z), 90, 0)
		5:
			final_rotation = Vector3(0, 0, -90)
		6:
			final_rotation = Vector3(90, 90, 0)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "rotation_degrees", final_rotation, 0.4)

func animate_slide_to(posn:Vector3):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", posn, 0.4)

# Mouse hover animations
var has_mouse: bool = false;
func mouse_entered():
	scale = Vector3.ONE * 1.1
#	SfxHandler.play_sfx(SfxHandler.PAPER_HIT_SFX, self, 1)
	SfxHandler.play_sfx(SfxHandler.DICE_SFX, self, 1)
func mouse_exited():
	scale = Vector3.ONE

func toggle_locked():
	if state == DIE_STATE.LOCKED:
		state = DIE_STATE.RESULT
		$CollisionShape3D/MeshInstance3D.transparency = 0
#		lock_rotation = false
	elif state == DIE_STATE.RESULT:
		state = DIE_STATE.LOCKED
		$CollisionShape3D/MeshInstance3D.transparency = 0.5
#		lock_rotation = true

func reset_die():
	state = DIE_STATE.RESULT
	$CollisionShape3D/MeshInstance3D.transparency = 0
	scale = Vector3.ONE

func fade_away():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector3.ONE*0.01, 0.1)
