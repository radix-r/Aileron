## This script contains the level logic for the obstical areana. The goal os for 
## the player to race up an obstacle course with moving platforms and falling 
## objects. The lower the time to get to ther endd the better. 

## TODO: ball spawner
##      Moving platforms
##      enemy racers
##          Go to next closest safe zone?  
extends BaseLevelLogic 
class_name ObstacleLevelLogic0

@export var combat_logic: CombatLogic = null
@export var actors_root: Node3D = null
@export var env_root: Node3D = null 

@export var ball_spawn_location: Area3D = null


@onready var PLAYER_TEAM: String = "Player"
@onready var OPPONENT_TEAM: String = "CPU"
@onready var ENVIRNOMENT_TEAM: String = "env"

@onready var player_starting_pos: Vector3 = Vector3(0, 0, -96)
@onready var player_starting_rotation: Vector3 = Vector3(0, PI, 0)

@onready var ball_spawn_timer: Timer = Timer.new()
@onready var ball_spawn_radius: float = 80 # TODO data driven
@onready var ball_spawn_cooldown: float = 5
@onready var ball_max_init_velocity: float = 100
@onready var ball_scale: float = 5
@onready var ball_scene: PackedScene = preload("res://scenes/ball_obstacle.tscn") 

@onready var game_timer: Timer = Timer.new()
@onready var time_label_update_timer: Timer = Timer.new()
## Base format for timer label
@onready var timer_format: String = "%02d:%02d"

@onready var start_tick: int = Time.get_ticks_msec()

var level_state: ObstacleLevelState

func _ready() -> void:
    connect_input_signals()
    #print_debug(scene_file_path)
    level_state = GameState.get_level_state("res://scenes/levels/obstacle_level_0.tscn")
    if level_state == null:
        level_state = ObstacleLevelState.new()
    
    # Instantiate team relations
    targeting_logic.set_team_targetability(PLAYER_TEAM, ENVIRNOMENT_TEAM)
    targeting_logic.set_team_targetability(OPPONENT_TEAM, PLAYER_TEAM)
    targeting_logic.set_team_targetability(OPPONENT_TEAM, ENVIRNOMENT_TEAM)
    
    player_node = player_scene.instantiate()
    init_physics_actor(player_node, player_starting_pos, player_starting_rotation, PLAYER_TEAM)

    # Start spawner
    ball_spawn_timer.one_shot = false
    ball_spawn_timer.wait_time = ball_spawn_cooldown
    add_child(ball_spawn_timer)
    ball_spawn_timer.timeout.connect(on_ball_spawn_timer_timeout)
    ball_spawn_timer.start()
    # start obstacles
    
    # Start timer
    # init game timer
    game_timer.one_shot = true
    add_child(game_timer)
    game_timer.timeout.connect(_on_game_timer_timeout)
    game_timer.start()
    
    
    time_label_update_timer.wait_time = .5
    time_label_update_timer.one_shot = false
    add_child(time_label_update_timer)
    time_label_update_timer.timeout.connect(update_time_label)
    time_label_update_timer.start()


func _process(delta: float) -> void:
    update_hud()
    
    pass

func init_physics_actor(actor: BasePhysicsActor, init_location: Vector3, init_rotation: Vector3, team: String) -> void:
    actors_root.add_child(actor)
    actor.global_position = init_location
    actor.global_rotation = init_rotation
    targeting_logic.add_targetable_node(actor, team)
    # data driven max hp and stability
    combat_logic.init_combat_actor(actor)

func init_physics_object(
        obj: RigidBody3D, init_location: Vector3, init_rotation: Vector3,
        team: String, init_linear_velocity: Vector3, init_angular_velocity: Vector3) -> void:
    
    env_root.add_child(obj)
    obj.global_position = init_location
    obj.global_rotation = init_rotation
    obj.angular_velocity = init_angular_velocity
    obj.linear_velocity = init_linear_velocity
    
    targeting_logic.add_targetable_node(obj, team)
    
    
    # data driven max hp and stability
    # TODO make balls destructable?
    #combat_logic.init_combat_actor(actor)


func update_time_label():
    var elapsed_usec: int = Time.get_ticks_msec() - start_tick
    
    @warning_ignore("integer_division")
    var mins: int = elapsed_usec / (60 * 1000)
    @warning_ignore("integer_division")
    var secs: int =  int(elapsed_usec / 1000) % 60
    hud_anchor.set_timer(timer_format % [mins, secs])

func on_ball_spawn_timer_timeout():
    # spawn ball
    #print_debug("ball_spawn_timer")
    var new_ball: RigidBody3D = ball_scene.instantiate()
    var new_ball_pos: Vector3 = \
        ball_spawn_location.position + Utilities.get_random_point_in_area(ball_spawn_location)
    var new_ball_linear_velocity: Vector3 = \
        Utilities.generate_random_unit_vector() * randf_range(0, ball_max_init_velocity)
    var new_ball_angular_velocity: Vector3 = \
        Utilities.generate_random_unit_vector() * randf_range(0, ball_max_init_velocity)
    new_ball.scale *= ball_scale
    init_physics_object(new_ball, new_ball_pos, Vector3.ZERO, ENVIRNOMENT_TEAM, new_ball_linear_velocity, new_ball_angular_velocity)
    # restart timer
    ball_spawn_timer.start()


func _on_ball_despawn_location_body_entered(body: Node3D) -> void:
    # despawn if ball
    #print_debug(body.name + " Entered Despawn Zone")
    if targeting_logic.node_team_dict.has(body):
        #print_debug(body.name + " in team dict")
        if targeting_logic.node_team_dict[body] == ENVIRNOMENT_TEAM:
            targeting_logic.remove_targetable_node(body)
            body.queue_free()


func _on_finish_area_body_entered(body: Node3D) -> void:
    # Stop timer. Log time. Trigger effect
    var elapsed_msec = Time.get_ticks_msec() - start_tick
    time_label_update_timer.stop()
    # Log time to game state
    level_state.best_times_ms.append(elapsed_msec)
    level_state.best_times_ms.sort()
    GlobalState.save()
    
    # Show times
    for t in level_state.best_times_ms:
        print(t)
    # Show "pres esc to quit or R to reset"
    


func _on_game_timer_timeout() -> void:
    pass
