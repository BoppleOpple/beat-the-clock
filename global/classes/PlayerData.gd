extends Resource
class_name PlayerData

const COLOR_PALETTE = {
	1: Color.RED,
	2: Color.ORANGE_RED,
	3: Color.ORANGE,
	4: Color.GOLDENROD,
	5: Color.YELLOW,
	6: Color.YELLOW_GREEN,
	7: Color.GREEN,
	8: Color.LIGHT_SEA_GREEN,
	9: Color.BLUE,
	10: Color.BLUE_VIOLET,
	11: Color.VIOLET,
	12: Color.MEDIUM_VIOLET_RED
}

# -----------
# ABILITY VALUES
# 0 - Empty
# 1 - Dash
# 2 - Sword
# 3 - Grenade
# -----------

var player_name: String = "Player"
var timer: float = 0.0
var ability_1_cooldown: float = 0.0
var ability_2_cooldown: float = 0.0
var ability_3_cooldown: float = 0.0
var ability_c_cooldown: float = 0.0
var color: Color = COLOR_PALETTE[1]
