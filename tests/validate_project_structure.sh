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
require_text "scenes/main.tscn" "Cloud" "Main scene must include Cloud"
require_text "project.godot" "run/main_scene=\"res://scenes/main.tscn\"" "Project must point to main scene"

if [[ "$failures" -eq 0 ]]; then
	echo "Project structure smoke test passed."
	exit 0
fi

exit 1
