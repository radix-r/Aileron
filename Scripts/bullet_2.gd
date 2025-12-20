class_name Projectile extends RigidBody3D
# TODO maybe inherit from BasePhysicsActor?

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
# TODO make lifespan private and make getters and setters?
@onready var lifespan: Timer = Timer.new()
@onready var shot_by: Node = null
@onready var hp_damage: float = 0
@onready var stability_damage: float = 0

#####################################
# PRIVATE VARIABLES
#####################################

#####################################
# ONREADY VARIABLES
#####################################

#####################################
# OVERRIDE FUNCTIONS
#####################################
func _init() -> void:
    pass

#func _physics_process(_delta: float) -> void:
    ## move forward
    #var collision =  move_and_collide(velocity)
#
    #if collision && collision is KinematicCollision3D && collision.get_collider() is Node:
        #var player_found: bool = false
        #for group in collision.get_collider().get_groups():
            #player_found = player_found || group == "player"
#
        #if !player_found:
            #queue_free()


func _ready() -> void:
    var unit_name = "Bullet2"
    #speed = Utilities.data_dict[unit_name]["speed"]
    lifespan.wait_time = Utilities.data_dict[unit_name]["lifespan"]
    lifespan.one_shot = true
    lifespan.connect("timeout", _on_lifespan_timeout)
    add_child(lifespan)
    lifespan.start()
    
    hp_damage = Utilities.data_dict[unit_name]["hp_damage"]
    stability_damage = Utilities.data_dict[unit_name]["stability_damage"]
    #velocity = to_global(Vector3.FORWARD * speed)


#####################################
# API FUNCTIONS
#####################################

#####################################
# HELPER FUNCTIONS
#####################################
# TODO init variables func?

func _on_lifespan_timeout() -> void:
    queue_free()
