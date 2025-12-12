class_name BasePhysicsActor extends RigidBody3D

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
@export var weapon: Weapon 

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
#var command_queue: Array = []
var input_dir_local: Vector3 = Vector3.ZERO
#####################################
# ONREADY VARIABLES
#####################################
@onready var pitch_point: Node3D = $PitchPoint
@onready var forward_point: Node3D = $PitchPoint/ForwardPoint
@onready var forward: Vector3 = Vector3()
@onready var up_point: Node3D = $PitchPoint/UpPoint
@onready var up_relative: Vector3 = Vector3()
#@onready var camera_control: Node3D = $PitchPoint/CameraControl
#@onready var camera: Camera3D = $PitchPoint/CameraControl/Camera3D
@onready var thrust_vector: Node3D = $ThrustVector

#@onready var camera_chase: float = 0
@onready var contact_point: Vector3 = Vector3.ZERO

@onready var boost_factor: float = 1
@onready var spark_speed_coeficent: float = 0
@onready var spark_amount_ratio_coeficent: float = 0
@onready var spark_lifetime_coeficent: float = 0
@onready var rotation_speed: float = 0
@onready var thrust_strength: float = 2000
@onready var boosting: bool = false

func _apply_flight_effects(delta: float):
    forward = _calc_forward()
    up_relative = _calc_up_relative()
    var input_dir_world = _calc_input_dir_world()
    
    #Apply rotation input
    _apply_rotation(delta)
    
    var thrust: Vector3 = calc_thrust(input_dir_world, delta)
     
    # apply gavity counter force
    if flight_mode == FlightModes.HOVER || flight_mode == FlightModes.SPEED:
        thrust += mass * -get_gravity()
    
    apply_force(thrust)
    #if thrust.length() > 0:
        #print_debug(thrust)
        
    # draw thrust vector
    _draw_thrust_effect(thrust)

func _apply_rotation(delta: float):
    self.rotate_y(tick_y_rotation_input_sum * rotation_speed * delta)
    pitch_point.rotate_x(tick_x_rotation_input_sum * rotation_speed * delta)
    pitch_point.rotation.x = clamp(pitch_point.rotation.x, deg_to_rad(-85), deg_to_rad(85))

func _calc_forward():
    return (forward_point.global_position - global_position).normalized()


func _calc_input_dir_world():
    return input_dir_local * pitch_point.global_transform.basis.inverse()

func _calc_up_relative():
    return (up_point.global_position - global_position).normalized()


func _draw_thrust_effect(thrust: Vector3):
    var thrust_direction: Vector3 = thrust
    thrust_direction += Vector3(1, 1, 1) - (global_position + thrust_direction).cross(Vector3.UP).normalized()

    thrust_vector.look_at(global_position + thrust_direction)
    var scale_factor = thrust.length() / 2000 # TODO magic number
    thrust_vector.scale = Vector3(scale_factor, scale_factor, scale_factor)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
    if 0 < state.get_contact_count():
        contact_point = state.get_contact_collider_position(0)
        apply_spark_effect(contact_point)


func _physics_process(delta: float) -> void:
    _apply_flight_effects(delta)
    

func _default_init():
    contact_monitor = true
    max_contacts_reported = 1
    
    var unit_name = "ShipPhysics"
    
    rotation_speed = Utilities.data_dict[unit_name]["rotation_speed"]

    spark_speed_coeficent = Utilities.data_dict[unit_name]["spark_speed_coeficent"]
    spark_amount_ratio_coeficent = Utilities.data_dict[unit_name]["spark_amount_ratio_coeficent"]
    spark_lifetime_coeficent = Utilities.data_dict[unit_name]["spark_lifetime_coeficent"]
    boost_factor = Utilities.data_dict[unit_name]["boost_factor"]
    thrust_strength = Utilities.data_dict[unit_name]["thrust_strength"]

func _ready() -> void:
    _default_init()

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
    if boosting:
        thrust *= boost_factor
    return thrust 
    
    
func fire_weapon():
    if weapon:
        weapon.fire()


func set_boosting(boosting_: bool):
    boosting = boosting_


func set_input_direction(direction_normal: Vector3):
    input_dir_local = direction_normal


func rotate_with_input(rotation_input: Vector2):
    tick_y_rotation_input_sum = rotation_input.y
    tick_x_rotation_input_sum = rotation_input.x
    
