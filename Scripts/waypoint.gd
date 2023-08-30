extends Node3D

@onready var camera = get_viewport().get_camera_3d()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    var marker_pos = camera.unproject_position(self.global_transform.origin)
    $Origin.position = marker_pos

    if $VisibleNotifier.is_on_screen():
        $Origin.show()
    else:
        $Origin.hide()
