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
require_text "scripts/warrior.gd" "func get_next_position(" "Warrior must expose get_next_position()"
require_text "scripts/warrior.gd" "const VISUAL_BOUNDS" "Warrior movement must use visual bounds"
require_text "scripts/warrior.gd" "const UI_PANEL_TOP := 1040.0" "Warrior bottom edge must stop above action buttons"
require_text "scripts/warrior.gd" "func get_screen_visual_bounds(" "Warrior must expose visible screen bounds"
require_text "scenes/main.tscn" "AttackButton" "Main scene must include AttackButton"
require_text "scenes/main.tscn" "DefendButton" "Main scene must include DefendButton"
require_text "scenes/main.tscn" "Cloud" "Main scene must include Cloud"
require_text "project.godot" "move_left={" "Project must define move_left input action"
require_text "project.godot" "move_right={" "Project must define move_right input action"
require_text "project.godot" "move_up={" "Project must define move_up input action"
require_text "project.godot" "move_down={" "Project must define move_down input action"
require_text "project.godot" "run/main_scene=\"res://scenes/main.tscn\"" "Project must point to main scene"

if [[ "$failures" -eq 0 ]]; then
	echo "Project structure smoke test passed."
	exit 0
fi

exit 1
