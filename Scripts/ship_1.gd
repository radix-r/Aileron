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

#####################################
# OVERRIDE FUNCTIONS
#####################################


func _ready() -> void:
    var dataDict: Dictionary = read_json_file("res://Data.json")
    speed = dataDict["Ship1"]["speed"]


func _physics_process(delta: float) -> void:
    var velocity: Vector3 = Vector3.FORWARD * speed
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

