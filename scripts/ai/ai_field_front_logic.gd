class_name AiFieldFrontLogic extends Node3D
# TODO mannage units on each team
# TODO Objective. Move twards objective and shoot nearest enemy
# TODO range on un units?
# TODO Objectives by team?
# TODO accuracy? Data driven?
# TODO This file for individual unit control. Another file for broader unit commanding?
## Level logic node to pass information up to
@export var level_logic: BaseLevelLogic = null

var objective_location: Vector3

var units: Array

## Timer to refresh unit objective and target assignements 
@onready var unit_update_timer: Timer
## units that are ready to fire a burst
@onready var units_ready_to_fire: Array = []

## How long unit shoots for
var burst_duration_timer: Timer = Timer.new()
## How long unit holds fire for
var burst_cooldown_timer: Timer = Timer.new()

func _ready() -> void:
    # TODO set objective and unit list
    
    # TODO make unit specific?
    burst_cooldown_timer.wait_time = Utilities.data_dict["Arena0"]["burst_cooldown"]
    burst_duration_timer.wait_time = Utilities.data_dict["Arena0"]["burst_duration"]
    # config burst timers
    burst_cooldown_timer.one_shot = true
    burst_duration_timer.one_shot = true
    pass

func _physics_process(delta: float) -> void:
    for unit: BasePhysicsActor in units:
        var target: Node3D = level_logic.get_selected_target(unit)
        if target and !unit.player_controled:
            unit.look_at(target.global_position)
            
            #var opponent_move_command: MoveCommand = \
                        #ai_logic.get_input_direction_command(
                                #opponent_node, 
                                #ball_node.global_position, 
                                #goal1.global_position, 
                                #goal2.global_position)
            #opponent_move_command.execute(opponent_node)
            
            var unit_aim_location: Vector3 = \
                    Utilities.calculate_aim_location_3d(
                            target.global_position, 
                            target.linear_velocity, 
                            unit.global_position, 
                            unit.linear_velocity, 
                            unit.weapon.projectile_speed)
            unit.look_at(unit_aim_location)
            
            var fire_command: FireCommand = FireCommand.new()
            if unit in units_ready_to_fire:
                fire_command.execute(unit)


func _on_burst_duration_timeout(unit: BasePhysicsActor) -> void:
    if unit in units_ready_to_fire:
        units_ready_to_fire.erase(unit)
    # start burst cooldoen timer
    var new_timer: Timer= burst_cooldown_timer.duplicate()
    new_timer.timeout.connect(_on_burst_cooldown_timeout.bind(unit))
    add_child(new_timer)
    new_timer.start(burst_cooldown_timer.wait_time + randf() *2) # random variation


func _on_burst_cooldown_timeout(unit: BasePhysicsActor) -> void:
    if !(unit in units_ready_to_fire):
        units_ready_to_fire.append(unit)
    # Start burst duration timer
    var new_timer: Timer = burst_duration_timer.duplicate()
    new_timer.timeout.connect(_on_burst_duration_timeout.bind(unit))
    add_child(new_timer)
    new_timer.start(burst_duration_timer.wait_time + randf() *2)


func add_unit(unit: Node3D):
    units.append(unit)
    update_unit_target(unit)
    units_ready_to_fire.append(unit)
    _on_burst_cooldown_timeout(unit)

func get_closest_objective(unit: BasePhysicsActor) -> Node3D:
    # TODO
    return Node3D.new()


## Updates the unit that given unit will shoot at. Returns new target unit or 
## None if no potential targets
func update_unit_target(unit: BasePhysicsActor) -> BasePhysicsActor:
    var closest_enemy: BasePhysicsActor = level_logic.get_closest_targetable(unit)
    level_logic.set_selected_target(unit, closest_enemy)
    return closest_enemy


## Remove unit from play due to death or leaving the level. 
func remove_unit(node: Node3D):
    units.erase(node)
