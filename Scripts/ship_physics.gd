extends RigidBody3D

# TODO: Hover and speed mode

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
# TODO: make data driven
@export var thrust_strength: float = 1000

#####################################
# PUBLIC VARIABLES
#####################################

#####################################
# PRIVATE VARIABLES
#####################################
var tick_y_rotation_input_sum: float = 0
var tick_x_rotation_input_sum: float = 0

#####################################
# ONREADY VARIABLES
#####################################
@onready var pitch_point: Node3D = $PitchPoint
@onready var forward_point: Node3D = $PitchPoint/ForwardPoint
@onready var up_point: Node3D = $PitchPoint/UpPoint
@onready var camera_control: Node3D = $PitchPoint/CameraControl
@onready var camera: Camera3D = $PitchPoint/CameraControl/Camera3D

@onready var camera_chase: float =not 0
@onready var contact_point: Vector3 = Vector3.ZERO

@onready var spark_speed_coeficent: float 
@onready var spark_amount_ratio_coeficent: float 
@onready var spark_lifetime_coeficent: float 
@onready var rotation_speed: float

# TODO: Controler support
func _input(event: InputEvent) -> void:
    #capture mouse movements
    if event is InputEventMouseButton:
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    elif event.is_action_pressed("ui_cancel"):
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

    if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        if event is InputEventMouseMotion:
            tick_y_rotation_input_sum += -event.relative.x 
            tick_x_rotation_input_sum += -event.relative.y
            

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
    if 0 < state.get_contact_count():
        contact_point = state.get_contact_collider_position(0)
        apply_spark_effect(contact_point)


func _physics_process(delta: float) -> void:
    var input_dir: Vector3 = get_input_direction()

    self.rotate_y(tick_y_rotation_input_sum * rotation_speed * delta)
    tick_y_rotation_input_sum = 0
    pitch_point.rotate_x(tick_x_rotation_input_sum * rotation_speed * delta)
    tick_x_rotation_input_sum = 0
    pitch_point.rotation.x = clamp(pitch_point.rotation.x, deg_to_rad(-85), deg_to_rad(85))

    var thrust: Vector3 = calc_thrust(input_dir, delta).rotated(Vector3.UP, global_rotation.y)
    
    apply_force(thrust)
    #if thrust.length() > 0:
        #print_debug(thrust)
    # TODO draw thrust vector
    

func _ready() -> void:
    contact_monitor = true
    max_contacts_reported = 1
    
    var unit_name = "ShipPhysics"
    
    rotation_speed = Utilities.data_dict[unit_name]["rotation_speed"]
    camera_chase = Utilities.data_dict[unit_name]["camera_chase"]
    spark_speed_coeficent = Utilities.data_dict[unit_name]["spark_speed_coeficent"]
    spark_amount_ratio_coeficent = Utilities.data_dict[unit_name]["spark_amount_ratio_coeficent"]
    spark_lifetime_coeficent = Utilities.data_dict[unit_name]["spark_lifetime_coeficent"]

# TODO: factor out of ship code
func apply_spark_effect(global_location: Vector3) -> void:
    if linear_velocity.length() > 0.2:
        var new_sparks: GPUParticles3D = spark_effect.instantiate() as GPUParticles3D
        new_sparks.speed_scale = spark_speed_coeficent * sqrt(linear_velocity.length())
        new_sparks.amount_ratio = spark_amount_ratio_coeficent * sqrt(linear_velocity.length())
        new_sparks.lifetime = spark_lifetime_coeficent * sqrt(linear_velocity.length())
        get_node("/root").add_child(new_sparks)
        new_sparks.emitting = true
        new_sparks.global_position = global_location


func calc_thrust(input_dir: Vector3, delta: float) -> Vector3:
    return input_dir * thrust_strength * delta
    # return Vector3.ZERO
    

func get_input_direction() -> Vector3:
    var input_right = Input.get_axis("left", "right")
    var input_up = Input.get_axis("down","up")
    # -z is forward
    var input_forward = Input.get_axis("forward", "back")
    return Vector3(input_right, input_up, input_forward)


func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
    #apply_spark_effect(contact_point)
    pass
