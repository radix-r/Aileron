## This script contains the level logic for the field front test area. The goal 
## is for the level to spawn npcs on opposing teams that move tward an objective 
## and shoot at enemies. The player will be able to target, shoot, and destroy
## enemy units. Enemy and allied units will be able to do the same 
extends BaseLevelLogic 
class_name FieldFrontLevelLogic

@export var combat_logic: CombatLogic = null
@export var actors_root: Node3D = null
@export var env_root: Node3D = null 
@export var ai_logic: AiFieldFrontLogic = null



@onready var PLAYER_TEAM: String = "Player"
@onready var OPPONENT_TEAM: String = "CPU"
@onready var ENVIRNOMENT_TEAM: String = "env"

@onready var player_starting_pos: Vector3 = Vector3(0, 10, 0)
@onready var player_starting_rotation: Vector3 = Vector3(0, PI, 0)



@onready var game_timer: Timer = Timer.new()
@onready var time_label_update_timer: Timer = Timer.new()
## Base format for timer label
@onready var timer_format: String = "%02d:%02d"



@onready var start_tick: int = Time.get_ticks_msec()

var aa_gun_scene: PackedScene = load("res://scenes/actors/aa_gun.tscn")
var aa_gun_starting_pos: Vector3 = Vector3(5, 5, 5)

# TODO red spawn zone, blue spawn zone
# TODO objective
#var level_state: ObstacleLevelState

func _ready() -> void:
    connect_input_signals()
    SignalManager.reached_0_hp.connect(_on_reached_0_hp)
    #print_debug(scene_file_path)
    #level_state = GameState.get_level_state("res://scenes/levels/obstacle_level_0.tscn")
    #if level_state == null:
    #    level_state = ObstacleLevelState.new()
    
    # Instantiate team relations
    targeting_logic.set_team_targetability(PLAYER_TEAM, ENVIRNOMENT_TEAM)
    targeting_logic.set_team_targetability(OPPONENT_TEAM, PLAYER_TEAM)
    targeting_logic.set_team_targetability(OPPONENT_TEAM, ENVIRNOMENT_TEAM)
    
    
    player_node = player_scene.instantiate()
    player_node.set_player_control(true)
    init_physics_actor(player_node, player_starting_pos, player_starting_rotation, PLAYER_TEAM)
    
    # Start spawner
    # TODO: Spawn enemies and alies
    var test_aa_gun = aa_gun_scene.instantiate()
    init_physics_actor(test_aa_gun, aa_gun_starting_pos, Vector3.ZERO, OPPONENT_TEAM)

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
    
    

func _physics_process(delta: float) -> void:
    pass

func _process(delta: float) -> void:
    update_hud()

func _on_ball_despawn_location_body_entered(body: Node3D) -> void:
    # despawn if ball
    #print_debug(body.name + " Entered Despawn Zone")
    if targeting_logic.node_team_dict.has(body):
        #print_debug(body.name + " in team dict")
        if targeting_logic.node_team_dict[body] == ENVIRNOMENT_TEAM:
            targeting_logic.remove_targetable_node(body)
            body.queue_free()


func _on_game_timer_timeout() -> void:
    pass


func _on_reached_0_hp(node: Node3D):
    ai_logic.remove_unit(node)
    # Spaw Explosion
    # Remove from targeting
    
   
## Get all nodes targetable by given node acording to team
func get_targetable(node: Node3D) -> Array[Node3D]:
    return targeting_logic.get_targetable(node)


func get_closest_targetable(node: Node3D) -> Node3D:
    return targeting_logic.get_closest_target(node)


func get_selected_target(targeter: Node3D) -> Node3D:
    return targeting_logic.get_selected_target(targeter)
    
     
func init_physics_actor(actor: BasePhysicsActor, init_location: Vector3, init_rotation: Vector3, team: String) -> void:
    actors_root.add_child(actor)
    actor.global_position = init_location
    actor.global_rotation = init_rotation
    targeting_logic.add_targetable_node(actor, team)
    # data driven max hp and stability
    combat_logic.init_combat_actor(actor)
    ai_logic.add_unit(actor)
    

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



    ## spawn ball
    ##print_debug("ball_spawn_timer")
    #var new_ball: RigidBody3D = ball_scene.instantiate()
    #var new_ball_pos: Vector3 = \
        #ball_spawn_location.position + Utilities.get_random_point_in_area(ball_spawn_location)
    #var new_ball_linear_velocity: Vector3 = \
        #Utilities.generate_random_unit_vector() * randf_range(0, ball_max_init_velocity)
    #var new_ball_angular_velocity: Vector3 = \
        #Utilities.generate_random_unit_vector() * randf_range(0, ball_max_init_velocity)
    #new_ball.scale *= ball_scale
    #init_physics_object(new_ball, new_ball_pos, Vector3.ZERO, ENVIRNOMENT_TEAM, new_ball_linear_velocity, new_ball_angular_velocity)
    ## restart timer
    #ball_spawn_timer.start()


## Returns true on sucsessful target assignemnt
func set_selected_target(targeter: Node3D, target: Node3D) -> bool:
    return targeting_logic.set_selected_target(targeter, target)


func update_stability_bar(actor: BasePhysicsActor, fraction_full: float) -> void:
    hud_anchor.update_stability_bar(fraction_full, actor)


func update_time_label():
    var elapsed_usec: int = Time.get_ticks_msec() - start_tick
    
    @warning_ignore("integer_division")
    var mins: int = elapsed_usec / (60 * 1000)
    @warning_ignore("integer_division")
    var secs: int =  int(elapsed_usec / 1000) % 60
    hud_anchor.set_timer(timer_format % [mins, secs])

#func on_ball_spawn_timer_timeout():


func update_hp_bar(actor: BasePhysicsActor, fraction_full: float) -> void:
    hud_anchor.update_hp_bar(fraction_full, actor)
