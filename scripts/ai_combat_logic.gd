extends Node3D
class_name AiCombatLogic


@export var level_logic: CombatLevelLogic 

var ai_actors: Array = []

# TODO shot cooldown logic
# TODO accuracy logic

func _ready() -> void:
    SignalManager.reached_0_hp.connect(_on_target_reached_0_hp)
    pass

func _on_target_reached_0_hp(actor: BasePhysicsActor):
    # any actors targeting this target select a new random target
    # also killed actor select new random target
    select_random_target(actor)
    pass

func _physics_process(_delta: float) -> void:
    for actor: BasePhysicsActor in ai_actors:
        # Process movement commands
        var move_command: MoveCommand = get_move_command(
                actor,
                # there has to be a better way to do this
                level_logic.targeting_logic.get_selected_target(actor)
        )
        move_command.execute(actor)
        # aim
        # shoot
        
        pass


func get_move_command(
        ai_node: BasePhysicsActor,
        target: Node3D) -> MoveCommand:
    var distance_vector: Vector3 = ai_node.to_local(target.position)
    var direction: Vector3 = distance_vector.normalized()
    # TODO magic number. make data driven
    if distance_vector.length() < 5:
        direction = Vector3.ZERO 
    return MoveCommand.new(direction)

func init_ai_actor(actor: BasePhysicsActor):
    ai_actors.append(actor)
    # Select random target
    select_random_target(actor)
    
    # start combat behavior
        # move tward target
        # look at target
        # shift look based on accuracy
        # fire
        # until target hp <= 0
    pass

# Tels the actor to select a random target
func select_random_target(actor: BasePhysicsActor):
    var rand_target = level_logic.targeting_logic.get_random_target(actor)
    level_logic.targeting_logic.set_selected_target(actor, rand_target)
