extends Resource
class_name PlayerData

# -----------
# ABILITY VALUES
# 0 - Empty
# 1 - Dash
# 2 - Sword
# 3 - Grenade
# -----------

enum Ability {
	EMPTY = 0,
	DASH = 1,
	SWORD = 2,
	GRENADE = 3,
}

@export var player_name: String = "Player"
@export var timer: float = 0.0
@export var ability_1: Ability = Ability.DASH
@export var ability_2: Ability = Ability.DASH
@export var ability_3: Ability = Ability.GRENADE
@export var ability_c: Ability = Ability.DASH
@export var ability_1_cooldown: float = 0.0
@export var ability_2_cooldown: float = 0.0
@export var ability_3_cooldown: float = 0.0
@export var ability_c_cooldown: float = 0.0
