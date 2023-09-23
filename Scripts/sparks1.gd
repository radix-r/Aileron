extends GPUParticles3D

@onready var timer: Timer = Timer.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    add_child(timer)
    timer.one_shot = true
    timer.wait_time = lifetime
    timer.connect("timeout", queue_free)
    timer.start()



