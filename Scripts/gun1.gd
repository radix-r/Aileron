extends Node3D


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
var bullet: PackedScene = preload("res://Scenes/bullet_1.tscn")

#####################################
# PRIVATE VARIABLES
#####################################

#####################################
# ONREADY VARIABLES
#####################################
@onready var fire_cooldown: float = 0
@onready var projectile_speed: float = 0
@onready var can_fire: bool = true
@onready var platform: PhysicsBody3D = $"../.."
@onready var fire_point: Node3D = $FirePoint
@onready var muzzel_flash: Node3D = $FirePoint/MuzzleFlash1
@onready var cooldown: Timer = Timer.new()
@onready var root = get_node("/root/")
#####################################
# OVERRIDE FUNCTIONS
#####################################

func _physics_process(_delta: float) -> void:
    var triggered = Input.is_action_pressed("fire")
    if triggered and can_fire:
        fire()


func _ready() -> void:
    var unit_name = "Gun1"
    fire_cooldown = Utilities.data_dict[unit_name]["fire_cooldown"]
    projectile_speed = Utilities.data_dict[unit_name]["projectile_speed"]
    cooldown.wait_time = fire_cooldown
    cooldown.one_shot = true
    add_child(cooldown)
    cooldown.connect("timeout", _on_cooldown)
#####################################
# API FUNCTIONS
#####################################

#####################################
# HELPER FUNCTIONS
#####################################

func _on_cooldown():
    can_fire = true


func fire():
    can_fire = false
    # start timer for firing cooldown
    cooldown.start()
    # spawn a bullet
    var bullet_instace: CharacterBody3D = bullet.instantiate()
    # I have no idea why platform velocity needs to be devided by 60
    bullet_instace.velocity = platform.velocity/60 + (platform.forward * projectile_speed)
    root.add_child(bullet_instace)
    bullet_instace.global_position = fire_point.global_position
    bullet_instace.global_rotation = fire_point.global_rotation
    muzzel_flash.get_node("AnimationPlayer").play("Fire")
