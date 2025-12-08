class_name RotationCommand extends Command

# TODO use quaternion
var rotation_input_: Vector2 = Vector2.ZERO

func _init(rotation_input: Vector2) -> void:
    rotation_input_ = rotation_input
    
    
func execute(actor: Node3D):
    actor.rotate_with_input(rotation_input_)
