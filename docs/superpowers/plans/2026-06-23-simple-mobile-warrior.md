# Simple Mobile Warrior Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a tiny Godot mobile prototype with one stationary warrior, an attack button, and a defend button.

**Architecture:** The project uses a single main scene that owns the layout and UI, plus a focused warrior scene that owns the character drawing and animations. The warrior script exposes two public methods, `attack()` and `defend()`, so the main scene has a simple interface to call.

**Tech Stack:** Godot 4 text scenes (`.tscn`), GDScript, built-in `Tween`, built-in 2D nodes, and a headless Godot smoke test.

---

## File Structure

- Create `tests/test_project_structure.gd`: headless Godot smoke test for expected files and warrior API.
- Create `tests/validate_project_structure.sh`: local fallback smoke test when Godot CLI is not installed.
- Create `scripts/warrior.gd`: character animation API.
- Create `scenes/warrior.tscn`: drawable warrior made from Godot 2D nodes.
- Create `scripts/main.gd`: UI button wiring.
- Create `scenes/main.tscn`: mobile-friendly root scene and bottom controls.
- Modify `project.godot`: set `run/main_scene` to `res://scenes/main.tscn`.
- Modify `README.md`: explain the small project layout.

## Task 1: Headless Structure Test

**Files:**
- Create: `tests/test_project_structure.gd`
- Create: `tests/validate_project_structure.sh`

- [ ] **Step 1: Write the failing test**

```gdscript
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
```

Create the fallback shell test with the same expectations:

```bash
#!/usr/bin/env bash
set -u

failures=0

require_file() {
	local path="$1"
	if [[ ! -f "$path" ]]; then
		echo "Missing required file: $path" >&2
		failures=$((failures + 1))
	fi
}

require_text() {
	local path="$1"
	local text="$2"
	local message="$3"
	if [[ ! -f "$path" ]] || ! grep -Fq "$text" "$path"; then
		echo "$message" >&2
		failures=$((failures + 1))
	fi
}

require_file "scenes/main.tscn"
require_file "scenes/warrior.tscn"
require_file "scripts/main.gd"
require_file "scripts/warrior.gd"

require_text "scripts/warrior.gd" "func attack() -> void:" "Warrior must expose attack()"
require_text "scripts/warrior.gd" "func defend() -> void:" "Warrior must expose defend()"
require_text "scenes/main.tscn" "AttackButton" "Main scene must include AttackButton"
require_text "scenes/main.tscn" "DefendButton" "Main scene must include DefendButton"
require_text "project.godot" "run/main_scene=\"res://scenes/main.tscn\"" "Project must point to main scene"

if [[ "$failures" -eq 0 ]]; then
	echo "Project structure smoke test passed."
	exit 0
fi

exit 1
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `godot --headless --script tests/test_project_structure.gd`

Expected: exit code `1` with missing file errors for the new scenes and scripts.

If `godot` is not installed, run: `bash tests/validate_project_structure.sh`

Expected: exit code `1` with missing file errors for the new scenes and scripts.

## Task 2: Warrior Scene and Animation API

**Files:**
- Create: `scripts/warrior.gd`
- Create: `scenes/warrior.tscn`
- Test: `tests/test_project_structure.gd`

- [ ] **Step 1: Write the minimal warrior script**

```gdscript
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
	if _action_tween:
		_action_tween.kill()
	_action_tween = create_tween()
```

- [ ] **Step 2: Create the warrior scene**

Create `scenes/warrior.tscn` with a `Node2D` root using `scripts/warrior.gd`, simple child nodes named `SwordArm`, `ShieldArm`, and `Shield`, and polygon/line primitives for the body, sword, shield, boots, and helmet.

- [ ] **Step 3: Run the structure test**

Run: `godot --headless --script tests/test_project_structure.gd`

Expected: still fails because `scenes/main.tscn` and `scripts/main.gd` do not exist yet.

If `godot` is not installed, run: `bash tests/validate_project_structure.sh`

Expected: still fails because `scenes/main.tscn` and `scripts/main.gd` do not exist yet.

## Task 3: Main Scene, UI, and Project Entry Point

**Files:**
- Create: `scripts/main.gd`
- Create: `scenes/main.tscn`
- Modify: `project.godot`
- Modify: `README.md`
- Test: `tests/test_project_structure.gd`

- [ ] **Step 1: Write the main script**

```gdscript
extends Node2D

@onready var warrior: Node2D = %Warrior
@onready var attack_button: Button = %AttackButton
@onready var defend_button: Button = %DefendButton

func _ready() -> void:
	attack_button.pressed.connect(_on_attack_pressed)
	defend_button.pressed.connect(_on_defend_pressed)

func _on_attack_pressed() -> void:
	warrior.attack()

func _on_defend_pressed() -> void:
	warrior.defend()
```

- [ ] **Step 2: Create the main scene**

Create `scenes/main.tscn` with a `Node2D` root using `scripts/main.gd`, a background, a centered instance of `scenes/warrior.tscn`, and a bottom `CanvasLayer` containing two large buttons named `AttackButton` and `DefendButton`.

- [ ] **Step 3: Set the project entry point**

Add this line under `[application]` in `project.godot`:

```ini
run/main_scene="res://scenes/main.tscn"
```

- [ ] **Step 4: Update README**

Document the file layout and the purpose of each scene/script.

- [ ] **Step 5: Run the structure test**

Run: `godot --headless --script tests/test_project_structure.gd`

Expected: exit code `0` with `Project structure smoke test passed.`

If `godot` is not installed, run: `bash tests/validate_project_structure.sh`

Expected: exit code `0` with `Project structure smoke test passed.`

## Task 4: Final Verification

**Files:**
- Verify all files touched in Tasks 1-3.

- [ ] **Step 1: Run the Godot smoke test**

Run: `godot --headless --script tests/test_project_structure.gd`

Expected: exit code `0`.

If `godot` is not installed, run: `bash tests/validate_project_structure.sh`

Expected: exit code `0`.

- [ ] **Step 2: Run the main scene briefly in headless mode**

Run: `godot --headless --quit-after 1 --path .`

Expected: exit code `0`, with no scene load errors.

- [ ] **Step 3: Review git diff**

Run: `git diff --stat`

Expected: new scene/script/test/docs files plus `project.godot` and `README.md` changes.
