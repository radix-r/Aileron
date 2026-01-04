extends Node3D
class_name AiCombatLogic


@export var level_logic: CombatLevelLogic 

func _ready() -> void:
    pass

func _physics_process(delta: float) -> void:
    pass


func get_input_direction_command(
        ai_node: BasePhysicsActor,
        target: Node3D):
    pass 

func init_ai_actor(actor: BasePhysicsActor):
    # Select random target
    level_logic.targeting_logic.get_random_target(actor)
    # start combat behavior
        # move tward target
        # look at target
        # shift look based on accuracy
        # fire
        # until target hp <= 0
    pass
