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
@onready var speed: int = 0
@onready var rotation_speed: float = 0
@onready var pitch_point: Node3D = $PitchPoint
@onready var forward_point: Node3D = $PitchPoint/ForwardPoint
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
    var dataDict: Dictionary = read_json_file("res://Data.json")
    speed = dataDict["Ship1"]["speed"]
    rotation_speed = dataDict["Ship1"]["rotation_speed"]


func _physics_process(delta: float) -> void:
    # Move forward


    # Get input and handel turining, acel/decel
    var input_dir = Input.get_vector("left", "right", "up", "down")
    var direction = Vector3(input_dir.x, 0, 0).normalized()
    # input_dir.y # rotation with this?
    velocity = (forward_point.global_position - global_position).normalized() * speed
#    if direction:
#        velocity.y = direction.y * speed
#        velocity.x = direction.x * speed

    move_and_slide()
    var collision = move_and_collide(velocity * delta)
    if collision:
        print("Ship1 collided with ", collision.get_collider().name)


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

