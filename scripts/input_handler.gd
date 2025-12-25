extends Node3D

@onready var controller_horizontal_turn_sensitivity: float = 0
@onready var controller_vertical_turn_sensitivity: float = 0
@onready var mouse_horizontal_turn_sensitivity: float = 0
@onready var mouse_vertical_turn_sensitivity: float = 0


var boosting: bool = false
var tick_y_rotation_input_sum: float = 0
var tick_x_rotation_input_sum: float = 0

var fire: bool = false

func _ready() -> void:
    controller_horizontal_turn_sensitivity = Utilities.data_dict["settings"]["controller_horizontal_turn_sensitivity"]
    controller_vertical_turn_sensitivity = Utilities.data_dict["settings"]["controller_vertical_turn_sensitivity"]
    mouse_horizontal_turn_sensitivity = Utilities.data_dict["settings"]["mouse_horizontal_turn_sensitivity"]
    mouse_vertical_turn_sensitivity = Utilities.data_dict["settings"]["mouse_vertical_turn_sensitivity"]


# TODO: Controler support
func _input(event: InputEvent) -> void:
    #capture mouse movements
    if event is InputEventMouseButton:
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    elif event.is_action_pressed("ui_cancel"):
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

    if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        if event is InputEventMouseMotion:
            # TODO sensitivity setting
            tick_y_rotation_input_sum += -event.relative.x * mouse_horizontal_turn_sensitivity
            tick_x_rotation_input_sum += -event.relative.y * mouse_vertical_turn_sensitivity
            
    #if event is InputEventJoypadMotion:
        #tick_y_rotation_input_sum += Input.get_axis("turn_right", "turn_left")
        #tick_x_rotation_input_sum += Input.get_axis("turn_down", "turn_up")
    
    
func _physics_process(_delta: float) -> void:
    var input_dir_local: Vector3 = get_input_direction()
    # emmit signals
    SignalManager.directional_input_received.emit(input_dir_local)
    SignalManager.rotation_input_received.emit(Vector2(tick_x_rotation_input_sum, tick_y_rotation_input_sum))
    tick_x_rotation_input_sum = Input.get_axis("turn_down", "turn_up") * controller_vertical_turn_sensitivity # 0
    tick_y_rotation_input_sum = Input.get_axis("turn_right", "turn_left") * controller_horizontal_turn_sensitivity # 0
    
    # Trigger pulled
    # Change to trigger?
    fire = Input.is_action_pressed("fire")
    if fire:
        SignalManager.fire_input.emit()
        fire = false
    
    boosting = Input.is_action_pressed("boost")
    SignalManager.boost_input.emit(boosting)

    if Input.is_action_just_pressed("target_select"):
        SignalManager.target_select_input.emit()
    

func get_input_direction() -> Vector3:
    var input_right = Input.get_axis("left", "right")
    var input_up = Input.get_axis("down","up")
    # -z is forward
    var input_forward = Input.get_axis("forward", "back")
    return Vector3(input_right, input_up, input_forward).normalized()
