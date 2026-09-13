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
@onready var ball_scene: PackedScene = preload("res://scenes/ball_obstacle.tscn") 

func _ready() -> void:
    connect_input_signals()
    
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



func on_ball_spawn_timer_timeout():
    # spawn ball
    #print_debug("ball_spawn_timer")
    var new_ball = ball_scene.instantiate()
    var new_ball_pos: Vector3 = \
        ball_spawn_location.position + Utilities.get_random_point_in_area(ball_spawn_location)
    var new_ball_linear_velocity: Vector3 = \
        Utilities.generate_random_unit_vector() * randf_range(0, ball_max_init_velocity)
    var new_ball_angular_velocity: Vector3 = \
        Utilities.generate_random_unit_vector() * randf_range(0, ball_max_init_velocity)
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
