class_name LevelLogic extends BaseLevelLogic

# TODO orginize varables. make private?
@onready var objects_in_force_field: Dictionary = {}
@onready var foce_field_force_newtons: float = 1000

## How long actor shoots for
@onready var burst_duration_timer: Timer = Timer.new()
## How long actor holds fire for
@onready var burst_cooldown_timer: Timer = Timer.new()
## Delay between a goal beiong scored and the arena reseting
@onready var arena_reset_timer: Timer = Timer.new()
## Timer for the game. Game is over when the timer reaches 0
@onready var game_timer: Timer = Timer.new()
## Timer to update time lable once a second
@onready var time_label_update_timer: Timer = Timer.new()

## Base format for timer label
@onready var timer_format: String = "%02d:%02d"

## actors that are ready to fire a burst
@onready var actors_ready_to_fire: Array = []

@onready var player_scene: PackedScene = preload("res://scenes/actors/ship_physics.tscn")
@onready var ball_scene: PackedScene = preload("res://scenes/ball.tscn") 
@onready var opponent_scene: PackedScene = preload("res://scenes/actors/base_physics_actor.tscn")

@export var ai_logic: AiLogic = null
@export var targeting_logic: TargetingLogic = null # $"../TargetingLogic"
@export var hud_logic: HudLogic = null
@export var combat_logic: CombatLogic = null
@export var hud_anchor: HudAnchor = null #$"../../UI/HudAnchor"
@export var actors_root: Node3D = null
@export var env_root: Node3D = null 


@onready var goal1: Goal = $"../../Environment/Arena2/Goal1"
@onready var goal2: Goal = $"../../Environment/Arena2/Goal2"
#@onready var pause_menu: CanvasLayer = $"../../UI/PauseMenu"

@onready var PLAYER_TEAM: String = "Player"
@onready var OPPONENT_TEAM: String = "CPU"
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




func _ready() -> void:
    #init signals
    SignalManager.arena_force_field_entered.connect(add_object_in_force_field)
    SignalManager.arena_force_field_exited.connect(remove_object_in_force_field)

    SignalManager.directional_input_received.connect(_on_directional_input_received)
    SignalManager.rotation_input_received.connect(_on_rotational_input_received)
    SignalManager.fire_input.connect(_on_fire_input)
    SignalManager.boost_input.connect(_on_boost_input)
    SignalManager.target_select_input.connect(_on_target_select_input)

    # Instantiate team relations
    targeting_logic.set_team_targetability(PLAYER_TEAM, ENVIRNOMENT_TEAM)
    targeting_logic.set_team_targetability(OPPONENT_TEAM, PLAYER_TEAM)
    targeting_logic.set_team_targetability(OPPONENT_TEAM, ENVIRNOMENT_TEAM)
    # init scores
    team_score_dict[PLAYER_TEAM] = 0
    team_score_dict[OPPONENT_TEAM] = 0
    update_score_ui()
    
    # get data values
    foce_field_force_newtons = Utilities.data_dict["Arena0"]["foce_field_force_newtons"]
    burst_cooldown_timer.wait_time = Utilities.data_dict["Arena0"]["burst_cooldown"]
    burst_duration_timer.wait_time = Utilities.data_dict["Arena0"]["burst_duration"]
    game_timer.wait_time = 60 * Utilities.data_dict["Arena0"]["game_time"]
    
    # config burst timers
    burst_cooldown_timer.one_shot = true
    burst_duration_timer.one_shot = true
    
    # Instantiate player, npcs, objects (ball)
    player_node = player_scene.instantiate()
    init_physics_actor(player_node, player_starting_pos, player_starting_rotation, PLAYER_TEAM)
    
    teammate_node = opponent_scene.instantiate()
    init_physics_actor(
            teammate_node,
            player_starting_pos + Vector3(10, 0, 0),
            player_starting_rotation,
            PLAYER_TEAM)
    actors_ready_to_fire.append(teammate_node)
    # start burst timer
    _on_burst_cooldown_timeout(teammate_node)
    
    ball_node = ball_scene.instantiate()
    env_root.add_child(ball_node)
    ball_node.global_position = ball_starting_position
    targeting_logic.add_targetable_node(ball_node, ENVIRNOMENT_TEAM)
    
    opponent_node = opponent_scene.instantiate()
    init_physics_actor(
            opponent_node,
            opponent_starting_pos,
            Vector3.ZERO,
            OPPONENT_TEAM)
    actors_ready_to_fire.append(opponent_node)
    _on_burst_cooldown_timeout(opponent_node)
    
    arena_reset_timer.wait_time = 4
    arena_reset_timer.one_shot = true
    add_child(arena_reset_timer)
    arena_reset_timer.timeout.connect(_on_arena_reset_timer_timeout)
    
    # init game timer
    game_timer.one_shot = true
    add_child(game_timer)
    game_timer.timeout.connect(_on_game_timer_timeout)
    game_timer.start()
    
    
    time_label_update_timer.wait_time = 1
    time_label_update_timer.one_shot = false
    add_child(time_label_update_timer)
    time_label_update_timer.timeout.connect(update_time_label)
    time_label_update_timer.start()
    
    
