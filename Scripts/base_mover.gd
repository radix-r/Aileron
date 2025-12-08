class_name BaseMover extends CharacterBody3D

@onready var acceleration: float = 0
@onready var speed_default: float = 0
@onready var speed_max: float = 0
@onready var speed_min: float = 0
@onready var rotation_speed: float = 0
@onready var momentum: float = 0
@onready var drag: float = 0
@onready var hp: int = 1
@onready var team: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
