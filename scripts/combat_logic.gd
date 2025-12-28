## This system implements functionality related to hp, stability, damage
extends Node3D
class_name CombatLogic

## Level logic node to pass information up to
@export var level_logic: BaseLevelLogic = null


var node_hp_dict: Dictionary = {}
var node_max_hp_dict: Dictionary = {}
var node_stability_dict: Dictionary = {}
var node_stability_regen_dict: Dictionary = {}
var node_max_stability_dict: Dictionary = {}

## array with all destabilized actors
@onready var actorts_destabilized: Array = []
## When true teammates can dammage eachother
@onready var friendly_fire: bool = false


func _ready() -> void:
    SignalManager.hit_by_projectile.connect(_on_hit_by_projectile)

func _on_hit_by_projectile(hit_node: Node3D, projectile: Projectile) -> void:
    # print_debug(hit_node.name + " hit by " + projectile.name)
    var hp_damage: float = projectile.hp_damage
    var stability_damage: float = projectile.stability_damage
    if hit_node in actorts_destabilized:
        stability_damage = 0
    if node_hp_dict.has(hit_node) && node_stability_dict.has(hit_node):
        if level_logic.targeting_logic.is_same_team(hit_node, projectile.shot_by) \
                && !friendly_fire:
                hp_damage = 0
                stability_damage = 0
        node_hp_dict[hit_node] -= hp_damage # projectile damage
        node_stability_dict[hit_node] -= stability_damage
        # print_debug(hit_node.name + " hp: " + str(node_hp_dict[hit_node]))
        if node_hp_dict[hit_node] <= 0:
            #print_debug(hit_node.name + " HP 0!")
            node_hp_dict[hit_node] = 0
            # emmit signal to level logic to apply effects
            SignalManager.reached_0_hp.emit(hit_node)
            
        if node_stability_dict[hit_node] <= 0:
            # print_debug(hit_node.name + " Stability 0!")
            node_stability_dict[hit_node] = 0
            # apply effect
            apply_destabilize_effect(hit_node)

        # draw hit effect to player screen
        if projectile.shot_by == level_logic.player_node:
            # TODO bad coupling?
            level_logic.hud_anchor.trigger_hit_marker()

            
        # refresh health and stability bar
        level_logic.update_hp_bar(hit_node, node_hp_dict[hit_node]/node_max_hp_dict[hit_node])
        level_logic.update_stability_bar(hit_node, node_stability_dict[hit_node]/node_max_stability_dict[hit_node])

func _physics_process(delta: float) -> void:
    # regen stability
    _regen_stability(delta)


func _regen_stability(delta:float) -> void:
    for actor in node_stability_regen_dict:
        if node_stability_dict[actor] < node_max_stability_dict[actor]:
            node_stability_dict[actor] += node_stability_regen_dict[actor] * delta
            # Update stability ui
            level_logic.update_stability_bar(actor, node_stability_dict[actor]/node_max_stability_dict[actor])


func apply_destabilize_effect(actor: BasePhysicsActor) -> void:
    # print_debug(actor.name + " Destabilized!")
    actor.flight_mode = BasePhysicsActor.FlightModes.OFF
    actor.linear_damp = 0
    # start timer to remove effect
    var destabilize_timer: Timer = Timer.new()
    destabilize_timer.one_shot = true
    destabilize_timer.timeout.connect(remove_destabilize_effect.bind(actor))
    add_child(destabilize_timer)
    # TODO time durraton data driven
    destabilize_timer.start(5)
    # keep track of who is destabilized
    actorts_destabilized.push_back(actor)



func init_combat_actor(actor: BasePhysicsActor) -> void:
    node_hp_dict[actor] = actor.max_hp
    node_max_hp_dict[actor] = actor.max_hp
    node_stability_dict[actor] = actor.max_stability
    node_stability_regen_dict[actor] = actor.stability_regen
    node_max_stability_dict[actor] = actor.max_stability


func remove_destabilize_effect(actor: BasePhysicsActor) -> void:
    # print_debug(actor.name + " Stabilized!")
    actor.flight_mode = BasePhysicsActor.FlightModes.HOVER
    actor.linear_damp = 1
    node_stability_dict[actor] = node_max_stability_dict[actor]
    if actorts_destabilized.has(actor):
        actorts_destabilized.erase(actor)
    # refrfesh stability bar. TODO use signal?
    level_logic.update_stability_bar(actor, node_stability_dict[actor]/node_max_stability_dict[actor])

## Resets given combat actor to max hp and stability and removes effects
func reset_actor(actor: BasePhysicsActor) -> void:
    #
    node_hp_dict[actor] = node_max_hp_dict[actor]
    # TODO signal hp bar change?
    level_logic.update_hp_bar(actor, 1.0)
    remove_destabilize_effect(actor)
