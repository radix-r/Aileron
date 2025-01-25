class_name GoTo extends ObjectiveManager

@export var timed: bool
# Node3D with child Node3D points to navigate too
@export var points_root: Node3D

signal waypoint_arrived(id: int)
signal waypoints_finished

@onready var waypoint: PackedScene = preload("res://Scenes/waypoint.tscn")
@onready var NO_WAYPOINT: Waypoint = waypoint.instantiate()
@onready var active_waypoint: Waypoint = NO_WAYPOINT
@onready var active_waypoint_index: int = 0
@onready var waypoints: Array = []


const DEFAULT_RADIUS: float = 40

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    for point in points_root.get_children():
        var new_waypoint: Waypoint = waypoint.instantiate()
        add_child(new_waypoint)
        new_waypoint.set_radius(DEFAULT_RADIUS)
        new_waypoint.set_disabled(true)
        new_waypoint.position = point.position
        new_waypoint.waypoint_arrived.connect(on_waypoint_arrived)
        waypoints.append(new_waypoint)

    if waypoints.size() > 0:
        waypoints[0].set_disabled(false)
        active_waypoint = waypoints[0]

func start_objective() -> void:
    pass


func on_waypoint_arrived(body: Node3D, id: int) -> void:
    var player_found: bool = false

    for group in body.get_groups():
        player_found = player_found || group == "player"

    if !player_found:#|| id != active_waypoint.id:
        return

    
    waypoints[active_waypoint_index].set_disabled(true)
    active_waypoint_index += 1

    if active_waypoint_index >= waypoints.size():
        waypoints_finished.emit()
        active_waypoint = NO_WAYPOINT
        return
    else:
        waypoints[active_waypoint_index].set_disabled(false)
        active_waypoint = waypoints[active_waypoint_index]

    waypoint_arrived.emit(id)
