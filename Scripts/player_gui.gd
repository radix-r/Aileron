extends Control

@export var player_ship: AirMover

@onready var nav_arrow_point: Node3D = player_ship
@onready var overlay: CanvasLayer = $NavArrowOverlay
@onready var nav_arrow_drawer: Control = $NavArrowOverlay/Draw3d
@onready var hud_center: Control = $PlayerVectorOverlay/HudCenter
@onready var hud_anchor: Control = self
@onready var velocity_marker: Control = $PlayerVectorOverlay/VelocityMarker

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    if player_ship.camera:
        update_nav_arrow()
        update_hud_center()
        update_velocity_marker()


func update_hud_center() -> void:
    # var cam_rotation: Vector3 = camera_control.rotation

    var hud_pos: Vector2 = transform_to_hud_space(player_ship.camera.global_position + player_ship.forward )

    if !player_ship.camera.is_position_behind(player_ship.camera.global_position + player_ship.forward):
        hud_center.show()
        hud_center.position = hud_pos

    else:
        hud_center.hide()


func update_nav_arrow() -> void:
    if nav_arrow_drawer:
        nav_arrow_drawer.queue_redraw()


func update_velocity_marker() -> void:
    var hud_pos: Vector2 = transform_to_hud_space(player_ship.camera.global_position + player_ship.velocity)

    if player_ship.camera.is_position_behind(player_ship.camera.global_position + player_ship.velocity):
        velocity_marker.hide()
    else:
        velocity_marker.show()
        velocity_marker.position = hud_pos


func transform_angle(angel: float, fov: float, pixel_height: float) -> float:
    return (tan(angel) / tan(fov / 2)) * pixel_height / 2


func transform_to_hud_space(world_space: Vector3) -> Vector2:
    var screen_space: Vector2 = player_ship.camera.unproject_position(world_space)
    return screen_space #- Vector2(get_viewport().get_visible_rect().size / 2)
