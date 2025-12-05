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
@export var thrust_strength: float = 2000

#####################################
# PUBLIC VARIABLES
#####################################

#####################################
# PRIVATE VARIABLES
#####################################
enum FlightModes{
    OFF,
    HOVER,
    SPEED,
}
var flight_mode: FlightModes = FlightModes.HOVER
var tick_y_rotation_input_sum: float = 0
var tick_x_rotation_input_sum: float = 0

#####################################
# ONREADY VARIABLES
#####################################
@onready var pitch_point: Node3D = $PitchPoint
@onready var forward_point: Node3D = $PitchPoint/ForwardPoint
@onready var forward: Vector3 = Vector3()
@onready var up_point: Node3D = $PitchPoint/UpPoint
@onready var up_relative: Vector3 = Vector3()
@onready var camera_control: Node3D = $PitchPoint/CameraControl
@onready var camera: Camera3D = $PitchPoint/CameraControl/Camera3D

@onready var camera_chase: float = 0
@onready var contact_point: Vector3 = Vector3.ZERO

@onready var boost_factor: float = 1
@onready var spark_speed_coeficent: float = 0
@onready var spark_amount_ratio_coeficent: float = 0
@onready var spark_lifetime_coeficent: float = 0
@onready var rotation_speed: float = 0

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
    forward = (forward_point.global_position - global_position).normalized()
    up_relative = (up_point.global_position - global_position).normalized()
    var input_dir_local: Vector3 = get_input_direction()

    var input_dir_world = input_dir_local * pitch_point.global_transform.basis.inverse()
    
    #Apply rotation input
    self.rotate_y(tick_y_rotation_input_sum * rotation_speed * delta)
    tick_y_rotation_input_sum = 0
    pitch_point.rotate_x(tick_x_rotation_input_sum * rotation_speed * delta)
    tick_x_rotation_input_sum = 0
    pitch_point.rotation.x = clamp(pitch_point.rotation.x, deg_to_rad(-85), deg_to_rad(85))
    
    var thrust: Vector3 = calc_thrust(input_dir_world, delta)
    if Input.is_action_pressed("boost"):
        thrust *= boost_factor 
        
    # apply gavity counter force
    if flight_mode == FlightModes.HOVER || flight_mode == FlightModes.SPEED:
        thrust += mass * -get_gravity()
    
    apply_force(thrust)
    #if thrust.length() > 0:
        #print_debug(thrust)
    # TODO draw thrust vector
    
    # shift camera based on velocity to give chase effect
    update_camera_position()

func _ready() -> void:
    contact_monitor = true
    max_contacts_reported = 1
    
    var unit_name = "ShipPhysics"
    
    rotation_speed = Utilities.data_dict[unit_name]["rotation_speed"]
    camera_chase = Utilities.data_dict[unit_name]["camera_chase"]
    spark_speed_coeficent = Utilities.data_dict[unit_name]["spark_speed_coeficent"]
    spark_amount_ratio_coeficent = Utilities.data_dict[unit_name]["spark_amount_ratio_coeficent"]
    spark_lifetime_coeficent = Utilities.data_dict[unit_name]["spark_lifetime_coeficent"]
    boost_factor = Utilities.data_dict[unit_name]["boost_factor"]
# TODO: spark effect factor out of ship code
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
    var thrust = Vector3.ZERO
    match flight_mode:
        FlightModes.OFF:
            thrust = Vector3.ZERO
        FlightModes.HOVER:
            
            thrust = input_dir * thrust_strength * delta
            # add thrust to offset gravity
            #thrust += mass * -get_gravity()
        FlightModes.SPEED:
            input_dir.z = input_dir.z - 1 
            #thrust += mass * -get_gravity()
    return thrust 
    

func get_input_direction() -> Vector3:
    var input_right = Input.get_axis("left", "right")
    var input_up = Input.get_axis("down","up")
    # -z is forward
    var input_forward = Input.get_axis("forward", "back")
    return Vector3(input_right, input_up, input_forward).normalized()


# apply chase effect to camera
func update_camera_position() -> void:
    var basis_z = forward
    var basis_y = -(up_point.global_position - global_position).normalized()
    var basis_x = -forward.rotated(basis_y, PI/2)
    var new_basis = Basis(basis_x, basis_y, basis_z)

    camera_control.position = ((linear_velocity * new_basis ) * camera_chase + camera_control.position) /2



func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
    #apply_spark_effect(contact_point)
    pass
