class_name MoveCommand extends Command

# actor var inherited from Command class
var move_direction_: Vector3

func _init(move_direction: Vector3) -> void:
    move_direction_ = move_direction
    
    
func execute(actor: Node3D):
    actor.set_input_direction(move_direction_)
