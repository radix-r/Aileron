extends Button
class_name LevelSelectButton

signal level_selected(level)

func _on_pressed() -> void:
    emit_signal("level_selected", text)
    print_debug("Emitted level_selected: ", text)
