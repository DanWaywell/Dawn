extends KinematicBody

onready var camera = $CameraRotation/Camera
onready var camera_rotation = $CameraRotation

onready var label_1 = $Debug/Labels/Label1
onready var label_2 = $Debug/Labels/Label2
onready var label_3 = $Debug/Labels/Label3
onready var label_4 = $Debug/Labels/Label4
onready var label_5 = $Debug/Labels/Label5

var mouse_sensitivity = 0.007
var joypad_sensertivity = 4
var joypad_deadzone = 0.2
var speed = 80
var min_speed = speed / 4
var jump_speed = 120
var gravity = 300
var velocity = Vector3()
var snap = Vector3()


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	# Mouse look input
	if event is InputEventMouseMotion:
		camera_rotation.rotate_y(-event.relative.x * mouse_sensitivity)
		
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)


func _physics_process(delta):
	# Gamepad look input
	var look_input = get_gamepad_look_input(delta)
	if look_input:
		camera_rotation.rotate_y(deg2rad(look_input.x * joypad_sensertivity))
		
		camera.rotate_x(deg2rad(look_input.y * joypad_sensertivity))
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	
	# Move input
	var direction = get_move_input(delta)
	direction = direction.rotated(Vector3.UP, camera_rotation.rotation.y)
	
	# X Z Velocity
	if direction:
		velocity.x = direction.normalized().x * min_speed
		velocity.z = direction.normalized().z * min_speed
		velocity.x += direction.x * speed
		velocity.z += direction.z * speed
	else:
		velocity.x = 0
		velocity.z = 0
	
	# Y velocity
	velocity.y -= gravity * delta
	if is_on_floor():
		snap = Vector3(0, -5, 0)
		if Input.is_action_just_pressed("jump"):
			snap = Vector3()
			velocity.y = jump_speed
			
	# Moving platforms
	velocity += get_floor_velocity() * delta
	
	# Apply Velocity
	velocity = move_and_slide_with_snap(velocity, snap, Vector3.UP, true, 4, deg2rad(89))
	
	
	# Debug labels
	label_1.text = "velocity = " + str(velocity)
	label_2.text = "speed = " + str(velocity.length())
	label_3.text = "is_on_floor() = " + str(is_on_floor())
	label_4.text = "floor_normal = " + str(get_floor_normal())
	label_5.text = "is_on_wall = " + str(is_on_wall())


func get_gamepad_look_input(delta):
	var input = Vector2()
	input.x = Input.get_action_strength("look_left") - Input.get_action_strength("look_right")
	input.y = Input.get_action_strength("look_up") - Input.get_action_strength("look_down")
	
	if input.length() < joypad_deadzone:
		input = Vector2()
	else:
		input = input.normalized() * ((input.length() - joypad_deadzone) / (1 - joypad_deadzone))
	
	return input.clamped(1.0)


func get_move_input(delta):
	var input = Vector2()
	input.x =  Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input.y =  Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	
	if input.length() < joypad_deadzone:
		input = Vector2()
	else:
		input = input.normalized() * ((input.length() - joypad_deadzone) / (1 - joypad_deadzone))
	
	input = input.clamped(1.0)
	
	return Vector3(input.x, 0, input.y)
