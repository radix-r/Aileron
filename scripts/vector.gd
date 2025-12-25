class_name Vector extends Control

var object  # The node to follow
var property  # The property to draw
var scale_factor  # Scale factor
var width  # Line width
var color  # Draw color

var vectors = []  # Array to hold all registered values.

func _init(_object, _property, _scale, _width, _color):
    object = _object
    property = _property
    scale_factor = _scale
    width = _width
    color = _color

func draw(node, camera):
    var start = camera.unproject_position(object.global_transform.origin)
    var end = camera.unproject_position(object.global_transform.origin + object.get(property) * scale)
    node.draw_line(start, end, color, width)
    node.draw_triangle(end, start.direction_to(end), width*2, color)
