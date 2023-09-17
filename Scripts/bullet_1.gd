extends CharacterBody3D


#####################################
# SIGNALS
#####################################

#####################################
# CONSTANTS
#####################################

#####################################
# EXPORT VARIABLES
#####################################

#####################################
# PUBLIC VARIABLES
#####################################
@onready var speed: float = 0
@onready var lifespan: Timer = Timer.new()
@onready var initial_velocity: Vector3 = Vector3.ZERO
#####################################
# PRIVATE VARIABLES
#####################################

#####################################
# ONREADY VARIABLES
#####################################

#####################################
# OVERRIDE FUNCTIONS
#####################################
func _init(_initial_velocity: Vector3 = Vector3.ZERO) -> void:
    initial_velocity = _initial_velocity

func _physics_process(_delta: float) -> void:
    # move forward
    var collision =  move_and_collide(velocity)

    if collision && collision is KinematicCollision3D && collision.get_collider() is Node:
        var player_found: bool = false
        for group in collision.get_collider().get_groups():
            player_found = player_found || group == "player"

        if !player_found:
            queue_free()

func _ready() -> void:
    var unit_name = "Bullet1"
    #speed = Utilities.data_dict[unit_name]["speed"]
    lifespan.wait_time = Utilities.data_dict[unit_name]["lifespan"]
    lifespan.one_shot = true
    lifespan.connect("timeout", _on_lifespan_timeout)
    add_child(lifespan)
    lifespan.start()
    #velocity = to_global(Vector3.FORWARD * speed)


#####################################
# API FUNCTIONS
#####################################

#####################################
# HELPER FUNCTIONS
#####################################
func _on_lifespan_timeout() -> void:
    queue_free()
