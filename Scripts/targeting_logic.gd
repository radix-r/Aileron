class_name TargetingLogic extends Node3D
# This script is responsible for the logic of who is targeting who.
# For each enntity that can target other entities the following will be maintained
# 1. A list of nodes it can target
# 2. The entitie's currently selected target
# 3. The entitie's team
# 4. The teams the entity can target

# Key: Node name, Value: Node refference
# Dict of all targetable nodes in scene
var all_targetable_dict: Dictionary = {}
# Key: Node name, Value: Array of targetable nodes
var node_targetable_dict: Dictionary = {}
# Key: Node name, Value: Currently selected target name
var node_selected_target_dict: Dictionary = {}
# Key: Team name, Value: Array of node names on that team
var team_node_dict: Dictionary = {}
# Key: Team, Value: Array of team names given team can target
var team_targetability_dict: Dictionary = {}

@export var hud_anchor: HudAnchor = null #$"../../UI/HudAnchor"

@export var level_logic: LevelLogic = null # $"../LevelLogic"

func _ready() -> void:
    # get all nodes in targetable group. What teams are they? Handel in level logic?
    var target_list = get_tree().get_nodes_in_group("targetable")
    for target in target_list:
        all_targetable_dict[target.name] = target
    pass

func _process(_delta: float) -> void:
    pass

# To be called whenever a targetable node is added to a scene
func add_targetable_node(node: Node3D, team: String) -> void:
    all_targetable_dict[node.name] = node
    # Assume team name already init?
    add_to_team(node, team)
    var targetable: Array = []
    for targetable_team in team_targetability_dict[team]:
        if team_node_dict.has(targetable_team):
            targetable.append_array(team_node_dict[targetable_team])
            # add new node to hostile team target dicts
            for hostile_node in team_node_dict[targetable_team]:
                #print_debug("Adding " + node.name + " to " + hostile_node.name + "'s targets")
                node_targetable_dict[hostile_node.name].append(node)
    node_targetable_dict[node.name] = targetable
    # create new target indicator
    hud_anchor.add_target_indicator(node)

func add_to_team(node: Node3D, team: String) -> void:
    if team_node_dict.has(team):
        team_node_dict[team].append(node)
    else:
        team_node_dict[team] = [node]
        
# Return an array of all nodes given node can target   
func get_targetable(node_name: String) -> Array:
    # 
    var targets: Array = []
    if node_targetable_dict.has(node_name):
        targets = node_targetable_dict[node_name]
    return targets        
    

func remove_targetable_node(node: Node3D) -> void:
    hud_anchor.remove_target_indicator(node.name)
    # TODO remove from target dicts

func set_team_targetability(team: String, can_target_team: String) -> void:
    if team_targetability_dict.has(team):
        team_targetability_dict[team].append(can_target_team)
    else:
        team_targetability_dict[team] = [can_target_team]
        
    if team_targetability_dict.has(can_target_team):
        team_targetability_dict[can_target_team].append(team)
    else:
        team_targetability_dict[can_target_team] = [team] 
