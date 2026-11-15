extends Node2D

@export var grab_radius: float = 120.0
@export var show_grab_circle: bool = true

var is_dragging: bool = false
var drag_angle_offset: float = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var mouse_pos: Vector2 = get_global_mouse_position()
			
			if global_position.distance_to(mouse_pos) <= grab_radius:
				is_dragging = true
				var mouse_angle: float = (mouse_pos - global_position).angle()
				drag_angle_offset = rotation - mouse_angle
		else:
			is_dragging = false

	elif event is InputEventMouseMotion and is_dragging:
		var mouse_pos: Vector2 = get_global_mouse_position()
		var current_mouse_angle: float = (mouse_pos - global_position).angle()
		rotation = current_mouse_angle + drag_angle_offset

func _draw() -> void:
	if show_grab_circle:
		draw_arc(Vector2.ZERO, grab_radius, 0, TAU, 48, Color(0.3, 0.8, 1.0, 0.4), 2.0)
