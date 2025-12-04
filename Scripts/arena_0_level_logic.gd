extends Node3D

@onready var objects_in_force_field: Dictionary = {}
@onready var foce_field_force_newtons: float = 1000


func _ready() -> void:
    pass
    SignalManager.arena_force_field_entered.connect(add_object_in_force_field)
    SignalManager.arena_force_field_exited.connect(remove_object_in_force_field)
    
    
func _physics_process(delta: float) -> void:
    pass
    apply_force_field_effects(delta)


func add_object_in_force_field(obj: RigidBody3D) -> void:
    objects_in_force_field[obj.name] = obj
    #print_debug(obj.name + " entered")


func apply_force_field_effects(_delta: float) -> void:
    for obj_name in objects_in_force_field:
        objects_in_force_field[obj_name].apply_central_force(Vector3.UP * foce_field_force_newtons)
    
    
func remove_object_in_force_field(obj: RigidBody3D) -> void:
    objects_in_force_field.erase(obj.name)
