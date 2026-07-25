class_name EnemyMelee
extends EnemyBase

###########
# GLOBALS #
###########

var next_sword: int = 2

###########
# METHODS #
###########

func _ready() -> void:
	super()
	
	state_graph = {
		"IDLE": ["IDLE", "IDLE", "IDLE", "RUSH"],
		"RUSH": ["IDLE"]
	}
	
	state_durations = {
		"IDLE": 2.0,
		"RUSH": 6.0
	}
	
	ability_1 = GameManager.Ability.DASH
	ability_2 = GameManager.Ability.SWORD
	ability_3 = GameManager.Ability.SWORD

func _get_move_x() -> float:
	var target: Node2D = _get_current_target()
	match current_state:
		"IDLE":
			return clamp(-global_position.x / 1000, -1, 1)
		"RUSH":
			return clamp((target.global_position.x - global_position.x) / 300, -1, 1)
	return 0.0

func _get_jump() -> bool:
	var target: Node2D = _get_current_target()
	match current_state:
		"IDLE":
			pass
		"RUSH":
			return target.global_position.y < global_position.y + 100
	return false

func _get_slow_fall() -> bool:
	var target: Node2D = _get_current_target()
	match current_state:
		"IDLE":
			return true
		"RUSH":
			return target.global_position.y < global_position.y - 20
	return false

func _get_ability_1() -> bool:
	var target: Node2D = _get_current_target()
	match current_state:
		"IDLE":
			return false
		"RUSH":
			# dash when far away
			return global_position.distance_to(target.global_position) > 500
	return false

func _get_ability_2() -> bool:
	var target: Node2D = _get_current_target()
	if global_position.distance_to(target.global_position) < 200 and next_sword == 2:
		next_sword = 3
		return true
	return false

func _get_ability_3() -> bool:
	var target: Node2D = _get_current_target()
	if global_position.distance_to(target.global_position) < 200 and next_sword == 3:
		next_sword = 2
		return true
	return false

func _get_ability_combo() -> bool:
	return false

func _get_current_target() -> Node2D:
	return GameManager.player_ref
