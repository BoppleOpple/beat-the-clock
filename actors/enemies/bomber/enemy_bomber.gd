class_name EnemyBomber
extends EnemyBase

const PANIC_DASH_CHANCE: float = 0.25

const EVADE_JUMP_CHANCE: float = 0.15

###########
# GLOBALS #
###########

var next_bomb: int = 2

var bomb_timer_duration: float = GameManager.ABILITY_COOLDOWN[GameManager.Ability.SWORD] * 0.2

###########
# METHODS #
###########

func _ready() -> void:
	super()
	
	state_graph = {
		"IDLE": ["IDLE", "EVADE", "RUSH"],
		"RUSH": ["IDLE", "RUSH", "EVADE", "EVADE"],
		"EVADE": ["IDLE", "EVADE", "RUSH", "RUSH"],
		"RECOVERY": ["RUSH"]
	}
	
	state_durations = {
		"IDLE": 1.0,
		"RUSH": 2.0,
		"EVADE": 2.0,
		"RECOVERY": 0.5
	}
	
	ability_1 = GameManager.Ability.DASH
	ability_2 = GameManager.Ability.GRENADE
	ability_3 = GameManager.Ability.GRENADE

func _get_move_x() -> float:
	if self.target_node == null:
		return false
	if self.target_node is Grenade:
		return sign(global_position.x - self.target_node.global_position.y)

	match current_state:
		"IDLE":
			return clamp(-global_position.x / 1000, -1, 1)
		"RUSH":
			return clamp((self.target_node.global_position.x - global_position.x) / 300, -1, 1)
		"EVADE":
			return clamp(-(self.target_node.global_position.x - global_position.x) / 1000, -1, 1)
		"RECOVERY":
			return clamp(-global_position.x / 1000, -1, 1)
	return 0.0

func _get_jump() -> bool:
	if self.target_node == null:
		return false
	if self.target_node is Grenade:
		var actor_to_grenade: Vector2 = self.target_node.global_position - global_position
		if abs(actor_to_grenade.y) < 50 and actor_to_grenade.dot(self.target_node.linear_velocity) > -0.1:
			return true
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
		"EVADE":
			var random_jump: bool = randf() < EVADE_JUMP_CHANCE
			var obstructed: bool = false
			if global_position.x < self.target_node.global_position.x:
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
			return random_jump or obstructed
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
		"EVADE":
			return self.target_node.global_position.y < global_position.y + 20
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
		"EVADE":
			return false
		"RECOVERY":
			if $Unrotatable/Senses/SenseLeft.is_colliding():
				self.target_direction = Vector2.from_angle(-3*PI/4)
				return true
			if $Unrotatable/Senses/SenseRight.is_colliding():
				self.target_direction = Vector2.from_angle(-PI/4)
				return true
			if randf() < PANIC_DASH_CHANCE:
				self.target_direction = Vector2.UP
				return true
	return false

func _get_ability_2() -> bool:
	if self.target_node == null:
		return false
	if self.target_node is Grenade:
		return false
	if self.current_state == "IDLE":
		return false
	if ( \
		global_position.distance_to(self.target_node.global_position) > 150 \
		and next_bomb == 2 \
		and $Timers/BombTimer.time_left == 0 \
	):
		self.target_direction = (self.target_node.global_position - self.global_position).normalized()
		$Timers/BombTimer.start(bomb_timer_duration)
		next_bomb = 3
		return true
	return false

func _get_ability_3() -> bool:
	if self.target_node == null:
		return false
	if self.target_node is Grenade:
		return false
	if self.current_state == "IDLE":
		return false
	if ( \
		global_position.distance_to(self.target_node.global_position) > 150 \
		and next_bomb == 3 \
		and $Timers/BombTimer.time_left == 0 \
	):
		self.target_direction = (self.target_node.global_position - self.global_position).normalized()
		self.target_direction.y -= 0.9
		self.target_direction = self.target_direction.normalized()
		$Timers/BombTimer.start(bomb_timer_duration)
		next_bomb = 2
		return true
	return false

func _get_ability_combo() -> bool:
	return false
