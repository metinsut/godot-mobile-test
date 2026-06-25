extends SceneTree

const REQUIRED_FILES := [
	"res://scenes/main.tscn",
	"res://scenes/warrior.tscn",
	"res://scripts/main.gd",
	"res://scripts/warrior.gd",
]

func _init() -> void:
	var failures: Array[String] = []

	for path in REQUIRED_FILES:
		if not FileAccess.file_exists(path):
			failures.append("Missing required file: %s" % path)

	var main_scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")
	if not main_scene_text.contains("Cloud"):
		failures.append("Main scene must include Cloud")

	var warrior_script := load("res://scripts/warrior.gd")
	if warrior_script == null:
		failures.append("Unable to load warrior script")
	else:
		var warrior := Node2D.new()
		warrior.set_script(warrior_script)
		if not warrior.has_method("attack"):
			failures.append("Warrior must expose attack()")
		if not warrior.has_method("defend"):
			failures.append("Warrior must expose defend()")
		if not warrior.has_method("get_next_position"):
			failures.append("Warrior must expose get_next_position()")
		else:
			var moved_position: Vector2 = warrior.get_next_position(Vector2(360, 572), Vector2.RIGHT, 0.5)
			if not moved_position.is_equal_approx(Vector2(490, 572)):
				failures.append("Warrior must move right according to movement speed")
		if not warrior.has_method("get_screen_visual_bounds"):
			failures.append("Warrior must expose get_screen_visual_bounds()")
		else:
			warrior.scale = Vector2(-1.72, 1.72)
			var left_position: Vector2 = warrior.get_next_position(Vector2(360, 572), Vector2.LEFT, 10.0)
			var left_bounds: Rect2 = warrior.get_screen_visual_bounds(left_position)
			if not is_equal_approx(left_bounds.position.x, 0.0):
				failures.append("Warrior visible left edge must stop at screen left")

			warrior.scale = Vector2(1.72, 1.72)
			var right_position: Vector2 = warrior.get_next_position(Vector2(360, 572), Vector2.RIGHT, 10.0)
			var right_bounds: Rect2 = warrior.get_screen_visual_bounds(right_position)
			if not is_equal_approx(right_bounds.end.x, 720.0):
				failures.append("Warrior visible right edge must stop at screen right")

			var down_position: Vector2 = warrior.get_next_position(Vector2(360, 572), Vector2.DOWN, 10.0)
			var down_bounds: Rect2 = warrior.get_screen_visual_bounds(down_position)
			if not is_equal_approx(down_bounds.end.y, 1040.0):
				failures.append("Warrior visible bottom edge must stop above action buttons")
		warrior.free()

	for action in ["move_left", "move_right", "move_up", "move_down"]:
		if not ProjectSettings.has_setting("input/%s" % action):
			failures.append("Project must define input action: %s" % action)

	if failures.is_empty():
		print("Project structure smoke test passed.")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
