extends Control

@onready var hp_bar: Sprite2D = $HpBar/Fill
@onready var target_indicator: Sprite2D = $TargetIndicator
@onready var selected_indicator: Sprite2D = $SelectedIndicator
@onready var stability_bar: Sprite2D = $StabilityBar/Fill

# TODO bar reduce effects. under bar that slowly moves to current fill when fill changed

# TODO only show hp, stability when selected?
func hide_hp_and_stability() -> void:
    $HpBar.hide()
    $StabilityBar.hide()

func hide_selected_indicator() -> void:
    selected_indicator.hide()


func hide_target_indicator() -> void:
    target_indicator.hide()
    
    
func set_hp_bar(fraction_full: float) -> void:
    hp_bar.scale.x = fraction_full
    
    
func set_stability_bar(fraction_full: float) -> void:
    stability_bar.scale.x = fraction_full
    

func show_hp_and_stability() -> void:
    $HpBar.show()
    $StabilityBar.show()

func show_selected_indicator() -> void:
    selected_indicator.show()
    

func show_hp_and_stablity() -> void:
    hp_bar.show()
    stability_bar.show()

func show_target_indicator() -> void:
    target_indicator.show()
