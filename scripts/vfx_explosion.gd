extends Node3D


func _ready() -> void:
    $AnimationPlayer.play("init")
    var life_timer: Timer = Timer.new()
    life_timer.timeout.connect(_on_life_timer_timeout)
    add_child(life_timer)
    # Magic number. make data driven?
    life_timer.start(3)
    
func _on_life_timer_timeout():
    queue_free()
