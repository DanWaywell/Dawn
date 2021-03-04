extends KinematicBody

onready var camera = $CameraRotation/Camera
onready var camera_rotation = $CameraRotation

var mouse_sensitivity = 0.007
var joypad_sensertivity = 4
var joypad_deadzone = 0.2
var speed = 6
var jump_speed = 12
var gravity = 30
var velocity = Vector3()
var snap = Vector3()


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	# Mouse look input
	if(event is InputEventMouseMotion):
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
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	
	# Y velocity
	velocity.y -= gravity * delta
	if is_on_floor():
		snap = Vector3(0, -1, 0)
		if Input.is_action_just_pressed("jump"):
			snap = Vector3()
			velocity.y = jump_speed
	
	# Apply Velocity
	velocity += get_floor_velocity() * delta
	velocity = move_and_slide_with_snap(velocity, snap, Vector3.UP, true)


func get_gamepad_look_input(delta):
	var input = Vector2()
	input.x = Input.get_action_strength("look_left") - Input.get_action_strength("look_right")
	input.y = Input.get_action_strength("look_up") - Input.get_action_strength("look_down")
	
	if input.length() < joypad_deadzone:
		input = Vector2()
	else:
		input = input.normalized() * ((input.length() - joypad_deadzone) / (1 - joypad_deadzone))
	
	return input


func get_move_input(delta):
	var input = Vector3()
	input.x =  Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input.z =  Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	
	if input.length() < joypad_deadzone:
		input = Vector3()
	else:
		input = input.normalized() * ((input.length() - joypad_deadzone) / (1 - joypad_deadzone))
	
	return input
