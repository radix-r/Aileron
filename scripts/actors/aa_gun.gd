extends BasePhysicsActorNav



func _ready():
    flight_mode = FlightModes.OFF
    unit_name = "AaGun"
    _default_init()
    #_init_nav()

func _physics_process(_delta):
    # look at targets velocity vector 
    forward = _calc_forward()
    up_relative = _calc_up_relative()
    #weapon.fire(self)
