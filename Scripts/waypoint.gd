extends Node3D

class_name Waypoint

signal waypoint_arrived(body: Node3D, waypoint_id: int)

@onready var camera: Camera3D = get_viewport().get_camera_3d()
@onready var collision_shape_node: CollisionShape3D = $Area3D/CollisionShape3D
@onready var mesh_node: MeshInstance3D = $Area3D/MeshInstance3D

@onready var shape: SphereShape3D = collision_shape_node.shape#.duplicate(true)
@onready var mesh: SphereMesh = mesh_node.mesh#.duplicate(true)
@onready var temp_radius: float = 0.0
@onready var temp_position: Vector3 = Vector3.ZERO

var id: int
static var next_id: int = 0

# Constructor
# Create new shpherical waypoint. Detects arrival at given within given radius.
func _init(_radius: float = 0.0, _position: Vector3 = Vector3.ZERO) -> void:
    #shape = SphereShape3D.new()
    temp_radius = _radius

    self.position = _position


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    set_radius(temp_radius)
    id = next_id
    next_id = next_id + 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    var marker_pos = camera.unproject_position(self.global_transform.origin)
    $Origin.position = marker_pos

    if $VisibleNotifier.is_on_screen():
        $Origin.show()
    else:
        $Origin.hide()


func initialize() -> void:
    pass


func set_disabled(disabled: bool) -> void:
    collision_shape_node.set_deferred("disabled", disabled)
    visible = !disabled

func set_radius(new_radius: float) -> void:
    #shape = SphereShape3D.new()
    shape.radius = new_radius
    collision_shape_node.shape = shape

    #mesh = SphereMesh.new()
    mesh.radius = new_radius
    mesh.height = new_radius * 2
    mesh_node.mesh = mesh


func _on_area_3d_body_entered(body: Node3D) -> void:
    waypoint_arrived.emit(body, id)

