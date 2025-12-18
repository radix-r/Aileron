## Script to control AI arena opponent 
class_name AiLogic extends Node3D

enum BehaviorMode{
    OFFENSE,
    DEFENCE,
}

#@onready var behavior_mode: BehaviorMode = BehaviorMode.DEFENCE 


#func _physics_process(delta: float) -> void:
    
func _calculate_defensive_target_location(ball_location: Vector3, own_goal_location: Vector3) -> Vector3:
    var ball_to_goal_vector: Vector3 = (ball_location - own_goal_location)
    return ball_location - (ball_to_goal_vector/2)
    
    
func _calculate_offensive_target_location(ball_location: Vector3, enemy_goal_location: Vector3) -> Vector3:
    # return location opposite ball and enemy goal
    var goal_to_ball_direction: Vector3 = (enemy_goal_location - ball_location).normalized()
    var target_distance_from_ball: float = 20
    return ball_location - (goal_to_ball_direction * target_distance_from_ball)


func _calculate_target_location(ball_location: Vector3, enemy_goal_location: Vector3, own_goal_location: Vector3, behavior: BehaviorMode) -> Vector3:
    var target_location: Vector3 = Vector3.ZERO
    if BehaviorMode.OFFENSE == behavior:
        target_location = _calculate_offensive_target_location(ball_location, enemy_goal_location)
    elif BehaviorMode.DEFENCE == behavior:
        target_location = _calculate_defensive_target_location(ball_location, own_goal_location)
    return target_location

func _determine_behavior_mode(
        ball_location: Vector3, 
        enemy_goal_location: Vector3, 
        own_goal_location: Vector3) -> BehaviorMode:
    var ball_to_own_goal_dist: float = (ball_location - own_goal_location).length()
    var ball_to_enemy_goal_dist: float = (ball_location - enemy_goal_location).length()
    
    var behavior: BehaviorMode = BehaviorMode.DEFENCE
    
    if ball_to_own_goal_dist > ball_to_enemy_goal_dist:
        behavior = BehaviorMode.OFFENSE
        
    return behavior

#func move_tward_location(taget_location: Vector3) -> void:
    
## Determine what direction the AI player should be inputing
func get_input_direction_command(ai_node: BasePhysicsActor, 
        ball_location: Vector3, 
        enemy_goal_location: Vector3,
        own_goal_location: Vector3) -> MoveCommand:
    var behavior: BehaviorMode = _determine_behavior_mode(ball_location, enemy_goal_location, own_goal_location)
    var target_location: Vector3 = _calculate_target_location(ball_location, enemy_goal_location, own_goal_location, behavior)
    #var move_direction: Vector3 = ai_node.global_position.direction_to(target_location)
    var move_direction: Vector3 = ai_node.to_local(target_location).normalized()
    #var move_direction_local = move_direction * ai_node.global_basis#.inverse()
    
    #move_direction = ai_node.to_local(move_direction).normalized()
    return MoveCommand.new(move_direction)
