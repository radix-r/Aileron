extends RigidBody3D

# TODO: Hover and speed mode

#####################################
# SIGNALS
#####################################

#####################################
# CONSTANTS
#####################################
# TODO: make data driven
const spark_speed_coeficent: float = 0.3
const spark_amount_ratio_coeficent: float = 0.1
const spark_lifetime_coeficent: float = 0.1

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

#####################################
# ONREADY VARIABLES
#####################################
@onready var pitch_point: Node3D = $PitchPoint
@onready var forward_point: Node3D = $PitchPoint/ForwardPoint
@onready var up_point: Node3D = $PitchPoint/UpPoint
@onready var camera_control: Node3D = $PitchPoint/CameraControl
@onready var camera: Camera3D = $PitchPoint/CameraControl/Camera3D

@onready var camera_chase: float = 0
@onready var contact_point: Vector3 = Vector3.ZERO

func _input(event: InputEvent) -> void:
    #capture mouse movements
    if event is InputEventMouseButton:
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    elif event.is_action_pressed("ui_cancel"):
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

    if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        if event is InputEventMouseMotion:
            # self.rotate_y(-event.relative.x * rotation_speed)
            # pitch_point.rotate_x(-event.relative.y * rotation_speed)
            pitch_point.rotation.x = clamp(pitch_point.rotation.x, deg_to_rad(-85), deg_to_rad(85))


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
    if 0 < state.get_contact_count():
        contact_point = state.get_contact_collider_position(0)
        apply_spark_effect(contact_point)

func _physics_process(delta: float) -> void:
    var input_dir: Vector3 = get_input_direction()

    var thrust: Vector3 = calc_thrust(input_dir, delta)
    
    apply_force(thrust)
    if thrust.length() > 0:
        print_debug(thrust)
    # TODO draw thrust vector
    
    get_colliding_bodies()
    pass

func _ready() -> void:
    contact_monitor = true
    max_contacts_reported = 1

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
    var input_forward = Input.get_axis( "back", "forward")
    return Vector3(input_right, input_up, input_forward)


func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
    #apply_spark_effect(contact_point)
    pass
