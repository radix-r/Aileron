# Event bus for distant nodes to communicate using signals.
# This is intended for cases where connecting the nodes directly creates more coupling
# or increases code complexity substantially.
extends Node

# Emmited when a physics object enters an arena forcefield
@warning_ignore_start("unused_signal")
signal arena_force_field_entered(object: RigidBody3D)
signal arena_force_field_exited(object: RigidBody3D)

signal boost_input(boosting: bool)
signal directional_input_received(direction: Vector3)
# On triger or fire input
signal fire_input()
signal hit_by_projectile(hit_node: Node3D, projectile: Projectile)
# x, y. Quaternion?
signal rotation_input_received(x_y_rotation: Vector2)
signal target_select_input()
signal ui_cancel_input()
