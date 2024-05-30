extends Control

@export var button_level_dict: Dictionary

var level_select_button: PackedScene = preload("res://Scenes/level_select_button.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    for key in button_level_dict:
        # create a button and put it in the vBox container
        var new_button = level_select_button.instantiate()
        new_button.text = key
        $VBoxContainer.add_child(new_button)
        new_button.connect("level_selected", _on_level_selected)
        # TODO: Verify level path is vaild



func _on_level_selected(level: String):
    SceneLoader.load_scene(button_level_dict[level])
