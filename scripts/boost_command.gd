class_name BoostCommand extends Command

var boosting_: bool = false

func _init(boosting: bool) -> void:
    boosting_ = boosting

func execute(actor: Node3D):
    actor.set_boosting(boosting_)
