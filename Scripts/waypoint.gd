extends Node3D

class_name Waypoint

@onready var camera: Camera3D = get_viewport().get_camera_3d()
@onready var collision_shape_node: CollisionShape3D = $Area3D/CollisionShape3D
@onready var mesh_node: MeshInstance3D = $Area3D/MeshInstance3D

@onready var shape: SphereShape3D = collision_shape_node.shape
@onready var mesh: SphereMesh = mesh_node.mesh

# Constructor
# Create new shpherical waypoint. Detects arrival at given within given radius.
func _init(_radius: float = 0.0, _position: Vector3 = Vector3(0, 0, 0)) -> void:
    shape = SphereShape3D.new()
    shape.radius = _radius

    mesh = SphereMesh.new()
    mesh.radius = _radius
    mesh.height = _radius * 2
    pass
    #self.position = _position


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    collision_shape_node.shape = shape
    mesh_node.mesh = mesh


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#    var marker_pos = camera.unproject_position(self.global_transform.origin)
#    $Origin.position = marker_pos
#
#    if $VisibleNotifier.is_on_screen():
#        $Origin.show()
#    else:
#        $Origin.hide()
#
#func initialize() -> void:
#    pass


#func set_position(new_position: Vector3) -> void:
#    self.position = new_position

func set_radius(new_radius: float) -> void:
    shape = SphereShape3D.new()
    shape.radius = new_radius
    collision_shape_node.shape = shape

    mesh = SphereMesh.new()
    mesh.radius = new_radius
    mesh.height = new_radius * 2
    mesh_node.mesh = mesh