func _on_arena_reset_timer_timeout() -> void:
    reset_arena()
    
    
func _on_boost_input(boosting: bool):
    if player_node:
        var boost_command: BoostCommand = BoostCommand.new(boosting)
        boost_command.execute(player_node)
        

func _on_burst_duration_timeout(actor: BasePhysicsActor) -> void:
    if actor in actors_ready_to_fire:
        actors_ready_to_fire.erase(actor)
    # start burst cooldoen timer
    var new_timer: Timer= burst_cooldown_timer.duplicate()
    new_timer.timeout.connect(_on_burst_cooldown_timeout.bind(actor))
    add_child(new_timer)
    new_timer.start(burst_cooldown_timer.wait_time + randf() *2) # random variation

func _on_burst_cooldown_timeout(actor: BasePhysicsActor) -> void:
    if !(actor in actors_ready_to_fire):
        actors_ready_to_fire.append(actor)
    # Start burst duration timer
    var new_timer: Timer= burst_duration_timer.duplicate()
    new_timer.timeout.connect(_on_burst_duration_timeout.bind(actor))
    add_child(new_timer)
    new_timer.start(burst_duration_timer.wait_time + randf() *2)

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
        
        
func _on_game_timer_timeout():
    var highest_score: int = 0
    var score_team_dict: Dictionary = {}
    for team in team_score_dict:
        if score_team_dict.has(team_score_dict[team]):
            score_team_dict[team_score_dict[team]].append(team)
        else:
            score_team_dict[team_score_dict[team]] = [team]
    
    var scores: Array = score_team_dict.keys()
    scores.sort()
    highest_score = scores[-1]
    
    var winner: Array = score_team_dict[highest_score]
    #print_debug("Team " + winner + " wins!")
    print(winner)
    if PLAYER_TEAM in winner && winner.size() == 1:
        # Display win on screen
        hud_anchor.set_center_screen_label("WIN")
        SignalManager.emit_signal("level_won")

    elif PLAYER_TEAM in winner && winner.size() > 1:
        # tie
        hud_anchor.set_center_screen_label("TIE")
        SignalManager.emit_signal("level_lost")

    else:
        # lose
        hud_anchor.set_center_screen_label("LOSE")
        SignalManager.emit_signal("level_lost")

    hud_anchor.show_center_screen_label()
        
    # Go back to menu?
        
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



                        
                
func _on_rotational_input_received(x_y_rotation: Vector2):
    if player_node:
        var rotate_command: RotationCommand = RotationCommand.new(x_y_rotation)
        rotate_command.execute(player_node)

    
