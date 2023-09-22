extends Node3D

@export var waypoint_system: Node3D

@onready var timer: Timer = Timer.new()
@onready var stopwatch_label: Label = $UI/StopwatchLabel

var watch_running: bool = false
var time_elapsed: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    waypoint_system.waypoint_arrived.connect(on_waypoint_arrived)
    waypoint_system.waypoints_finished.connect(on_waypoints_finished)

    add_child(timer)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if watch_running:
        time_elapsed += delta
        # update lable
        var minutes: float = time_elapsed / 60
        var seconds: float = fmod(time_elapsed, 60)
        var milliseconds: float = fmod(time_elapsed, 1) * 100
        var time_string: String = "%02d:%02d.%02d" % [minutes, seconds, milliseconds]
        if stopwatch_label:
            stopwatch_label.text = time_string


func on_waypoint_arrived(id: int) -> void:
    if id == 0:
        start_timer()


func on_waypoints_finished() -> void:
    stop_timer()


func start_timer() -> void:
    # start a timer and display it on the screen. Timer stops when player has
    # arrived at last waypoint
    watch_running = true

func stop_timer() -> void:
    # stop timer and save time to file
    watch_running = false
