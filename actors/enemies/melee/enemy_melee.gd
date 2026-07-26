class_name EnemyMelee
extends EnemyBase

const PANIC_DASH_CHANCE: float = 0.33

###########
# GLOBALS #
###########

var next_sword: int = 2

var slash_timer_duration: float = GameManager.ABILITY_COOLDOWN[GameManager.Ability.SWORD] * 0.66

###########
# METHODS #
###########

func _ready() -> void:
	super()
	
	state_graph = {
		"IDLE": ["IDLE", "IDLE", "IDLE", "RUSH"],
		"RUSH": ["IDLE", "IDLE", "IDLE", "RUSH"],
		"RECOVERY": ["RUSH"]
	}
	
	state_durations = {
		"IDLE": 1.0,
		"RUSH": 6.0,
		"RECOVERY": 0.5
	}
	
	ability_1 = GameManager.Ability.DASH
	ability_2 = GameManager.Ability.SWORD
	ability_3 = GameManager.Ability.SWORD

func _get_move_x() -> float:
	if self.target_node == null:
		return false
	match current_state:
		"IDLE":
			return clamp(-global_position.x / 1000, -1, 1)
		"RUSH":
			return clamp((self.target_node.global_position.x - global_position.x) / 300, -1, 1)
		"RECOVERY":
			return clamp(-global_position.x / 1000, -1, 1)
	return 0.0

func _get_jump() -> bool:
	if self.target_node == null:
		return false
	match current_state:
		"IDLE":
			var obstructed: bool = false
			if global_position.x > 0:
				if (
					$Unrotatable/Senses/SenseLeft.is_colliding()
					and global_position.distance_to($Unrotatable/Senses/SenseLeft.get_collision_point()) < 250
				):
					obstructed = true
			else:
				if (
					$Unrotatable/Senses/SenseRight.is_colliding()
					and global_position.distance_to($Unrotatable/Senses/SenseRight.get_collision_point()) < 250
				):
					obstructed = true
			return obstructed
		"RUSH":
			var target_above: bool = self.target_node.global_position.y < global_position.y + 100
			var obstructed: bool = false
			if global_position.x > self.target_node.global_position.x:
				if (
					$Unrotatable/Senses/SenseLeft.is_colliding()
					and global_position.distance_to($Unrotatable/Senses/SenseLeft.get_collision_point()) < 250
				):
					obstructed = true
			else:
				if (
					$Unrotatable/Senses/SenseRight.is_colliding()
					and global_position.distance_to($Unrotatable/Senses/SenseRight.get_collision_point()) < 250
				):
					obstructed = true
			return target_above or obstructed
		"RECOVERY":
			return true
	return false

func _get_slow_fall() -> bool:
	if self.target_node == null:
		return false
	match current_state:
		"IDLE":
			return false
		"RUSH":
			return self.target_node.global_position.y < global_position.y - 20
		"RECOVERY":
			return true
	return false

func _get_ability_1() -> bool:
	if self.target_node == null:
		return false
	match current_state:
		"IDLE":
			return false
		"RUSH":
			# dash when far away
			return global_position.distance_to(self.target_node.global_position) > 500
		"RECOVERY":
			if $Unrotatable/Senses/SenseLeft.is_colliding():
				self.target_direction = Vector2.from_angle(-3*PI/4)
				return true
			if $Unrotatable/Senses/SenseRight.is_colliding():
				self.target_direction = Vector2.from_angle(-PI/4)
				return true
			if randf() < PANIC_DASH_CHANCE and self.global_position.y > 0:
				self.target_direction = Vector2.UP
				return true
	return false

func _get_ability_2() -> bool:
	if self.target_node == null:
		return false
	if ( \
		global_position.distance_to(self.target_node.global_position) < 200 \
		and next_sword == 2 \
		and $Timers/SlashTimer.time_left == 0 \
	):
		$Timers/SlashTimer.start(slash_timer_duration)
		next_sword = 3
		return true
	return false

func _get_ability_3() -> bool:
	if self.target_node == null:
		return false
	if ( \
		global_position.distance_to(self.target_node.global_position) < 200 \
		and next_sword == 3 \
		and $Timers/SlashTimer.time_left == 0 \
	):
		$Timers/SlashTimer.start(slash_timer_duration)
		next_sword = 2
		return true
	return false

func _get_ability_combo() -> bool:
	return false
