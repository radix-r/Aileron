extends Node3D

#@onready var NO_WAYPOINT: Waypoint = Waypoint.new(0, Vector3(0, 0, 0))
#@onready var active_waypoint: Waypoint = NO_WAYPOINT
@onready var waypoint: PackedScene = preload("res://Scenes/waypoint.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var new_waypoint = waypoint.instantiate()

    add_child(new_waypoint)
    new_waypoint.set_radius(100.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
