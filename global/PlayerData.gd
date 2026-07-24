extends Resource
class_name PlayerData

# -----------
# ABILITY VALUES
# 0 - Empty
# 1 - Dash
# 2 - Sword
# 3 - Grenade
# -----------

@export var player_name: String = "Player"
@export var timer: float = 0.0
@export var ability_1: int = 1
@export var ability_2: int = 1
@export var ability_3: int = 3
@export var ability_c: int = 1
@export var ability_1_cooldown: float = 0.0
@export var ability_2_cooldown: float = 0.0
@export var ability_3_cooldown: float = 0.0
@export var ability_c_cooldown: float = 0.0
