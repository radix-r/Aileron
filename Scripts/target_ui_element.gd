extends Control

@onready var hp_bar: Sprite2D = $HpBar/Fill
@onready var target_indicator: Sprite2D = $TargetIndicator
@onready var selected_indicator: Sprite2D = $SelectedIndicator
@onready var stability_bar: Sprite2D = $StabilityBar/Fill

# TODO only show hp, stability when selected?
func hide_selected_indicator() -> void:
    selected_indicator.hide()


func hide_target_indicator() -> void:
    target_indicator.hide()
    
    
func set_hp(fraction_full: float) -> void:
    hp_bar.scale.x = fraction_full
    
    
func set_stability(fraction_full: float) -> void:
    stability_bar.scale.x = fraction_full
    
func show_selected_indicator() -> void:
    selected_indicator.show()
    

func show_target_indicator() -> void:
    target_indicator.show()
