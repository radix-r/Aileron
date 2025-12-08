extends CharacterBody3D


func _on_hurt_box_body_entered(body: Node3D) -> void:
    #if body.get_groups(): 
    print_debug("Hit")
