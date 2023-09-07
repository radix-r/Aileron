extends CharacterBody3D


#####################################
# SIGNALS
#####################################

#####################################
# CONSTANTS
#####################################

#####################################
# EXPORT VARIABLES
#####################################

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

@onready var pitch_point: Node3D = $PitchPoint
@onready var forward_point: Node3D = $PitchPoint/ForwardPoint
@onready var up_point: Node3D = $PitchPoint/UpPoint
@onready var camera_control: Node3D = $PitchPoint/CameraControl
@onready var camera: Camera3D = $PitchPoint/CameraControl/Camera3D
@onready var nav_arrow_point: Node3D = $NavArrowPoint
@onready var overlay: CanvasLayer = $NavArrowPoint/Overlay
@onready var nav_arrow_drawer: Control = $NavArrowPoint/Overlay/Draw3d

@onready var waypoint_system: Node3D = get_node("/root/TestScene1/Services/Navigation/WaypointSystem")


@onready var forward: Vector3 = Vector3()
@onready var starting_camera_position: Vector3 = camera_control.global_position
@onready var speed: float = 0


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
    var dataDict: Dictionary = read_json_file("res://Data.json")
    speed_default = dataDict[unit_name]["speed_default"]
    speed_max = dataDict[unit_name]["speed_max"]
    speed_min = dataDict[unit_name]["speed_min"]
    rotation_speed = dataDict[unit_name]["rotation_speed"]
    momentum = dataDict[unit_name]["momentum"]
    camera_chase = dataDict[unit_name]["camera_chase"]
    acceleration = dataDict[unit_name]["acceleration"]


func _physics_process(_delta: float) -> void:

    nav_arrow_drawer.queue_redraw()

    # Get input and handel turining, acel/decel
    var input_dir = Input.get_vector("left", "right", "up", "down")
    # var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
    var target_speed = (-input_dir.y * speed_max) + speed_default
    target_speed = clamp(target_speed, speed_min, speed_max)
    speed = move_toward(speed, target_speed, acceleration)

    forward = (forward_point.global_position - global_position).normalized()
    velocity = ((velocity * momentum + forward * speed ) / 2).normalized() * speed

    # shift camera based on speed to give chase effect
    var basis_z = forward
    var basis_y = -(up_point.global_position - global_position).normalized()
    var basis_x = -forward.rotated(basis_y, PI/2)
    var new_basis = Basis(basis_x, basis_y, basis_z)

    camera_control.position = ((velocity * new_basis ) * camera_chase + camera_control.position) /2

    if ( move_and_slide() ):
        # check collision info
        var collision: KinematicCollision3D = get_last_slide_collision()
        var collision_vector: Vector3 = (collision.get_position() - global_position).normalized()

        velocity = -collision_vector * speed


#####################################
# API FUNCTIONS
#####################################

#####################################
# HELPER FUNCTIONS
#####################################

# TODO: Move to utils file?
func read_json_file(file_path: String) -> Dictionary:
    var json_as_text = FileAccess.get_file_as_string(file_path)
    var json_as_dict = JSON.parse_string(json_as_text)
    if json_as_dict:
        return json_as_dict
    else:
        # TODO: Retrun error dict
        return Dictionary()

