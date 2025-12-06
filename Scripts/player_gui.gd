class_name HudAnchor extends Control

var target_ui_element: PackedScene = preload("res://Scenes/GUI/target_ui_element.tscn")

#@export var player_ship: PhysicsBody3D 

#@onready var nav_arrow_point: Node3D = player_ship
@onready var overlay: CanvasLayer = $NavArrowOverlay
@onready var nav_arrow_drawer: Control = $NavArrowOverlay/Draw3d
@onready var hud_center: Control = $PlayerVectorOverlay/HudCenter
@onready var hud_anchor: Control = self
@onready var velocity_marker: Control = $PlayerVectorOverlay/VelocityMarker

# Dictionary full of nodes in group target
#@onready var target_list: Array = []
var target_ui_element_dict: Dictionary = {}
# @onready var current_target: Node3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    
    # init_targeting_ui()
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    # Moving to level logic
    #if player_ship.camera:
        #update_nav_arrow()
        #update_hud_center(player_ship)
        #update_velocity_marker(player_ship)
        #
        #update_target_indicator(player_ship)
        pass

func add_target_indicator(target: Node3D) -> void:
    var new_target_ui_element = target_ui_element.instantiate()
    add_child(new_target_ui_element)
    target_ui_element_dict[target.name] = new_target_ui_element
    target_ui_element_dict[target.name].hide()
    

#func init_targeting_ui() -> void:
    ## Moving to level logic
#
    #for target in target_list:
        #



func remove_target_indicator(node_name: String) -> void:
    if target_ui_element_dict.has(node_name):
        target_ui_element_dict.erase(node_name)


func update_hud_center(ship: PlayerPhysicsShip) -> void:
    # var cam_rotation: Vector3 = camera_control.rotation

    var hud_pos: Vector2 = transform_to_hud_space(ship.get_camera().global_position + ship.forward, ship.get_camera() )

    if !ship.get_camera().is_position_behind(ship.get_camera().global_position + ship.forward):
        hud_center.show()
        hud_center.position = hud_pos

    else:
        hud_center.hide()


func update_nav_arrow() -> void:
    if nav_arrow_drawer:
        nav_arrow_drawer.queue_redraw()


func update_selected_target_indicator(_camera: Camera3D, target: Node3D) -> void:
    if target:
        target_ui_element_dict[target.name].show_selected_indicator()


func update_velocity_marker(ship: PlayerPhysicsShip) -> void:
    if ship.linear_velocity.length() > 0.01:
        var hud_pos: Vector2 = transform_to_hud_space(ship.get_camera().global_position + ship.linear_velocity, ship.get_camera())

        if ship.get_camera().is_position_behind(ship.get_camera().global_position + ship.linear_velocity):
            velocity_marker.hide()
        else:
            velocity_marker.show()
            velocity_marker.position = hud_pos
    else:
        velocity_marker.hide()



func update_target_indicators(camera: Camera3D, target_list: Array) -> void:
    for target in target_list:
        if !camera.is_position_behind(target.global_position):
            var hud_pos: Vector2 = transform_to_hud_space(target.global_position,camera)
            target_ui_element_dict[target.name].position = hud_pos
            target_ui_element_dict[target.name].hide_selected_indicator()
            target_ui_element_dict[target.name].show()
        else:
            target_ui_element_dict[target.name].hide()
            
            
# in what way is this tranforming the angle?
func transform_angle(angel: float, fov: float, pixel_height: float) -> float:
    return (tan(angel) / tan(fov / 2)) * pixel_height / 2

# TODO mode to utilities?
func transform_to_hud_space(world_space: Vector3, camera: Camera3D) -> Vector2:
    var screen_space: Vector2 = camera.unproject_position(world_space)
    return screen_space #- Vector2(get_viewport().get_visible_rect().size / 2)
