extends Control

var dash_texture = load("res://assets/textures/dash.png")
var sword_texture = load("res://assets/textures/sword.png")
var grenade_texture = load("res://assets/textures/grenade.png")

var player: Player
# -----------
# ABILITY VALUES
# 0 - Empty
# 1 - Dash
# 2 - Sword
# 3 - Grenade
# -----------

func _ready() -> void:
	GameManager.local_player_ready.connect(_initialize)
	
	player = GameManager.get_local_player()
	if player:
		_initialize(player)
	

func _initialize(p: Player):
	player = p
	# Ability Slot 1
	$AbilityFG/VBoxContainer/LowerAbilities/Ability1.max_value = GameManager.ABILITY_COOLDOWN[player.ability_1]
	# Ability Slot 2
	$AbilityFG/VBoxContainer/LowerAbilities/Ability2.max_value = GameManager.ABILITY_COOLDOWN[player.ability_2]
	# Ability Slot 3
	$AbilityFG/VBoxContainer/LowerAbilities/Ability3.max_value = GameManager.ABILITY_COOLDOWN[player.ability_3]
	# Ability Slot C
	$AbilityFG/VBoxContainer/UpperAbilities/AbilityC.max_value = GameManager.ABILITY_COOLDOWN[player.ability_c]
	_ability_texture_update()

func _process(delta: float) -> void:
	if player == null:
		return
	$AbilityFG/VBoxContainer/LowerAbilities/Ability1.value = player.player_data.ability_1_cooldown
	$AbilityFG/VBoxContainer/LowerAbilities/Ability2.value = player.player_data.ability_2_cooldown
	$AbilityFG/VBoxContainer/LowerAbilities/Ability3.value = player.player_data.ability_3_cooldown
	$AbilityFG/VBoxContainer/UpperAbilities/AbilityC.value = player.player_data.ability_c_cooldown
	ability_icon_change()

func _ability_texture_update() -> void:
	# ABILITY 1 TEXTURE
	if player.ability_1 == 0:
		$AbilityFG/VBoxContainer/LowerAbilities/Ability1.texture_under = null
	elif player.ability_1 == 1:
		$AbilityFG/VBoxContainer/LowerAbilities/Ability1.texture_under = dash_texture
	elif player.ability_1 == 2:
		$AbilityFG/VBoxContainer/LowerAbilities/Ability1.texture_under = sword_texture
	elif player.ability_1 == 3:
		$AbilityFG/VBoxContainer/LowerAbilities/Ability1.texture_under = grenade_texture
	# ABILITY 2 TEXTURE
	if player.ability_2 == 0:
		$AbilityFG/VBoxContainer/LowerAbilities/Ability2.texture_under = null
	elif player.ability_2 == 1:
		$AbilityFG/VBoxContainer/LowerAbilities/Ability2.texture_under = dash_texture
	elif player.ability_2 == 2:
		$AbilityFG/VBoxContainer/LowerAbilities/Ability2.texture_under = sword_texture
	elif player.ability_2 == 3:
		$AbilityFG/VBoxContainer/LowerAbilities/Ability2.texture_under = grenade_texture
	# ABILITY 3 TEXTURE
	if player.ability_3 == 0:
		$AbilityFG/VBoxContainer/LowerAbilities/Ability3.texture_under = null
	elif player.ability_3 == 1:
		$AbilityFG/VBoxContainer/LowerAbilities/Ability3.texture_under = dash_texture
	elif player.ability_3 == 2:
		$AbilityFG/VBoxContainer/LowerAbilities/Ability3.texture_under = sword_texture
	elif player.ability_3 == 3:
		$AbilityFG/VBoxContainer/LowerAbilities/Ability3.texture_under = grenade_texture
	# ABILITY C TEXTURE
	if player.ability_c == 0:
		$AbilityFG/VBoxContainer/UpperAbilities/AbilityC.texture_under = null
	elif player.ability_c == 1:
		$AbilityFG/VBoxContainer/UpperAbilities/AbilityC.texture_under = dash_texture
	elif player.ability_c == 2:
		$AbilityFG/VBoxContainer/UpperAbilities/AbilityC.texture_under = sword_texture
	elif player.ability_c == 3:
		$AbilityFG/VBoxContainer/UpperAbilities/AbilityC.texture_under = grenade_texture
		
func ability_icon_change() -> void:
	if GameManager.current_device == GameManager.InputDevice.KEYBOARD_MOUSE:
		$AbilityBG/VBoxContainer/UpperIcons_Con.hide()
		$AbilityBG/VBoxContainer/UpperIcons_KB.show()
		$AbilityBG/VBoxContainer/LowerIcons_Con.hide()
		$AbilityBG/VBoxContainer/LowerIcons_KB.show()
	elif GameManager.current_device == GameManager.InputDevice.CONTROLLER:
		$AbilityBG/VBoxContainer/UpperIcons_Con.show()
		$AbilityBG/VBoxContainer/UpperIcons_KB.hide()
		$AbilityBG/VBoxContainer/LowerIcons_Con.show()
		$AbilityBG/VBoxContainer/LowerIcons_KB.hide()
	return

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		GameManager.current_device = GameManager.InputDevice.KEYBOARD_MOUSE
	elif event is InputEventJoypadMotion or event is InputEventJoypadButton:
		GameManager.current_device = GameManager.InputDevice.CONTROLLER
	
	
