class_name LevelLogic extends Node3D

# TODO orginize varables. make private?
@onready var objects_in_force_field: Dictionary = {}
@onready var foce_field_force_newtons: float = 1000
@onready var node_hp_dict: Dictionary = {}
@onready var node_stability_dict: Dictionary = {}

@onready var player_scene: PackedScene = preload("res://Scenes/Actors/ship_physics.tscn")
@onready var ball_scene: PackedScene = preload("res://Scenes/ball.tscn") 
@onready var opponent_scene: PackedScene = preload("res://Scenes/Actors/base_physics_actor.tscn")

@export var ai_logic: AiLogic = null
@export var targeting_logic: TargetingLogic = null # $"../TargetingLogic"
@export var hud_logic: HudLogic = null
@export var hud_anchor: HudAnchor = null #$"../../UI/HudAnchor"
@export var actors_root: Node3D = null
@export var env_root: Node3D = null 


@onready var goal1: Goal = $"../../Environment/Arena2/Goal1"
@onready var goal2: Goal = $"../../Environment/Arena2/Goal2"

@onready var PLAYER_TEAM: String = "1"
@onready var OPPONENT_TEAM: String = "2"
@onready var ENVIRNOMENT_TEAM: String = "env"
@onready var team_score_dict: Dictionary = {}
@onready var SCORE_STR_TAMPLATE: String = "Team {team_1}: {team_1_score}\n" + \
        "Team {team_2}: {team_2_score}"
@onready var player_starting_pos: Vector3 = Vector3(0, 0, -96)
@onready var player_starting_rotation: Vector3 = Vector3(0, PI, 0)
@onready var opponent_starting_pos: Vector3 = Vector3(0, 0, 96)
@onready var opponent_starting_rotation: Vector3 = Vector3(0, 0, 0)
@onready var ball_starting_position: Vector3 = Vector3(0, 20, 0)

@onready var player_node: PlayerPhysicsShip = null
@onready var teammate_node: BasePhysicsActor = null
@onready var ball_node: RigidBody3D = null
@onready var opponent_node: BasePhysicsActor = null


# Delay between a goal beiong scored and the arena reseting
@onready var arena_reset_timer: Timer = Timer.new()

func _ready() -> void:
    SignalManager.arena_force_field_entered.connect(add_object_in_force_field)
    SignalManager.arena_force_field_exited.connect(remove_object_in_force_field)
    
    SignalManager.hit_by_projectile.connect(_on_hit_by_projectile)
    
    # Instantiate team relations
    targeting_logic.set_team_targetability(PLAYER_TEAM, ENVIRNOMENT_TEAM)
    targeting_logic.set_team_targetability(OPPONENT_TEAM, PLAYER_TEAM)
    targeting_logic.set_team_targetability(OPPONENT_TEAM, ENVIRNOMENT_TEAM)
    # init scores
    team_score_dict[PLAYER_TEAM] = 0
    team_score_dict[OPPONENT_TEAM] = 0
    update_score_ui()
    
    # Instantiate player, npcs, objects (ball)
    player_node = player_scene.instantiate()
    actors_root.add_child(player_node)
    player_node.global_position = player_starting_pos
    player_node.global_rotation = player_starting_rotation
    targeting_logic.add_targetable_node(player_node, PLAYER_TEAM)
    node_hp_dict[player_node] = 10
    node_stability_dict[player_node] = 10
    
    teammate_node = opponent_scene.instantiate()
    actors_root.add_child(teammate_node)
    teammate_node.global_position = player_starting_pos + Vector3(10, 0, 0)
    teammate_node.global_rotation = player_starting_rotation
    targeting_logic.add_targetable_node(teammate_node, PLAYER_TEAM)
    node_hp_dict[teammate_node] = 10
    node_stability_dict[teammate_node] = 10
    
    ball_node = ball_scene.instantiate()
    env_root.add_child(ball_node)
    ball_node.global_position = ball_starting_position
    targeting_logic.add_targetable_node(ball_node, ENVIRNOMENT_TEAM)
    
    opponent_node = opponent_scene.instantiate()
    actors_root.add_child(opponent_node)
    opponent_node.global_position = opponent_starting_pos
    targeting_logic.add_targetable_node(opponent_node, OPPONENT_TEAM)
    node_hp_dict[opponent_node] = 10
    node_stability_dict[opponent_node] = 10
    
    arena_reset_timer.wait_time = 4
    arena_reset_timer.one_shot = true
    add_child(arena_reset_timer)
    arena_reset_timer.timeout.connect(_on_arena_reset_timer_timeout)
    
    # get data values
    foce_field_force_newtons = Utilities.data_dict["Arena0"]["foce_field_force_newtons"]
    
    SignalManager.directional_input_received.connect(_on_directional_input_received)
    SignalManager.rotation_input_received.connect(_on_rotational_input_received)
    SignalManager.fire_input.connect(_on_fire_input)
    SignalManager.boost_input.connect(_on_boost_input)
    SignalManager.target_select_input.connect(_on_target_select_input)
    
    # TODO init score ui and game timer
    
    
    
