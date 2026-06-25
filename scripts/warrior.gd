extends Node2D

const MOVE_SPEED := 260.0
const VIEWPORT_SIZE := Vector2(720.0, 1280.0)
const UI_PANEL_TOP := 1040.0
const VISUAL_BOUNDS := Rect2(Vector2(-126.0, -114.0), Vector2(236.0, 237.0))

@onready var sword_arm: Node2D = %SwordArm
@onready var shield_arm: Node2D = %ShieldArm
@onready var shield: Polygon2D = %Shield

var _action_tween: Tween
var _base_scale := Vector2.ONE
var _walk_time := 0.0

func _ready() -> void:
	_base_scale = scale

func _physics_process(delta: float) -> void:
	var move_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	_update_facing(move_direction)
	position = get_next_position(position, move_direction, delta)
	_update_walk_animation(move_direction, delta)

func attack() -> void:
	_restart_action()
	sword_arm.rotation_degrees = -28.0
	_action_tween.tween_property(sword_arm, "rotation_degrees", 68.0, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_action_tween.tween_property(sword_arm, "rotation_degrees", -28.0, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func defend() -> void:
	_restart_action()
	shield_arm.rotation_degrees = 24.0
	shield.scale = Vector2.ONE
	_action_tween.parallel().tween_property(shield_arm, "rotation_degrees", -32.0, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_action_tween.parallel().tween_property(shield, "scale", Vector2(1.14, 1.14), 0.16)
	_action_tween.tween_interval(0.22)
	_action_tween.parallel().tween_property(shield_arm, "rotation_degrees", 24.0, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_action_tween.parallel().tween_property(shield, "scale", Vector2.ONE, 0.18)

func get_next_position(current_position: Vector2, move_direction: Vector2, delta: float) -> Vector2:
	if move_direction != Vector2.ZERO:
		current_position += move_direction.normalized() * MOVE_SPEED * delta

	var root_position_limits := _get_root_position_limits()
	return Vector2(
		clampf(current_position.x, root_position_limits.position.x, root_position_limits.end.x),
		clampf(current_position.y, root_position_limits.position.y, root_position_limits.end.y)
	)

func get_screen_visual_bounds(for_position: Vector2) -> Rect2:
	var scale_abs := Vector2(absf(scale.x), absf(scale.y))
	var min_x: float
	var max_x: float

	if scale.x < 0.0:
		min_x = for_position.x - VISUAL_BOUNDS.end.x * scale_abs.x
		max_x = for_position.x - VISUAL_BOUNDS.position.x * scale_abs.x
	else:
		min_x = for_position.x + VISUAL_BOUNDS.position.x * scale_abs.x
		max_x = for_position.x + VISUAL_BOUNDS.end.x * scale_abs.x

	var min_y := for_position.y + VISUAL_BOUNDS.position.y * scale_abs.y
	var max_y := for_position.y + VISUAL_BOUNDS.end.y * scale_abs.y

	return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))

func _restart_action() -> void:
	if is_instance_valid(_action_tween):
		_action_tween.kill()
	_action_tween = create_tween()

func _get_root_position_limits() -> Rect2:
	var scale_abs := Vector2(absf(scale.x), absf(scale.y))
	var left_extent: float
	var right_extent: float

	if scale.x < 0.0:
		left_extent = VISUAL_BOUNDS.end.x * scale_abs.x
		right_extent = -VISUAL_BOUNDS.position.x * scale_abs.x
	else:
		left_extent = -VISUAL_BOUNDS.position.x * scale_abs.x
		right_extent = VISUAL_BOUNDS.end.x * scale_abs.x

	var top_extent := -VISUAL_BOUNDS.position.y * scale_abs.y
	var bottom_extent := VISUAL_BOUNDS.end.y * scale_abs.y

	return Rect2(
		Vector2(left_extent, top_extent),
		Vector2(VIEWPORT_SIZE.x - left_extent - right_extent, UI_PANEL_TOP - top_extent - bottom_extent)
	)

func _update_facing(move_direction: Vector2) -> void:
	if move_direction.x != 0.0:
		scale.x = absf(_base_scale.x) * signf(move_direction.x)

func _update_walk_animation(move_direction: Vector2, delta: float) -> void:
	var smoothing := minf(delta * 14.0, 1.0)

	if move_direction == Vector2.ZERO:
		_walk_time = 0.0
		rotation_degrees = lerpf(rotation_degrees, 0.0, smoothing)
		return

	_walk_time += delta * 10.0
	rotation_degrees = lerpf(rotation_degrees, sin(_walk_time) * 2.5, smoothing)
