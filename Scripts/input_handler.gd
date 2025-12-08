extends Node3D

var tick_y_rotation_input_sum: float = 0
var tick_x_rotation_input_sum: float = 0

var fire: bool = false

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
            
    
    
    
func _physics_process(_delta: float) -> void:
    var input_dir_local: Vector3 = get_input_direction()
    # emmit signals
    # Use command here? then I'd have to know 
    SignalManager.directional_input_received.emit(input_dir_local)
    SignalManager.rotation_input_received.emit(Vector2(tick_x_rotation_input_sum, tick_y_rotation_input_sum))
    tick_x_rotation_input_sum = 0
    tick_y_rotation_input_sum = 0
    
    # Trigger pulled
    # Change to trigger?
    fire = Input.is_action_pressed("fire")
    if fire:
        SignalManager.fire_input.emit()
        fire = false
    
func get_input_direction() -> Vector3:
    var input_right = Input.get_axis("left", "right")
    var input_up = Input.get_axis("down","up")
    # -z is forward
    var input_forward = Input.get_axis("forward", "back")
    return Vector3(input_right, input_up, input_forward).normalized()
