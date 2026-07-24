extends Control

var dash_texture = load("res://assets/textures/dash.png")
var sword_texture = load("res://assets/textures/sword.png")
var grenade_texture = load("res://assets/textures/grenade.png")

# -----------
# ABILITY VALUES
# 0 - Empty
# 1 - Dash
# 2 - Sword
# 3 - Grenade
# -----------

func _ready() -> void:
	# Ability Slot 1
	$AbilityFG/Ability1.max_value = GameManager.ABILITY_COOLDOWN[GameManager.player.ability_1]
	# Ability Slot 2
	$AbilityFG/Ability2.max_value = GameManager.ABILITY_COOLDOWN[GameManager.player.ability_2]
	# Ability Slot 3
	$AbilityFG/Ability3.max_value = GameManager.ABILITY_COOLDOWN[GameManager.player.ability_3]
	# Ability Slot 1 Cooldown
	$AbilityFG/Ability1.value = GameManager.player.ability_1_cooldown
	# Ability Slot 2 Cooldown
	$AbilityFG/Ability2.value = GameManager.player.ability_2_cooldown
	# Ability Slot 3 Cooldown
	$AbilityFG/Ability3.value = GameManager.player.ability_3_cooldown
	_ability_texture_update()


func _process(delta: float) -> void:
	$AbilityFG/Ability1.value = GameManager.player.ability_1_cooldown
	$AbilityFG/Ability2.value = GameManager.player.ability_2_cooldown
	$AbilityFG/Ability3.value = GameManager.player.ability_3_cooldown

func _ability_texture_update() -> void:
	# ABILITY 1 TEXTURE
	if GameManager.player.ability_1 == 0:
		$AbilityFG/Ability1.texture_under = null
	elif GameManager.player.ability_1 == 1:
		$AbilityFG/Ability1.texture_under = dash_texture
	elif GameManager.player.ability_1 == 2:
		$AbilityFG/Ability1.texture_under = sword_texture
	elif GameManager.player.ability_1 == 3:
		$AbilityFG/Ability1.texture_under = grenade_texture
	# ABILITY 2 TEXTURE
	if GameManager.player.ability_2 == 0:
		$AbilityFG/Ability2.texture_under = null
	elif GameManager.player.ability_2 == 1:
		$AbilityFG/Ability2.texture_under = dash_texture
	elif GameManager.player.ability_2 == 2:
		$AbilityFG/Ability2.texture_under = sword_texture
	elif GameManager.player.ability_2 == 3:
		$AbilityFG/Ability2.texture_under = grenade_texture
	# ABILITY 3 TEXTURE
	if GameManager.player.ability_3 == 0:
		$AbilityFG/Ability3.texture_under = null
	elif GameManager.player.ability_3 == 1:
		$AbilityFG/Ability3.texture_under = dash_texture
	elif GameManager.player.ability_3 == 2:
		$AbilityFG/Ability3.texture_under = sword_texture
	elif GameManager.player.ability_3 == 3:
		$AbilityFG/Ability3.texture_under = grenade_texture
		