func _on_arena_reset_timer_timeout() -> void:
    reset_arena()
    
    
func _on_boost_input(boosting: bool):
    if player_node:
        var boost_command: BoostCommand = BoostCommand.new(boosting)
        boost_command.execute(player_node)
        
            
func _on_fire_input():
    if player_node:
        var fire_command: FireCommand = FireCommand.new()
        fire_command.execute(player_node)
        
        
func _on_directional_input_received(direction: Vector3) -> void:
    # command player node to move with input
    if player_node:
        var move_command: MoveCommand = MoveCommand.new(direction)
        move_command.execute(player_node)    
        
        
func _on_goal_zone_1_body_entered(body: Node3D) -> void:
    #print_debug(body.name + " entered goal 1")
    if body.is_in_group("ball"):
        team_score_dict[OPPONENT_TEAM] += 1
        # update score ui
        update_score_ui()
        # score effects
        goal1.play_goal_effect()
        # reset arena
        arena_reset_timer.start()

func _on_goal_zone_2_body_entered(body: Node3D) -> void:
    #print_debug(body.name + " entered goal 2")
    if body.is_in_group("ball"):
        team_score_dict[PLAYER_TEAM] += 1
        update_score_ui()
        goal2.play_goal_effect()
        arena_reset_timer.start()

func _on_hit_by_projectile(hit_node: Node3D, projectile: Node3D) -> void:
    print_debug(hit_node.name + " hit by " + projectile.name)

func _on_rotational_input_received(x_y_rotation: Vector2):
    if player_node:
        var rotate_command: RotationCommand = RotationCommand.new(x_y_rotation)
        rotate_command.execute(player_node)




    
    
func _on_target_select_input():
    # Set player's selected target
    # find target closest to center screen
    var closest_target: Node3D = get_closest_target_to_boresight(player_node.name, player_node.camera)
    var result: int = targeting_logic.set_selected_target(player_node.name, closest_target.name)
    if 0 != result:
        print_debug("Failed to select next player target")
    
    
func _physics_process(delta: float) -> void:
    apply_force_field_effects(delta)
    
    if opponent_node && teammate_node && ball_node && goal1 && goal2:
        var opponent_move_command: MoveCommand = \
                ai_logic.get_input_direction_command(
                        opponent_node, 
                        ball_node.global_position, 
                        goal1.global_position, 
                        goal2.global_position)
        opponent_move_command.execute(opponent_node)
        
        var opponent_aim_location: Vector3 = \
                calculate_aim_location_3d(
                        ball_node.global_position, 
                        ball_node.linear_velocity, 
                        opponent_node.global_position, 
                        opponent_node.linear_velocity, 
                        opponent_node.weapon.projectile_speed)
        opponent_node.look_at(opponent_aim_location)
        
        var fire_command: FireCommand = FireCommand.new()
        #fire_command.execute(opponent_node)
        
        var teammate_move_command: MoveCommand = \
                ai_logic.get_input_direction_command(
                        teammate_node,
                        ball_node.global_position,
                        goal2.global_position,
                        goal1.global_position)
        #teammate_move_command.execute(teammate_node)
        
        teammate_node.look_at(opponent_aim_location)
        #fire_command.execute(teammate_node)
        
    #opponent_node.set_input_direction(opponent_input_dir)

