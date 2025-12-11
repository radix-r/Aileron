class_name PlayerPhysicsShip extends BasePhysicsActor

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

@onready var camera_control: Node3D = $PitchPoint/CameraControl
@onready var camera: Camera3D = $PitchPoint/CameraControl/Camera3D
@onready var camera_chase: float = 0

func _ready() -> void:
    _default_init()
    var unit_name = "ShipPhysics"
    camera_chase = Utilities.data_dict[unit_name]["camera_chase"]

func _physics_process(delta: float) -> void:
    _apply_flight_effects(delta)
    # Apply camera effects
    _update_camera_position()


func get_camera() -> Camera3D:
    return $PitchPoint/CameraControl/Camera3D


# apply chase effect to camera
func _update_camera_position() -> void:
    var basis_z = forward
    var basis_y = -(up_point.global_position - global_position).normalized()
    var basis_x = -forward.rotated(basis_y, PI/2)
    var new_basis = Basis(basis_x, basis_y, basis_z)

    camera_control.position = ((linear_velocity * new_basis ) * camera_chase + camera_control.position) /2
