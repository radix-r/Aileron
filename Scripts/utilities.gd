extends Node


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
@onready var data_dict: Dictionary = {}

#####################################
# PRIVATE VARIABLES
#####################################

#####################################
# ONREADY VARIABLES
#####################################

#####################################
# OVERRIDE FUNCTIONS
#####################################
func _ready() -> void:
    data_dict = read_json_file("res://Data.json")



#####################################
# API FUNCTIONS
#####################################

#####################################
# HELPER FUNCTIONS
#####################################

func get_level_root() -> Node:
    var children: Array[Node] = get_tree().root.get_children()
    for child in children:
        if child.name == "LevelRoot":
            return child

    # root not found
    return null

# TODO: Move to utils file?
func read_json_file(file_path: String) -> Dictionary:
    var json_as_text = FileAccess.get_file_as_string(file_path)
    var json_as_dict = JSON.parse_string(json_as_text)
    if json_as_dict:
        return json_as_dict
    else:
        # TODO: Retrun error dict
        return Dictionary()
