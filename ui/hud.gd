extends Control


func _ready() -> void:
	# Ability Slot 1
	$HBoxContainer/Ability1.max_value = GameManager.dash_cooldown
	# Ability Slot 2
	$HBoxContainer/Ability2.max_value = GameManager.sword_cooldown
	# Ability Slot 3
	$HBoxContainer/Ability3.max_value = GameManager.grenade_cooldown
	# Ability Slot 1 Cooldown
	$HBoxContainer/Ability1.value = GameManager.player1_a1_cooldown
	# Ability Slot 2 Cooldown
	$HBoxContainer/Ability2.value = GameManager.player1_a2_cooldown
	# Ability Slot 3 Cooldown
	$HBoxContainer/Ability3.value = GameManager.player1_a3_cooldown
	$VBoxContainer/Player1/Time.text = str(snapped(GameManager.player_curr_time, 0.1))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$HBoxContainer/Ability1.value -= delta
	$HBoxContainer/Ability2.value -= delta
	$HBoxContainer/Ability3.value -= delta
	GameManager.player_curr_time -= delta
	$VBoxContainer/Player1/Time.text = str(snapped(GameManager.player_curr_time, 0.1))
