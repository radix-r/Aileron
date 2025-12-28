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
@onready var MAX_FLOAT: float = 1.79769e308
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
func calculate_aim_indicator_location(camera: Camera3D, selected_target_global_pos: Vector3, selected_target_velocity: Vector3, player_golbal_pos: Vector3, player_velocity: Vector3, player_weapon_projectile_speed: float) -> Vector2:
    var aim_location_3d: Vector3 = calculate_aim_location_3d(selected_target_global_pos, selected_target_velocity, player_golbal_pos, player_velocity, player_weapon_projectile_speed)
    return Utilities.transform_to_hud_space(aim_location_3d, camera)


func calculate_aim_location_3d(selected_target_global_pos: Vector3, selected_target_velocity: Vector3, player_golbal_pos: Vector3, player_velocity: Vector3, player_weapon_projectile_speed: float):
    var vector_to_target: Vector3 = player_golbal_pos - selected_target_global_pos
    var distance_to_target: float = vector_to_target.length()
    var time_to_target: float = distance_to_target / (player_weapon_projectile_speed + (player_velocity * player_velocity.normalized().dot(vector_to_target.normalized())).length())
    var aim_location: Vector3 = selected_target_global_pos + selected_target_velocity * time_to_target
    return aim_location

func get_level_root() -> Node:
    var children: Array[Node] = get_tree().root.get_children()
    for child in children:
        if child.name == "LevelRoot":
            return child

    # root not found
    return null

func get_random_point_in_area(area: Area3D) -> Vector3:
    var shape_owner = area.shape_find_owner(0)
    var shape_node: Shape3D= area.shape_owner_get_shape(shape_owner, 0)
    var return_val: Vector3 = Vector3.ZERO
    
    if shape_node is BoxShape3D:
        var temp_x: float = randf_range(-shape_node.size.x/2.0, shape_node.size.x/2.0)
        var temp_y: float = randf_range(-shape_node.size.y/2, shape_node.size.y/2)
        var temp_z: float = randf_range(-shape_node.size.z/2, shape_node.size.z/2)
        return_val = Vector3(temp_x, temp_y, temp_z)

    return return_val

func read_json_file(file_path: String) -> Dictionary:
    var json_as_text = FileAccess.get_file_as_string(file_path)
    var json_as_dict = JSON.parse_string(json_as_text)
    if json_as_dict:
        return json_as_dict
    else:
        # TODO: Retrun error dict
        return Dictionary()

func transform_to_hud_space(world_space: Vector3, camera: Camera3D) -> Vector2:
    var screen_space: Vector2 = camera.unproject_position(world_space)
    return screen_space
