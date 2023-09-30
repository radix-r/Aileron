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
@onready var hud_center: Control = $HudAnchor/CanvasLayer/HudCenter
@onready var hud_anchor: Node3D = $HudAnchor
@onready var velocity_marker: Control = $HudAnchor/CanvasLayer/VelocityMarker

@onready var waypoint_system: Node3D = get_tree().root.get_child(1).waypoint_system
@onready var gravity: Vector3 = get_tree().root.get_child(1).gravity
@onready var forward: Vector3 = Vector3()
@onready var starting_camera_position: Vector3 = camera_control.global_position
@onready var speed: float = 0

@onready var i = 0

var spark_effect: PackedScene = preload("res://Scenes/sparks1.tscn")
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

    velocity = Vector3.ZERO


# TODO: Boost
func _physics_process(delta: float) -> void:

    update_nav_arrow()
    update_hud_center()
    update_velocity_marker()

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


func update_hud_center() -> void:
    var cam_rotation: Vector3 = camera_control.rotation
    var hud_pos: Vector2 = transform_to_hud_space(camera.global_position + forward )

    if !camera.is_position_behind(camera.global_position + forward):
        hud_center.show()
        hud_center.position = hud_pos
        #hud_anchor.rotation = Vector3(0,0,-cam_rotation.z)
    else:
        hud_center.hide()


# TODO: Fix jank in accel/decel
func calc_velocity(input_dir: Vector3, delta: float) -> Vector3:
    var target_direction = Vector3(input_dir.x, input_dir.y, -1-input_dir.z)
    # convert to world space
    target_direction = pitch_point.to_global(target_direction) - global_position
    #target_direction.z = ceil(target_direction.z)
    #target_direction = target_direction * -1

    var velocity_x = move_toward(velocity.x, target_direction.x * speed_max, acceleration * delta)
    var velocity_y = move_toward(velocity.y, target_direction.y * speed_max, acceleration * delta)
    var velocity_z = move_toward(velocity.z, target_direction.z * speed_max, acceleration * delta)

    var target_velocity: Vector3 = Vector3(velocity_x, velocity_y ,velocity_z)
    target_velocity += gravity * delta
    #target_speed = clamp(target_speed, speed_min, speed_max)
    speed = target_velocity.length()

    #target_velocity = pitch_point.to_global(target_velocity)
    #if target_direction.length() > 1:
    #    print_debug(target_direction)
    return ((velocity * momentum + target_velocity ) /(1 + momentum)  )


func update_nav_arrow() -> void:
    nav_arrow_drawer.queue_redraw()


func update_velocity_marker() -> void:
    var hud_pos: Vector2 = transform_to_hud_space(camera.global_position + velocity)

    if camera.is_position_behind(camera.global_position + velocity):
        velocity_marker.hide()
    else:
        velocity_marker.show()
        velocity_marker.position = hud_pos


func transform_angle(angel: float, fov: float, pixel_height: float) -> float:
    return (tan(angel) / tan(fov / 2)) * pixel_height / 2


func transform_to_hud_space(world_space: Vector3) -> Vector2:
    var screen_space: Vector2 = camera.unproject_position(world_space)
    return screen_space #- Vector2(get_viewport().get_visible_rect().size / 2)
