@abstract class_name Command extends Node

#var actor_: Node3D
# TODO maybe have actor type be base physics mover?
@abstract func execute(actor: Node3D)
