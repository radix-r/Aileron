class_name Goal extends Node3D

@onready var sparks: PackedScene = preload("res://Scenes/sparks1.tscn")

@onready var goal_light: Node3D = $GoalLight

@onready var rotate_lights: bool = false
# TODO data driven
@onready var lights_duration: float = 3
@onready var lights_timer: Timer = Timer.new()


func _ready() -> void:
    lights_timer.one_shot = true
    lights_timer.timeout.connect(_on_lights_timer_timeout)
    add_child(lights_timer)
    
func _physics_process(delta: float) -> void:
    if rotate_lights:
        goal_light.rotate_object_local(Vector3.FORWARD, 2*PI*delta)

func _on_lights_timer_timeout():
    rotate_lights = false

func play_goal_effect():
    # rotate light 3 times at 1 rev per sec
    rotate_lights = true
    lights_timer.start(lights_duration)
