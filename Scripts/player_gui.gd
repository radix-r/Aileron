extends Control

var target_ui_element: PackedScene = preload("res://Scenes/GUI/target_ui_element.tscn")

@export var player_ship: PhysicsBody3D 

@onready var nav_arrow_point: Node3D = player_ship
@onready var overlay: CanvasLayer = $NavArrowOverlay
@onready var nav_arrow_drawer: Control = $NavArrowOverlay/Draw3d
@onready var hud_center: Control = $PlayerVectorOverlay/HudCenter
@onready var hud_anchor: Control = self
@onready var velocity_marker: Control = $PlayerVectorOverlay/VelocityMarker

# Dictionary full of nodes in group target
@onready var target_list: Array = []
@onready var target_ui_element_map: Dictionary = {}
@onready var current_target: Node3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    target_list = get_tree().get_nodes_in_group("target")
    init_targeting_ui()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    if player_ship.camera:
        update_nav_arrow()
        update_hud_center()
        update_velocity_marker()
        update_target_indicator()

func init_targeting_ui() -> void:
    for target in target_list:
        var new_target_ui_element = target_ui_element.instantiate()
        add_child(new_target_ui_element)
        target_ui_element_map[target.name] = new_target_ui_element

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
    if player_ship.linear_velocity.length() > 0.01:
        var hud_pos: Vector2 = transform_to_hud_space(player_ship.camera.global_position + player_ship.linear_velocity)

        if player_ship.camera.is_position_behind(player_ship.camera.global_position + player_ship.linear_velocity):
            velocity_marker.hide()
        else:
            velocity_marker.show()
            velocity_marker.position = hud_pos
    else:
        velocity_marker.hide()


func update_target_indicator() -> void:
    for target in target_list:
        if !player_ship.camera.is_position_behind(target.global_position):
            var hud_pos: Vector2 = transform_to_hud_space(target.global_position)
            target_ui_element_map[target.name].position = hud_pos


func transform_angle(angel: float, fov: float, pixel_height: float) -> float:
    return (tan(angel) / tan(fov / 2)) * pixel_height / 2


func transform_to_hud_space(world_space: Vector3) -> Vector2:
    var screen_space: Vector2 = player_ship.camera.unproject_position(world_space)
    return screen_space #- Vector2(get_viewport().get_visible_rect().size / 2)
