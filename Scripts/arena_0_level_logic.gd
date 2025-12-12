class_name LevelLogic extends Node3D

@onready var objects_in_force_field: Dictionary = {}
@onready var foce_field_force_newtons: float = 1000
@onready var player_scene: PackedScene = preload("res://Scenes/Actors/ship_physics.tscn")
@onready var ball_scene: PackedScene = preload("res://Scenes/ball.tscn") 
@onready var opponent_scene: PackedScene = preload("res://Scenes/Actors/base_physics_actor.tscn")

@export var targeting_logic: TargetingLogic = null # $"../TargetingLogic"
@export var hud_logic: HudLogic = null
@export var hud_anchor: HudAnchor = null #$"../../UI/HudAnchor"
@export var actors_root: Node3D = null
@export var env_root: Node3D = null 


@onready var PLAYER_TEAM: String = "1"
@onready var OPPONENT_TEAM: String = "2"
@onready var ENVIRNOMENT_TEAM: String = "env"


@onready var player_node: PlayerPhysicsShip = null
@onready var ball_node: RigidBody3D = null
@onready var opponent_node: BasePhysicsActor = null
@onready var opponent_move_timer: Timer = Timer.new()
@onready var opponent_input_dir: Vector3 = Vector3.UP

func _ready() -> void:
    SignalManager.arena_force_field_entered.connect(add_object_in_force_field)
    SignalManager.arena_force_field_exited.connect(remove_object_in_force_field)
    
    # Instantiate team relations
    targeting_logic.set_team_targetability(PLAYER_TEAM, ENVIRNOMENT_TEAM)
    targeting_logic.set_team_targetability(OPPONENT_TEAM, PLAYER_TEAM)
    targeting_logic.set_team_targetability(OPPONENT_TEAM, ENVIRNOMENT_TEAM)

    # Instantiate player, npcs, objects (ball)
    player_node = player_scene.instantiate()
    actors_root.add_child(player_node)
    player_node.global_position = Vector3(0, 0, -96)
    player_node.global_rotation = Vector3(0, -180, 0)
    targeting_logic.add_targetable_node(player_node, PLAYER_TEAM)
    
    ball_node = ball_scene.instantiate()
    env_root.add_child(ball_node)
    ball_node.global_position = Vector3(0, 20, 0)
    targeting_logic.add_targetable_node(ball_node, ENVIRNOMENT_TEAM)
    
    opponent_node = opponent_scene.instantiate()
    actors_root.add_child(opponent_node)
    opponent_node.global_position = Vector3(0, 0, 96)
    targeting_logic.add_targetable_node(opponent_node, OPPONENT_TEAM)
    
    opponent_move_timer.wait_time = 3
    opponent_move_timer.one_shot = false
    add_child(opponent_move_timer)
    opponent_move_timer.connect("timeout", _on_opponent_move_timer_timeout)
    opponent_move_timer.start()
    
    # get data values
    foce_field_force_newtons = Utilities.data_dict["Arena0"]["foce_field_force_newtons"]
    
    SignalManager.directional_input_received.connect(_on_directional_input_recieved)
    SignalManager.rotation_input_received.connect(_on_rotational_input_received)
    SignalManager.fire_input.connect(_on_fire_input)
    SignalManager.boost_input.connect(_on_boost_input)
    SignalManager.target_select_input.connect(_on_target_select_input)
    
func _on_opponent_move_timer_timeout():
    opponent_input_dir *= -1 
    
    
    
    
func _on_target_select_input():
    # Set player's selected target
    #targeting_logic.target
    print_debug("Select next player target")
    pass
    
    
func _physics_process(delta: float) -> void:
    apply_force_field_effects(delta)

    opponent_node.set_input_direction(opponent_input_dir)

func _process(_delta: float) -> void:
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

func _on_directional_input_recieved(direction: Vector3) -> void:
    # command player node to move with input
    if player_node:
        var move_command: MoveCommand = MoveCommand.new(direction)
        move_command.execute(player_node)


func _on_rotational_input_received(x_y_rotation: Vector2):
    if player_node:
        var rotate_command: RotationCommand = RotationCommand.new(x_y_rotation)
        rotate_command.execute(player_node)

func _on_fire_input():
    if player_node:
        var fire_command: FireCommand = FireCommand.new()
        fire_command.execute(player_node)

func _on_boost_input(boosting: bool):
    if player_node:
        var boost_command: BoostCommand = BoostCommand.new(boosting)
        boost_command.execute(player_node)


func remove_object_in_force_field(obj: RigidBody3D) -> void:
    objects_in_force_field.erase(obj.name)
