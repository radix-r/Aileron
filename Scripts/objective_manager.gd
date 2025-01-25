class_name ObjectiveManager extends Node3D

@export_group("Objective Settings")
@export var objective_name: String
@export var objective_description: String
@export var reached_goal_test: String


enum ObjectiveStatus{
    queued,
    active,
    complete,
    failed,
}
