class_name HudAnchor extends Control

var target_ui_element: PackedScene = preload("res://scenes/hud/target_ui_element.tscn")
var aim_ui_elemet: PackedScene = preload("res://scenes/hud/aim_indicator.tscn")
#@export var player_ship: PhysicsBody3D 

#@onready var nav_arrow_point: Node3D = player_ship
@onready var boresight: Control = $PlayerVectorOverlay/Boresight
@onready var hud_anchor: Control = self
@onready var nav_arrow_drawer: Control = $NavArrowOverlay/Draw3d
@export var objective_description: RichTextLabel 
@onready var objective_title: RichTextLabel = $ObjectiveBox/ObjectveTitle
@onready var overlay: CanvasLayer = $NavArrowOverlay
@onready var velocity_marker: Control = $PlayerVectorOverlay/VelocityMarker
@onready var stopwatch_label: Label = $StopwatchLabel
@onready var center_screen_label: Label = $CenterScreenLabel
@onready var hit_marker: Control = $HitMarkerOverlay/HitMarker
# Key: node reff, Value: target ui element assigned to that node
var target_ui_element_dict: Dictionary = {}
var aim_indicator: Control = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    aim_indicator = aim_ui_elemet.instantiate()
    aim_indicator.hide()
    add_child(aim_indicator)
    # Set hit marker to be transparent
    hit_marker.modulate = Color(1,1,1,0)
    objective_title.text = "Score"


func _physics_process(delta: float) -> void:
    # decay hit marker opacity
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    if 0 < hit_marker.modulate.a:
        hit_marker.modulate.a -= _delta


func add_target_indicator(target: Node3D) -> void:
    var new_target_ui_element = target_ui_element.instantiate()
    add_child(new_target_ui_element)
    target_ui_element_dict[target] = new_target_ui_element
    target_ui_element_dict[target].hide()
    target_ui_element_dict[target].hide_hp_and_stability()

func hide_boresight() -> void:
    boresight.hide()


func hide_center_screen_label() -> void:
    center_screen_label.hide()


func hide_velocity_marker() -> void:
    velocity_marker.hide()


func remove_target_indicator(node: Node3D) -> void:
    if target_ui_element_dict.has(node):
        target_ui_element_dict.erase(node)

func set_center_screen_label(text: String) -> void:
    center_screen_label.text = text

func set_boresight_position(hud_pos: Vector2) -> void:
    boresight.set_position(hud_pos)


func set_objective_description(description: String) -> void:
    objective_description.text = description

func set_timer(time_str: String) -> void:
    stopwatch_label.text = time_str

func set_velocity_marker_pos(hud_pos: Vector2) -> void:
    velocity_marker.set_position(hud_pos)


func show_boresight() -> void:
    boresight.show()

func show_center_screen_label() -> void:
    center_screen_label.show()

func show_velocity_marker() -> void:
    velocity_marker.show()


func update_aim_indicator(camera: Camera3D, aim_point_hud_pos: Vector2, selected_target_global_position: Vector3):
    # if target is in front of camera update aim indicator pos
    if !camera.is_position_behind(selected_target_global_position):
        aim_indicator.set_position(aim_point_hud_pos)
        aim_indicator.show()
    else:
        aim_indicator.hide()


func update_hp_bar(fraction_full: float, target: Node3D) -> void:
    if target:
        target_ui_element_dict[target].set_hp_bar(fraction_full)
        target_ui_element_dict[target].show_hp_and_stability()

func update_nav_arrow() -> void:
    if nav_arrow_drawer:
        nav_arrow_drawer.queue_redraw()


func update_selected_target_indicator(_camera: Camera3D, target: Node3D) -> void:
    if target:
        target_ui_element_dict[target].show_selected_indicator()


func update_stability_bar(fraction_full: float, target: Node3D) -> void:
    if target:
        target_ui_element_dict[target].set_stability_bar(fraction_full)
        target_ui_element_dict[target].show_hp_and_stability()


func update_target_indicators(camera: Camera3D, target_list: Array) -> void:
    for target in target_list:
        if !camera.is_position_behind(target.global_position):
            var hud_pos: Vector2 = Utilities.transform_to_hud_space(target.global_position,camera)
            target_ui_element_dict[target].position = hud_pos
            target_ui_element_dict[target].hide_selected_indicator()
            target_ui_element_dict[target].show()
        else:
            target_ui_element_dict[target].hide()
            
            
# in what way is this tranforming the angle?
func transform_angle(angel: float, fov: float, pixel_height: float) -> float:
    return (tan(angel) / tan(fov / 2)) * pixel_height / 2

#TODO
func trigger_hit_marker() -> void:
    # set opacity
    hit_marker.modulate.a = 1
    hit_marker.set_position(boresight.position)
