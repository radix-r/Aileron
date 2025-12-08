extends Area3D


func _on_body_entered(body: Node3D) -> void:
    # Emmit signal if physic body has entered force field
    #print_debug(body.name)
    if body is RigidBody3D:
        SignalManager.arena_force_field_entered.emit(body)
    


func _on_body_exited(body: Node3D) -> void:
    # Emmit signal if physic body has exited force field.
    # Does this include when object is deleted?
    if body is RigidBody3D:
        SignalManager.arena_force_field_exited.emit(body)
