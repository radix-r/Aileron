extends BaseLevelLogic
class_name CombatLevelLogic

@export var ai_logic: AiLogic = null
@export var targeting_logic: TargetingLogic = null # $"../TargetingLogic"
@export var hud_logic: HudLogic = null
@export var combat_logic: CombatLogic = null
@export var hud_anchor: HudAnchor = null #$"../../UI/HudAnchor"
@export var actors_root: Node3D = null
@export var env_root: Node3D = null 

@onready var player_scene: PackedScene = preload("res://scenes/actors/ship_physics.tscn")
@onready var opponent_scene: PackedScene = preload("res://scenes/actors/base_physics_actor.tscn")
@onready var explosion_scene: PackedScene = preload("res://scenes/fx/vfx_explosion.tscn")

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

@onready var player_node: PlayerPhysicsShip = null
@onready var teammate_node: BasePhysicsActor = null
@onready var opponent_node: BasePhysicsActor = null

# TODO data driven, changeable with menu option
@onready var team_size: int = 4
# TODO spawn areas
@onready var spawn_area_1: Area3D = $"../../Environment/Arena2/SpawnArea1"
@onready var spawn_area_2: Area3D = $"../../Environment/Arena2/SpawnArea2"



func _ready() -> void:
    
    SignalManager.directional_input_received.connect(_on_directional_input_received)
    SignalManager.rotation_input_received.connect(_on_rotational_input_received)
    SignalManager.fire_input.connect(_on_fire_input)
    SignalManager.boost_input.connect(_on_boost_input)
    SignalManager.target_select_input.connect(_on_target_select_input)
    SignalManager.reached_0_hp.connect(_on_reached_0_hp)

    # Instantiate team relations
    targeting_logic.set_team_targetability(PLAYER_TEAM, ENVIRNOMENT_TEAM)
    targeting_logic.set_team_targetability(OPPONENT_TEAM, PLAYER_TEAM)
    targeting_logic.set_team_targetability(OPPONENT_TEAM, ENVIRNOMENT_TEAM)
    # init scores
    team_score_dict[PLAYER_TEAM] = 0
    team_score_dict[OPPONENT_TEAM] = 0
    update_score_ui()
                
    
    # spawn actors in spawn area
    # init player
    player_node = player_scene.instantiate()
    init_physics_actor(player_node, player_starting_pos, player_starting_rotation, PLAYER_TEAM)
    # init player team
    for i in range(team_size - 1):
        var new_teammate: BasePhysicsActor = opponent_scene.instantiate()
        # get starting location. TODO check for overlaps?
        var init_pos = Utilities.get_random_point_in_area(spawn_area_1)
        init_pos += spawn_area_1.position
        init_physics_actor(new_teammate, init_pos, Vector3.ZERO, PLAYER_TEAM)
    
    # init opponent team
    for i in range(team_size):
        var new_opponent: BasePhysicsActor = opponent_scene.instantiate()
        # get starting location. TODO check for overlaps?
        var init_pos = Utilities.get_random_point_in_area(spawn_area_2)
        init_pos += spawn_area_2.position
        init_physics_actor(new_opponent, init_pos, Vector3.ZERO, OPPONENT_TEAM)
    
    
    
    
    
    
    
    
    
    
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

    elif PLAYER_TEAM in winner && winner.size() > 1:
        # tie
        hud_anchor.set_center_screen_label("TIE")

    else:
        # lose
        hud_anchor.set_center_screen_label("LOSE")
        
    hud_anchor.show_center_screen_label()


func _on_reached_0_hp(actor: BasePhysicsActor) -> void:
    # death animation
    var new_explosion: Node3D = explosion_scene.instantiate()
    
    add_child(new_explosion)
    new_explosion.global_position = actor.global_position
    
    
    # score update
    var team: String = targeting_logic.node_team_dict[actor]
    team_score_dict[team] -= 1
    update_score_ui()
    # move back to spawn
    # reset hp and stability
    _respawn(actor)

func _on_rotational_input_received(x_y_rotation: Vector2):
    if player_node:
        var rotate_command: RotationCommand = RotationCommand.new(x_y_rotation)
        rotate_command.execute(player_node)

    
# TODO move out of level logic?
## Set player's selected target
func _on_target_select_input():
    
    # find target closest to center screen
    var closest_target: Node3D = get_closest_target_to_boresight(player_node.name, player_node.camera)
    var result: int = -1
    if closest_target:
        result = targeting_logic.set_selected_target(player_node.name, closest_target.name)
    if 0 != result:
        print_debug("Failed to select next player target")


func _process(_delta: float) -> void:
    hud_logic.draw_target_ui_for_cam(player_node, player_node.get_camera(), targeting_logic.get_targetable(player_node.name), targeting_logic.get_selected_target(player_node.name))
    hud_logic.update_velocity_marker(player_node)
    hud_logic.update_boresight(player_node)


func _respawn(actor: BasePhysicsActor) -> void:
    var team: String = targeting_logic.get_team(actor)
    var new_pos: Vector3 = Vector3.ZERO
    if team == PLAYER_TEAM:
        new_pos = Utilities.get_random_point_in_area(spawn_area_1)
        new_pos += spawn_area_1.position
    elif team == OPPONENT_TEAM:
        new_pos = Utilities.get_random_point_in_area(spawn_area_2)
        new_pos += spawn_area_2.position
    else:
        print_debug("Unable to get respawn area")
    
    actor.global_position = new_pos
    actor.linear_velocity = Vector3.ZERO
    # reset hp and stability
    combat_logic.reset_actor(actor)
    
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


func update_stability_bar(actor: BasePhysicsActor, fraction_full: float) -> void:
    hud_anchor.update_stability_bar(fraction_full, actor)


func update_hp_bar(actor: BasePhysicsActor, fraction_full: float) -> void:
    hud_anchor.update_hp_bar(fraction_full, actor)
    

func update_score_ui() -> void:
    hud_logic.update_score_ui(
                SCORE_STR_TAMPLATE.format({"team_1": PLAYER_TEAM,
                    "team_1_score": team_score_dict[PLAYER_TEAM],
                    "team_2": OPPONENT_TEAM,
                    "team_2_score": team_score_dict[OPPONENT_TEAM]
            })
    )
