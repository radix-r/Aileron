# Event bus for distant nodes to communicate using signals.
# This is intended for cases where connecting the nodes directly creates more coupling
# or increases code complexity substantially.
extends Node

# Emmited when a physics object enters an arena forcefield
signal arena_force_field_entered(object: RigidBody3D)
signal arena_force_field_exited(object: RigidBody3D)

signal directional_input_received(direction: Vector3)
# x, y. Quaternion?
signal rotation_input_received(x_y_rotation: Vector2)
