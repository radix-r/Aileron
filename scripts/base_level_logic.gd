# base logic fo an Aileron level. This script or a child script shoud be 
# attached to the /LevelRoot/Services/LevelLogic/ node
# TODO what does this script do

extends Node
class_name BaseLevelLogic

var player_scene: PackedScene = load("res://scenes/actors/ship_physics.tscn")

@onready var player_node: PlayerPhysicsShip = null

@export var targeting_logic: TargetingLogic = null # $"../TargetingLogic"
@export var hud_logic: HudLogic = null
@export var hud_anchor: HudAnchor = null #$"../../UI/HudAnchor"

func _ready() -> void:
    connect_input_signals()
    # Spawn player ship
    instantiate_player_ship()

func _on_boost_input(boosting: bool):
    if player_node:
        var boost_command: BoostCommand = BoostCommand.new(boosting)
        boost_command.execute(player_node)


## command player node to move with input
func _on_directional_input_received(direction: Vector3) -> void:
    if player_node:
        var move_command: MoveCommand = MoveCommand.new(direction)
        move_command.execute(player_node)
        
                        
## command player node to fire on input
func _on_fire_input():
    if player_node:
        var fire_command: FireCommand = FireCommand.new()
        fire_command.execute(player_node)


func _on_rotational_input_received(x_y_rotation: Vector2):
    if player_node:
        var rotate_command: RotationCommand = RotationCommand.new(x_y_rotation)
        rotate_command.execute(player_node)

## Set player's selected target
func _on_target_select_input():
    
    # find target closest to center screen
    var closest_target: Node3D = get_closest_target_to_boresight(player_node, player_node.camera)
    var result: bool = targeting_logic.set_selected_target(player_node, closest_target)
    if !result:
        print_debug("Failed to select next player target")
    

func _process(delta: float) -> void:
    update_hud()

func connect_input_signals():
    SignalManager.directional_input_received.connect(_on_directional_input_received)
    SignalManager.rotation_input_received.connect(_on_rotational_input_received)
    SignalManager.fire_input.connect(_on_fire_input)
    SignalManager.boost_input.connect(_on_boost_input)
    SignalManager.target_select_input.connect(_on_target_select_input)


## Draw target indicators for given targets on given camera
func draw_target_ui_for_cam(camera: Camera3D, targets: Array, selected_target: Node3D) -> void:
    # draw targets
    # TODO: dont access hud anchor. instead go through hud logic?
    hud_anchor.update_target_indicators(camera, targets)
    # draw selected target
    hud_anchor.update_selected_target_indicator(camera, selected_target)
    var selected_target_velocity = Vector3.ZERO
    if selected_target is RigidBody3D:
        selected_target_velocity = selected_target.linear_velocity
    
    if selected_target:
        var aim_point_hud_pos: Vector2 = Utilities.calculate_aim_indicator_location(camera,selected_target.global_position, selected_target_velocity ,player_node.global_position, player_node.linear_velocity, player_node.weapon.projectile_speed)
        hud_anchor.update_aim_indicator(camera, aim_point_hud_pos, selected_target.position)



func get_closest_target_to_boresight(targeter_node: Node3D, camera: Camera3D) -> Node3D:

    var closest_target: Node3D = null
    var closest_dist: float = Utilities.MAX_FLOAT 
    var boresight_2d_pos: Vector2 = hud_anchor.boresight.position

    var targets: Array = targeting_logic.get_targetable(targeter_node) #node_targetable_dict[targeter_name]
    for target: Node3D in targets:
        var target_2d_pos: Vector2 = Utilities.transform_to_hud_space(target.global_position, camera)
        var dist: float = (boresight_2d_pos - target_2d_pos).length()
        # account for behind cam
        if camera.is_position_behind(target.global_position):
            dist = 10000 - dist
        if dist < closest_dist:
            closest_dist = dist
            closest_target = target
    return closest_target

## Spawn player ship as child. 
func instantiate_player_ship() -> void:
    player_node = player_scene.instantiate()
    add_child(player_node)

func update_hud():
    if player_node and targeting_logic and hud_logic:
        draw_target_ui_for_cam(player_node.get_camera(), targeting_logic.get_targetable(player_node), targeting_logic.get_selected_target(player_node))
        hud_logic.update_velocity_marker(player_node)
        hud_logic.update_boresight(player_node)
