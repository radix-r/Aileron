class_name TargetingLogic extends Node3D
# This script is responsible for the logic of who is targeting who.
# For each enntity that can target other entities the following will be maintained
# 1. A list of nodes it can target
# 2. The entitie's currently selected target
# 3. The entitie's team
# 4. The teams the entity can target

## Key: Node name, Value: Node refference
## Dict of all targetable nodes in scene
var all_targetable_dict: Dictionary = {}

## Key: Node name, Value: Array of targetable nodes
var node_targetable_dict: Dictionary = {}

## Key: Node name, Value: Currently selected target node reff
var node_selected_target_dict: Dictionary = {}

## Key: Node, Value: Team node is on. 
## Node can only be on one team for now
var node_team_dict: Dictionary = {}

## Key: Team name, Value: Array of nodes on that team
var team_node_dict: Dictionary = {}

## Key: Team, Value: Array of team names given team can target
var team_targetability_dict: Dictionary = {}

@export var hud_anchor: HudAnchor = null #$"../../UI/HudAnchor"

#@export var level_logic: LevelLogic = null # $"../LevelLogic"

func _ready() -> void:
    # get all nodes in targetable group. What teams are they? Handel in level logic?
    var target_list = get_tree().get_nodes_in_group("targetable")
    for target in target_list:
        all_targetable_dict[target.name] = target
    pass

func _process(_delta: float) -> void:
    pass

# To be called whenever a targetable node is added to a scene
# Assumes all targetable nodes can target
func add_targetable_node(node: Node3D, team: String) -> void:
    all_targetable_dict[node.name] = node
    node_selected_target_dict[node.name] = null
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
    # TODO Should I pass this to level logic to then pass to hud?
    hud_anchor.add_target_indicator(node)

func add_to_team(node: Node3D, team: String) -> void:
    if team_node_dict.has(team):
        team_node_dict[team].append(node)
    else:
        team_node_dict[team] = [node]
    
    # TODO maybe array of teams in future?
    node_team_dict[node] = team
        
# Return an array of all nodes given node can target   
func get_targetable(node_name: String) -> Array:
    # 
    var targets: Array = []
    if node_targetable_dict.has(node_name):
        targets = node_targetable_dict[node_name]
    return targets        
    

# TODO new dict that has node to team mapping?
func get_team(node: Node3D) -> String:
    var team: String = ""
    #var return_val = team_node_dict.find_key(node)
    if node_team_dict.has(node):
        team = node_team_dict[node]
    return team
    
    
func get_closest_target(targeter_name: String) -> Node3D:
    var closest_target: Node3D = null
    var targeter: Node3D = all_targetable_dict[targeter_name]
    var closest_dist: float = 1.79769e308
    if node_selected_target_dict.has(targeter_name):
        for target: Node3D in node_targetable_dict[targeter_name]:
            var dist: float = (targeter.global_position - target.global_position).length()
            if closest_dist > dist:
                closest_dist = dist
                closest_target = target
    return closest_target





func get_next_closest_target(targeter_name: String) -> Node3D:
    # TODO
    # sort nodes by closest
    # find current target
    # return next target
    return null


func get_selected_target(targeter_name: String) -> Node3D:
    var return_value: Node3D = null
    if node_selected_target_dict.has(targeter_name):
        return_value = node_selected_target_dict[targeter_name]
    return return_value

## returns true if both node are on the same team
## also returns true if both nodes are on no team
func is_same_team(node_a: Node3D, node_b: Node3D) -> bool:
    var node_a_team: String = get_team(node_a)
    var node_b_team: String = get_team(node_b)
    
    return node_a_team == node_b_team


func remove_targetable_node(node: Node3D) -> void:
    hud_anchor.remove_target_indicator(node.name)
    # TODO remove from target dicts

## Attempts to set given targeter's selected target. 
## @returns 0 on sucess returns -1 on failure
func set_selected_target(targeter_name: String, selected_target_name: String) -> int:
    var return_val = -1
    if node_targetable_dict.has(targeter_name) && \
            node_targetable_dict[targeter_name].has(all_targetable_dict[selected_target_name]):
        node_selected_target_dict[targeter_name] = all_targetable_dict[selected_target_name]
        return_val = 0
        #print_debug(targeter_name + "'s selected target is " + selected_target_name)
    return return_val



func set_team_targetability(team: String, can_target_team: String) -> void:
    if team_targetability_dict.has(team):
        team_targetability_dict[team].append(can_target_team)
    else:
        team_targetability_dict[team] = [can_target_team]
        
    if team_targetability_dict.has(can_target_team):
        team_targetability_dict[can_target_team].append(team)
    else:
        team_targetability_dict[can_target_team] = [team] 
