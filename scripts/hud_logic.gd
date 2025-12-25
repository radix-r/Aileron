class_name HudLogic extends Node3D

@export var hud_anchor: HudAnchor = null

func _process(_delta: float) -> void:
    pass

func update_boresight(ship: PlayerPhysicsShip) -> void:
    var hud_pos: Vector2 = Utilities.transform_to_hud_space(ship.global_position + ship.forward * 1000, ship.get_camera() )

    if !ship.get_camera().is_position_behind(ship.get_camera().global_position + ship.forward):
        hud_anchor.show_boresight()
        hud_anchor.set_boresight_position(hud_pos)

    else:
        hud_anchor.hide_boresight()


func update_velocity_marker(ship: PlayerPhysicsShip) -> void:
    if ship.linear_velocity.length() > 0.01:
        var hud_pos: Vector2 = Utilities.transform_to_hud_space(ship.get_camera().global_position + ship.linear_velocity, ship.get_camera())

        if ship.get_camera().is_position_behind(ship.get_camera().global_position + ship.linear_velocity):
            hud_anchor.hide_velocity_marker() #velocity_marker.hide()
        else:
            hud_anchor.show_velocity_marker()
            hud_anchor.set_velocity_marker_pos(hud_pos)
    else:
        hud_anchor.hide_velocity_marker()
