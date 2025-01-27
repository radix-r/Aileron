extends Control

@onready var hud_root: Control = $"../.."
@onready var nav_arrow_point: Node3D= hud_root.player_ship
@onready var nav_arrow_overlay: CanvasLayer = $".."
@onready var level_root: Node3D = Utilities.get_level_root()
#@onready var waypoint_system: Node3D
@onready var level_logic: Node3D = get_node("/root/LevelRoot/Services/LevelLogic")
@onready var camera: Camera3D = hud_root.player_ship.camera

const WIDTH: float = 10.0


func _draw() -> void:

    if !(level_logic and level_logic.current_target):
        nav_arrow_overlay.hide()
        return

    nav_arrow_overlay.show()
    #var active_waypoint: Waypoint = waypoint_system.active_waypoint
    #var vector_to_navpoint: Vector3 = nav_arrow_point.global_transform.origin - level_logic.current_target.global_transform.origin
    #vector_to_navpoint = vector_to_navpoint.normalized() * 10

    var color: Color = Color(0, 1, 0)
    var start: Vector2 = camera.unproject_position(nav_arrow_point.global_transform.origin) - position
    var end: Vector2 = camera.unproject_position(level_logic.current_target.global_transform.origin) - position
    if camera.is_position_behind(level_logic.current_target.global_transform.origin):
        end.y = -end.y
    #end = end.normalized() * 10
    var distance: float =  start.distance_to(end)
    draw_line(start, end, color, WIDTH)
    draw_triangle(end, start.direction_to(end), WIDTH*2, distance / 3.0 , color)


func _ready() -> void:
    if !level_logic:
        print_debug("Failed to init waypoint arrow GUI")
    #if level_logic and "waypoint_system" in level_root:
        #waypoint_system = level_root.waypoint_system
    #else:
        #print_debug("Failed to init waypoint arrow GUI")


func draw_triangle(pos: Vector2, dir: Vector2, width: float, length: float, color: Color):
    var a = pos + dir * length
    var b = pos + dir.rotated(2*PI/3) * width
    var c = pos + dir.rotated(4*PI/3) * width
    var points = PackedVector2Array([a, b, c])
    draw_polygon(points, PackedColorArray([color]))
