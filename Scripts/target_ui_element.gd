extends Control

@onready var target_indicator: Sprite2D = $TargetIndicator
@onready var selected_indicator: Sprite2D = $SelectedIndicator

func hide_selected_indicator() -> void:
    selected_indicator.hide()


func hide_target_indicator() -> void:
    target_indicator.hide()
    
    
func show_selected_indicator() -> void:
    selected_indicator.show()
    

func show_target_indicator() -> void:
    target_indicator.show()
