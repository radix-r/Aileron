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


## Draw target indicators for given targets on given camera
func draw_target_ui_for_cam(subject_actor: BasePhysicsActor, camera: Camera3D, targets: Array, selected_target: Node3D) -> void:
    # draw targets
    # TODO: dont access hud anchor. instead go through hud logic?
    hud_anchor.update_target_indicators(camera, targets)
    # draw selected target
    hud_anchor.update_selected_target_indicator(camera, selected_target)
    var selected_target_velocity = Vector3.ZERO
    if selected_target is RigidBody3D:
        selected_target_velocity = selected_target.linear_velocity
    
    if selected_target:
        var aim_point_hud_pos: Vector2 = Utilities.calculate_aim_indicator_location(camera,selected_target.global_position, selected_target_velocity ,subject_actor.global_position, subject_actor.linear_velocity, subject_actor.weapon.projectile_speed)
        hud_anchor.update_aim_indicator(camera, aim_point_hud_pos, selected_target.position)



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


func update_score_ui(new_text: String):
    hud_anchor.set_objective_description(new_text)
