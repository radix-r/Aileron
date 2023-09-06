extends Node3D

@onready var waypoint_system: Node3D = $Services/Navigation/WaypointSystem

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    waypoint_system.waypoint_arrived.connect(on_waypoint_arrived)
    waypoint_system.waypoints_finished.connect(on_waypoints_finished)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func on_waypoint_arrived(id: int) -> void:
    if id == 0:
        start_timer()


func on_waypoints_finished() -> void:
    stop_timer()

func start_timer() -> void:
    # start a timer and display it on the screen. Timer stops when player has
    # arrived at last waypoint
    pass

func stop_timer() -> void:
    # stop timer and save time to file
    pass
