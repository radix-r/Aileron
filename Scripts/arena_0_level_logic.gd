class_name LevelLogic extends Node3D

@onready var objects_in_force_field: Dictionary = {}
# TODO make data driven
@onready var foce_field_force_newtons: float = 1000
@onready var player_scene: PackedScene = preload("res://Scenes/Actors/ship_physics.tscn")
@onready var ball_scene: PackedScene = preload("res://Scenes/ball.tscn") 

@export var targeting_logic: TargetingLogic = null # $"../TargetingLogic"
@export var hud_logic: HudLogic = null
@export var hud_anchor: HudAnchor = null #$"../../UI/HudAnchor"
@export var actors_root: Node3D = null
@export var env_root: Node3D = null 


@onready var PLAYER_TEAM: String = "1"
@onready var ENVIRNOMENT_TEAM: String = "env"

@onready var player_node: PlayerPhysicsShip = null
@onready var ball_node: RigidBody3D = null



func _ready() -> void:
    pass
    SignalManager.arena_force_field_entered.connect(add_object_in_force_field)
    SignalManager.arena_force_field_exited.connect(remove_object_in_force_field)
    
    # Instantiate team relations
    targeting_logic.set_team_targetability(PLAYER_TEAM, ENVIRNOMENT_TEAM)
    # TODO Instantiate player, npcs, objects (ball)
    player_node = player_scene.instantiate()
    actors_root.add_child(player_node)
    player_node.global_position = Vector3(0, 0, -96)
    player_node.global_rotation = Vector3(0, -180, 0)
    targeting_logic.add_targetable_node(player_node, PLAYER_TEAM)
    
    ball_node = ball_scene.instantiate()
    env_root.add_child(ball_node)
    ball_node.global_position = Vector3(0, 20, 0)
    targeting_logic.add_targetable_node(ball_node, ENVIRNOMENT_TEAM)
    
func _physics_process(delta: float) -> void:
    apply_force_field_effects(delta)


func _process(delta: float) -> void:
    draw_target_ui_for_cam(player_node.get_camera(), targeting_logic.get_targetable(player_node.name), null)
    hud_logic.update_velocity_marker(player_node)
    hud_logic.update_boresight(player_node)

func add_object_in_force_field(obj: RigidBody3D) -> void:
    objects_in_force_field[obj.name] = obj
    #print_debug(obj.name + " entered")


func apply_force_field_effects(_delta: float) -> void:
    for obj_name in objects_in_force_field:
        objects_in_force_field[obj_name].apply_central_force(Vector3.UP * foce_field_force_newtons)
    
    
    
    
func draw_target_ui_for_cam(camera: Camera3D, targets: Array, selected_target: Node3D) -> void:
    # draw targets
    hud_anchor.update_target_indicators(camera, targets)
    # draw selected target
    hud_anchor.update_selected_target_indicator(camera, selected_target)
    pass



func remove_object_in_force_field(obj: RigidBody3D) -> void:
    objects_in_force_field.erase(obj.name)
