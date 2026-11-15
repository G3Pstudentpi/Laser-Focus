extends Node2D # Change to CharacterBody2D if you keep that node type

@export var max_bounces: int = 10
@export var max_distance: float = 2000.0
@export var rotation_speed: float = 1.5

@onready var beam: Line2D = $Line2D

var active_receiver: Node = null

func _physics_process(delta: float) -> void:
	# Rotate the character/laser gun with Left/Right or A/D
	var turn_input := Input.get_axis("ui_left", "ui_right")
	rotation += turn_input * rotation_speed * delta
	
	cast_laser()

func cast_laser() -> void:
	beam.clear_points()
	beam.add_point(Vector2.ZERO)
	
	var space_state := get_world_2d().direct_space_state
	var current_origin := global_position
	var current_direction := Vector2.RIGHT.rotated(global_rotation)
	var hit_receiver: Node = null
	
	for i in range(max_bounces):
		var target_end := current_origin + current_direction * max_distance
		var query := PhysicsRayQueryParameters2D.create(current_origin, target_end)
		query.collision_mask = 7 # Layers 1 (Walls), 2 (Mirrors), 3 (Receivers)
		
		var result := space_state.intersect_ray(query)
		
		if result:
			var hit_pos: Vector2 = result.position
			var collider: Object = result.collider
			beam.add_point(to_local(hit_pos))
			
			if collider is CollisionObject2D and collider.get_collision_layer_value(2):
				current_direction = current_direction.bounce(result.normal)
				current_origin = hit_pos + result.normal * 0.5
			elif collider is CollisionObject2D and collider.get_collision_layer_value(3):
				hit_receiver = collider
				break
			else:
				break
		else:
			beam.add_point(to_local(target_end))
			break
			
	update_receiver_state(hit_receiver)

func update_receiver_state(new_receiver: Node) -> void:
	if active_receiver != new_receiver:
		if active_receiver and active_receiver.has_method("set_powered"):
			active_receiver.set_powered(false)
		active_receiver = new_receiver
		if active_receiver and active_receiver.has_method("set_powered"):
			active_receiver.set_powered(true)
