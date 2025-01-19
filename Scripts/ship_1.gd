class_name AirMover extends CharacterBody3D


#####################################
# SIGNALS
#####################################

#####################################
# CONSTANTS
#####################################

#####################################
# EXPORT VARIABLES
#####################################
@export var spark_effect: PackedScene = preload("res://Scenes/sparks1.tscn")

#####################################
# PUBLIC VARIABLES
#####################################

#####################################
# PRIVATE VARIABLES
#####################################

#####################################
# ONREADY VARIABLES
#####################################

@onready var acceleration: float = 0
@onready var speed_default: float = 0
@onready var speed_max: float = 0
@onready var speed_min: float = 0
@onready var rotation_speed: float = 0
@onready var momentum: float = 0
@onready var camera_chase: float = 0
@onready var drag: float = 0

@onready var pitch_point: Node3D = $PitchPoint
@onready var forward_point: Node3D = $PitchPoint/ForwardPoint
@onready var up_point: Node3D = $PitchPoint/UpPoint
@onready var camera_control: Node3D = $PitchPoint/CameraControl
@onready var camera: Camera3D = $PitchPoint/CameraControl/Camera3D


@onready var level_root: Node3D = Utilities.get_level_root()
@onready var waypoint_system: Node3D
@onready var gravity: Vector3
@onready var forward: Vector3 = Vector3()
@onready var starting_camera_position: Vector3 = camera_control.global_position
@onready var speed: float = 0

@onready var i = 0

# Debug
var debug: bool = true
var debug_prev_target_direction_local: Vector3 = Vector3.ZERO
var debug_prev_velocity: Vector3 = Vector3.ZERO



#####################################
# OVERRIDE FUNCTIONS
#####################################

func _unhandled_input(event: InputEvent) -> void:
    #capture mouse movements
    if event is InputEventMouseButton:
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    elif event.is_action_pressed("ui_cancel"):
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

    if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        if event is InputEventMouseMotion:
            self.rotate_y(-event.relative.x * rotation_speed)
            pitch_point.rotate_x(-event.relative.y * rotation_speed)
            pitch_point.rotation.x = clamp(pitch_point.rotation.x, deg_to_rad(-85), deg_to_rad(85))


func _ready() -> void:
    var unit_name = "Ship1"

    speed_default = Utilities.data_dict[unit_name]["speed_default"]
    speed_max = Utilities.data_dict[unit_name]["speed_max"]
    speed_min = Utilities.data_dict[unit_name]["speed_min"]
    rotation_speed = Utilities.data_dict[unit_name]["rotation_speed"]
    momentum = Utilities.data_dict[unit_name]["momentum"]
    camera_chase = Utilities.data_dict[unit_name]["camera_chase"]
    acceleration = Utilities.data_dict[unit_name]["acceleration"]
    drag = Utilities.data_dict[unit_name]["drag"]

    velocity = Vector3.ZERO

    if level_root:
        if "waypoint_system" in level_root:
            waypoint_system = level_root.waypoint_system

        if "gravity" in level_root:
            gravity = level_root.gravity


# TODO: Boost
func _physics_process(delta: float) -> void:



    forward = (forward_point.global_position - global_position).normalized()

    # Get input and handel turining, acel/decel
    var input_dir: Vector3 = get_input_direction()

    velocity = calc_velocity(input_dir, delta)

    # shift camera based on velocity to give chase effect
    update_camera_position()

    # apply velocity
    if ( move_and_slide() ):
        # check collision info
        var collision: KinematicCollision3D = get_last_slide_collision()
        var collision_vector: Vector3 = (collision.get_position() - global_position).normalized()
        var collision_position: Vector3 = collision.get_position()
        apply_spark_effect(collision_position)

        #velocity = -collision_vector * speed


#####################################
# API FUNCTIONS
#####################################

#####################################
# HELPER FUNCTIONS
#####################################

func apply_spark_effect(global_location: Vector3) -> void:
    if velocity.length() > 0:
        var new_sparks: GPUParticles3D = spark_effect.instantiate() as GPUParticles3D
        get_node("/root").add_child(new_sparks)
        new_sparks.emitting = true
        new_sparks.global_position = global_location


func get_input_direction() -> Vector3:
    var input_right = Input.get_axis("left", "right")
    var input_up = Input.get_axis("down","up")
    var input_forward = Input.get_axis( "back", "forward")
    return Vector3(input_right, input_up, input_forward)


# apply chase effect to camera
func update_camera_position() -> void:
    var basis_z = forward
    var basis_y = -(up_point.global_position - global_position).normalized()
    var basis_x = -forward.rotated(basis_y, PI/2)
    var new_basis = Basis(basis_x, basis_y, basis_z)

    camera_control.position = ((velocity * new_basis ) * camera_chase + camera_control.position) /2






func calc_velocity(input_dir: Vector3, delta: float) -> Vector3:
    var target_direction_local = Vector3(input_dir.x, input_dir.y, -1-input_dir.z)
    # convert to world space
    var target_direction = target_direction_local * pitch_point.global_transform.basis.inverse()

    # apply thrust
    var velocity_x = move_toward(velocity.x,  speed_max, target_direction.x * acceleration * delta)
    var velocity_y = move_toward(velocity.y,  speed_max, target_direction.y * acceleration * delta) # -(30 * delta))# Gravity?
    var velocity_z = move_toward(velocity.z,  speed_max, target_direction.z * acceleration * delta)

    # apply drag
    velocity_x -= velocity.x * drag * delta
    velocity_y -= velocity.y * drag * delta
    velocity_z -= velocity.z * drag * delta

    var target_velocity: Vector3 = Vector3(velocity_x, velocity_y ,velocity_z) #- target_direction_local

    if debug:
        if Vector3.ZERO == debug_prev_target_direction_local && Vector3.ZERO != target_direction_local:
            print_debug("Input: ", target_direction_local, "\n",
                        "Input Global: ", target_direction, "\n",
                        "Velocity: ", target_velocity, "\n",
                        "Orientation: ", forward)



        debug_prev_target_direction_local = target_direction_local
        debug_prev_velocity = velocity

    #return target_velocity

    return ((velocity * momentum + target_velocity ) / (1 + momentum) )