func _process(_delta: float) -> void:
    draw_target_ui_for_cam(player_node.get_camera(), targeting_logic.get_targetable(player_node.name), targeting_logic.get_selected_target(player_node.name))
    hud_logic.update_velocity_marker(player_node)
    hud_logic.update_boresight(player_node)

func add_object_in_force_field(obj: RigidBody3D) -> void:
    objects_in_force_field[obj.name] = obj
    #print_debug(obj.name + " entered")


func apply_force_field_effects(_delta: float) -> void:
    for obj_name in objects_in_force_field:
        objects_in_force_field[obj_name].apply_central_force(Vector3.UP * foce_field_force_newtons)
    
    
func calculate_aim_indicator_location(camera: Camera3D, selected_target_global_pos: Vector3, selected_target_velocity: Vector3, player_golbal_pos: Vector3, player_velocity: Vector3, player_weapon_projectile_speed: float) -> Vector2:
    var aim_location_3d: Vector3 = calculate_aim_location_3d(selected_target_global_pos, selected_target_velocity, player_golbal_pos, player_velocity, player_weapon_projectile_speed)
    return Utilities.transform_to_hud_space(aim_location_3d, camera)


func calculate_aim_location_3d(selected_target_global_pos: Vector3, selected_target_velocity: Vector3, player_golbal_pos: Vector3, player_velocity: Vector3, player_weapon_projectile_speed: float):
    var vector_to_target: Vector3 = player_golbal_pos - selected_target_global_pos
    var distance_to_target: float = vector_to_target.length()
    var time_to_target: float = distance_to_target / (player_weapon_projectile_speed + (player_velocity * player_velocity.normalized().dot(vector_to_target.normalized())).length())
    var aim_location: Vector3 = selected_target_global_pos + selected_target_velocity * time_to_target
    return aim_location
    
    
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
        var aim_point_hud_pos: Vector2 = calculate_aim_indicator_location(camera,selected_target.global_position, selected_target_velocity ,player_node.global_position, player_node.linear_velocity, player_node.weapon.projectile_speed)
        hud_anchor.update_aim_indicator(camera, aim_point_hud_pos, selected_target.position)


func get_closest_target_to_boresight(targeter_name: String, camera: Camera3D) -> Node3D:

    var closest_target: Node3D = null
    var closest_dist: float = Utilities.MAX_FLOAT 
    var boresight_2d_pos: Vector2 = hud_anchor.boresight.position

    var targets: Array = targeting_logic.node_targetable_dict[targeter_name]
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


func update_score_ui():
    hud_anchor.set_objective_description(
            SCORE_STR_TAMPLATE.format({"team_1": PLAYER_TEAM,
                    "team_1_score": team_score_dict[PLAYER_TEAM],
                    "team_2": OPPONENT_TEAM,
                    "team_2_score": team_score_dict[OPPONENT_TEAM]
            })
    )


func remove_object_in_force_field(obj: RigidBody3D) -> void:
    objects_in_force_field.erase(obj.name)


func reset_arena() -> void:
    player_node.global_position = player_starting_pos
    player_node.global_rotation = player_starting_rotation
    
    teammate_node.global_position = player_starting_pos + Vector3(10, 0, 0)
    
    opponent_node.global_position = opponent_starting_pos
    
    ball_node.global_position = ball_starting_position