## Set player's selected target
func _on_target_select_input():
    
    # find target closest to center screen
    var closest_target: Node3D = get_closest_target_to_boresight(player_node.name, player_node.camera)
    var result: int = targeting_logic.set_selected_target(player_node.name, closest_target.name)
    if 0 != result:
        print_debug("Failed to select next player target")
    
    
#func _on_ui_cancel_input():
    #if pause_menu.visible:
        #pause_menu.hide()
        ## TODO resume time
        #get_tree().paused = false
    #else:
        #pause_menu.show()
        ## TODO pause time
        #get_tree().paused = true
        
func _physics_process(delta: float) -> void:
    apply_force_field_effects(delta)
    
    # Calculate AI movements and actions
    if opponent_node && teammate_node && ball_node && goal1 && goal2:
        var opponent_move_command: MoveCommand = \
                ai_logic.get_input_direction_command(
                        opponent_node, 
                        ball_node.global_position, 
                        goal1.global_position, 
                        goal2.global_position)
        opponent_move_command.execute(opponent_node)
        
        var opponent_aim_location: Vector3 = \
                Utilities.calculate_aim_location_3d(
                        ball_node.global_position, 
                        ball_node.linear_velocity, 
                        opponent_node.global_position, 
                        opponent_node.linear_velocity, 
                        opponent_node.weapon.projectile_speed)
        opponent_node.look_at(opponent_aim_location)
        
        var fire_command: FireCommand = FireCommand.new()
        if opponent_node in actors_ready_to_fire:
            fire_command.execute(opponent_node)
        
        var teammate_move_command: MoveCommand = \
                ai_logic.get_input_direction_command(
                        teammate_node,
                        ball_node.global_position,
                        goal2.global_position,
                        goal1.global_position)
        teammate_move_command.execute(teammate_node)
        
        teammate_node.look_at(opponent_aim_location)
        if teammate_node in actors_ready_to_fire:
            fire_command.execute(teammate_node)
        

    # 

func _process(_delta: float) -> void:
    draw_target_ui_for_cam(player_node.get_camera(), targeting_logic.get_targetable(player_node.name), targeting_logic.get_selected_target(player_node.name))
    hud_logic.update_velocity_marker(player_node)
    hud_logic.update_boresight(player_node)
    # update timer
    


            
            
func add_object_in_force_field(obj: RigidBody3D) -> void:
    objects_in_force_field[obj.name] = obj
    #print_debug(obj.name + " entered")






func apply_force_field_effects(_delta: float) -> void:
    for obj_name in objects_in_force_field:
        objects_in_force_field[obj_name].apply_central_force(Vector3.UP * foce_field_force_newtons)
    
    

    
    
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

func init_physics_actor(actor: BasePhysicsActor, init_location: Vector3, init_rotation: Vector3, team: String) -> void:
    actors_root.add_child(actor)
    actor.global_position = init_location
    actor.global_rotation = init_rotation
    targeting_logic.add_targetable_node(actor, team)
    # data driven max hp and stability
    combat_logic.init_combat_actor(actor)
    


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

func update_stability_bar(actor: BasePhysicsActor, fraction_full: float) -> void:
    hud_anchor.update_stability_bar(fraction_full, actor)

func update_hp_bar(actor: BasePhysicsActor, fraction_full: float) -> void:
    hud_anchor.update_hp_bar(fraction_full, actor)


func update_time_label():
    @warning_ignore("narrowing_conversion")
    var mins: int = game_timer.time_left / 60
    var secs: int =  int(game_timer.time_left) % 60
    hud_anchor.set_timer(timer_format % [mins, secs])


func remove_object_in_force_field(obj: RigidBody3D) -> void:
    objects_in_force_field.erase(obj.name)


func reset_arena() -> void:
    player_node.global_position = player_starting_pos
    player_node.global_rotation = player_starting_rotation
    
    teammate_node.global_position = player_starting_pos + Vector3(10, 0, 0)
    
    opponent_node.global_position = opponent_starting_pos
    
    ball_node.global_position = ball_starting_position
