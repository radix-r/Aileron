extends Node3D

@onready var aircraft: Aircraft = $Aircraft
@onready var model: Node3D = $Aircraft/Model
@onready var camera_joint: Node3D = $Aircraft/CameraControl
@onready var horizontal_look_sensitivity: float = 1.0
@onready var vertical_look_sensitivity: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    $Aircraft/Engine.engine_start()

    horizontal_look_sensitivity = Utilities.data_dict["settings"]["horizontal_look_sensitivity"]
    vertical_look_sensitivity = Utilities.data_dict["settings"]["vertical_look_sensitivity"]

func _input(event: InputEvent) -> void:
    #capture mouse movements
    if event is InputEventMouseButton:
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    elif event.is_action_pressed("ui_cancel"):
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

    # rotate aircraft on mouse movement
    if (event is InputEventMouseMotion) and (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
#        var v: Vector3 = aircraft.linear_velocity

        var mouse_velocity: Vector2 = event.velocity.normalized()

        model.global_rotate(Vector3.UP, -mouse_velocity.x * horizontal_look_sensitivity)
        model.global_rotate(aircraft.basis.x, -mouse_velocity.y * vertical_look_sensitivity)

        camera_joint.global_rotate(Vector3.UP, -mouse_velocity.x * horizontal_look_sensitivity)
        camera_joint.global_rotate(aircraft.basis.x, -mouse_velocity.y * vertical_look_sensitivity)

#        aircraft.apply_torque_impulse(Vector3(-mouse_velocity.y * vertical_look_sensitivity, -mouse_velocity.x * horizontal_look_sensitivity, 0))
        #aircraft.linear_velocity = v
