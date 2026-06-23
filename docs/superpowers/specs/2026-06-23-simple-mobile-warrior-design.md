# Simple Mobile Warrior Design

## Goal

Build a very small Godot mobile prototype for learning project structure. The game shows one stationary warrior holding a sword and shield, with two bottom buttons: attack and defend.

## Scope

- One playable screen.
- One warrior in the center of the screen.
- Two touch-friendly buttons at the bottom.
- Simple attack and defend animations.
- No enemies, movement, health, scoring, inventory, menus, or progression.

## Architecture

- `project.godot` points to `res://scenes/main.tscn` as the main scene.
- `scenes/main.tscn` owns the camera-scale layout, background, title label, warrior instance, and bottom controls.
- `scenes/warrior.tscn` owns the character drawing and animation targets.
- `scripts/main.gd` connects UI button presses to the warrior.
- `scripts/warrior.gd` exposes `attack()` and `defend()` methods and runs tweens for simple animation.
- `tests/test_project_structure.gd` is a headless smoke test that confirms the expected files and callable warrior API exist.
- `tests/validate_project_structure.sh` is a local fallback smoke test for machines where the Godot CLI is not installed.

## Visual Design

The warrior is drawn with Godot nodes rather than external image assets so the project stays easy to inspect. Body parts use simple `Polygon2D` and `Line2D` shapes: helmet, torso, arms, sword, shield, and boots.

The style is intentionally toy-like and readable on mobile: warm background, centered character, large bottom buttons, and clear color separation between sword and shield.

## Interaction Flow

- Tapping `Attack` calls `Warrior.attack()`.
- The sword arm rotates forward and returns to idle.
- Tapping `Defend` calls `Warrior.defend()`.
- The shield arm raises, the shield briefly grows, then returns to idle.
- If an animation is already running, the next button press restarts that action cleanly.

## Testing

The first verification target is a Godot headless script:

```bash
godot --headless --script tests/test_project_structure.gd
```

The test checks that the main scene, warrior scene, and warrior script are present and that the warrior instance exposes `attack` and `defend`.

When the Godot CLI is not available, use the local fallback:

```bash
bash tests/validate_project_structure.sh
```

Manual visual verification is opening the project in Godot or running the main scene after the headless test passes.
