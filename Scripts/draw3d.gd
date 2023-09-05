extends Control

@onready var nav_arrow_point: Node3D= $"../.."
@onready var waypoint_system: Node3D = get_tree().root.get_node("/root/TestScene1/Services/Navigation/WaypointSystem")
@onready var camera: Camera3D= $"../../../PitchPoint/CameraControl/Camera3D"

const WIDTH: float = 10.0


func _draw() -> void:
    #if waypoint_system:
    var active_waypoint: Waypoint = waypoint_system.active_waypoint
    var vector_to_navpoint: Vector3 = active_waypoint.global_transform.origin - nav_arrow_point.global_transform.origin
    vector_to_navpoint = vector_to_navpoint.normalized() * 10

    var color: Color = Color(0, 1, 0)
    var start: Vector2 = camera.unproject_position(nav_arrow_point.global_transform.origin)
    var end: Vector2 = camera.unproject_position(nav_arrow_point.global_transform.origin + vector_to_navpoint)
    draw_line(start, end, color, WIDTH)
    draw_triangle(end, start.direction_to(end), WIDTH*2, color)

func draw_triangle(pos: Vector2, dir: Vector2, _size: float, color: Color):
    var a = pos + dir * size
    var b = pos + dir.rotated(2*PI/3) * _size
    var c = pos + dir.rotated(4*PI/3) * _size
    var points = PackedVector2Array([a, b, c])
    draw_polygon(points, PackedColorArray([color]))

