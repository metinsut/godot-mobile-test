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
		warrior.free()

	if failures.is_empty():
		print("Project structure smoke test passed.")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
