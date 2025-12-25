class_name Weapon extends Node3D
# TODO base weapon class

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
var bullet_scene: PackedScene = preload("res://scenes/bullet_2.tscn")

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
@onready var root = Utilities.get_level_root()
@onready var triggered: bool = false
#####################################
# OVERRIDE FUNCTIONS
#####################################



func _ready() -> void:
    var unit_name = "Gun2"
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


func fire(shooter: Node):
    if can_fire:
        can_fire = false
        # start timer for firing cooldown
        cooldown.start()
        # spawn a bullet
        var bullet_instace: Projectile = bullet_scene.instantiate()
        
        # I have no idea why platform velocity needs to be devided by 60
        bullet_instace.linear_velocity = platform.linear_velocity/60 + (platform.forward * projectile_speed)
        root.add_child(bullet_instace)
        bullet_instace.shot_by = shooter
        bullet_instace.global_position = fire_point.global_position
        bullet_instace.global_rotation = fire_point.global_rotation
        muzzel_flash.get_node("AnimationPlayer").play("Fire")
