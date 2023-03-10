extends CharacterBody3D


@export var speed:float = 5.0
@export var mouse_sensitivity:float = 2.5
var mouse_delta:Vector2=Vector2.ZERO
var retardation:float


@onready var yaw = $Yaw
@onready var camera = $Yaw/Camera3D

func _ready():
	retardation = speed * 2
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	handle_input(delta)

func handle_input(delta):
#	var z_axis = (Input.get_action_strength("back") - Input.get_action_strength("forward"))
#	var x_axis = (Input.get_action_strength("strafe_right") - Input.get_action_strength("strafe_left"))
#	•••••••• The below code is similar to the above code ••••••••
	var input_dir := Input.get_vector("strafe_left", "strafe_right", "forward", "back")
	var direction = (yaw.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() 
	
	if(direction):
		velocity = Vector3(direction.x, velocity.y, direction.z) * speed
	else:
		velocity.x = move_toward(velocity.x, 0, delta*retardation)
		velocity.z = move_toward(velocity.z, 0, delta*retardation)

	move_and_slide()

func _unhandled_input(event):
	if(event is InputEventMouseMotion):
		mouse_delta = event.relative
		var sensitivity: = mouse_sensitivity * .1
		yaw.rotate_y(deg_to_rad(-mouse_delta.x * sensitivity))
		camera.rotate_x(deg_to_rad(-mouse_delta.y* sensitivity))
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(40))
