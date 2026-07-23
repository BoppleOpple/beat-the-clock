extends Node

const PLAYER_MAX_TIME: float = 300.0
var player: PlayerData

# -----------
# ABILITY VALUES
# 0 - Empty
# 1 - Dash
# 2 - Sword
# 3 - Grenade
# -----------
const ABILITY_COOLDOWN: Array[float] = [10.0, 2.0, 2.5, 3.0]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = PlayerData.new()
	player.timer = 300.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	player.timer -= delta
	player.ability_1_cooldown -= delta
	if player.ability_1_cooldown < 0.0:
		player.ability_1_cooldown = 0.0
	player.ability_2_cooldown -= delta
	if player.ability_2_cooldown < 0.0:
		player.ability_2_cooldown = 0.0
	player.ability_3_cooldown -= delta
	if player.ability_3_cooldown < 0.0:
		player.ability_3_cooldown = 0.0
	player.ability_c_cooldown -= delta
	if player.ability_c_cooldown < 0.0:
		player.ability_c_cooldown = 0.0
	
func _ability_used(ability): # TODO: Is this needed?
	if player.ability_1 == ability and player.ability_1_cooldown == 0.0:
		player.ability_1_cooldown = ABILITY_COOLDOWN[ability]
	elif player.ability_2 == ability and player.ability_2_cooldown == 0.0:
		player.ability_2_cooldown = ABILITY_COOLDOWN[ability]
	elif player.ability_3 == ability and player.ability_3_cooldown == 0.0:
		player.ability_3_cooldown = ABILITY_COOLDOWN[ability]
	elif player.ability_c == ability and player.ability_c_cooldown == 0.0:
		player.ability_c_cooldown = ABILITY_COOLDOWN[ability]
	else:
		return false
	return true
