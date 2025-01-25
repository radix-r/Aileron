extends Node3D

@onready var go_to_objective = GoTo.new()

# Publish objective/target location for waypoint arrow
var current_target: Node3D

func _ready() -> void:
    go_to_objective.points_root = $"../Navigation/Points"
    add_child(go_to_objective)
    current_target = go_to_objective.active_waypoint
