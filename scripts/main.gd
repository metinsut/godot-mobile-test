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
