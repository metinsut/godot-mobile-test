extends Node2D

@onready var sword_arm: Node2D = %SwordArm
@onready var shield_arm: Node2D = %ShieldArm
@onready var shield: Polygon2D = %Shield

var _action_tween: Tween

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

func _restart_action() -> void:
	if is_instance_valid(_action_tween):
		_action_tween.kill()
	_action_tween = create_tween()
