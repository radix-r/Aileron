extends BasePhysicsActor
class_name BasePhysicsActorNav

var movement_target_position: Vector3 = Vector3(0,100,0)
var target_node: Node3D = null

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

@onready var target_refresh_timer: Timer = Timer.new()

func _ready():
    _default_init()
    _init_nav()


func _init_nav():
    # These values need to be adjusted for the actor's speed
    # and the navigation layout.
    navigation_agent.path_desired_distance = 5
    navigation_agent.target_desired_distance = 5
    
    # Navigation map
    var default_navigation_map_rid: RID = get_world_3d().get_navigation_map()
    NavigationServer3D.map_set_active(default_navigation_map_rid, true)
    # Make sure to not await during _ready.
    actor_setup.call_deferred()


func _physics_process(_delta):
    if navigation_agent.is_navigation_finished():
        return
    var current_agent_position: Vector3 = global_position
    var next_path_position: Vector3 = navigation_agent.get_next_path_position()
    var path_direction = to_local(next_path_position).normalized()
    set_input_direction(path_direction)#to_local(current_agent_position.direction_to(next_path_position)).normalized())
    #if navigation_agent.avoidance_enabled:
    #    navigation_agent.set_velocity_forced()
    _apply_flight_effects(_delta)
    if navigation_agent.avoidance_enabled:
        navigation_agent.velocity = linear_velocity # .set_velocity_forced(linear_velocity)
    else:
        _on_navigation_agent_velocity_computed(linear_velocity)
    
func actor_setup():
    # Wait for the first physics frame so the NavigationServer can sync.
    await get_tree().physics_frame

    # Now that the navigation map is no longer empty, set the movement target.
    set_movement_target_position(target_node)
    # refresh nav target. only accounts for static baked obsicles. Rebake?
    target_refresh_timer.one_shot = false
    target_refresh_timer.wait_time = 1
    target_refresh_timer.timeout.connect(set_movement_target_position.bind(target_node))
    add_child(target_refresh_timer)
    target_refresh_timer.start()
    
    
func set_movement_target_position(_target_node: Node3D):
    if _target_node:
        navigation_agent.set_target_position(_target_node.global_position)
    else:
        navigation_agent.set_target_position(Vector3.ZERO)
        
        
func set_target_node(_target_node: Node3D):
    target_node = _target_node

# TODO safe velocity always 0
func _on_navigation_agent_velocity_computed(safe_velocity: Vector3) -> void:
    linear_velocity = safe_velocity
    pass
