class_name EnemyBase
extends ActorBase


###########
# GLOBALS #
###########

var state_graph: Dictionary[String, Array] = {
	"IDLE": ["IDLE"],
	"RECOVERY": ["IDLE"]
}

var state_durations: Dictionary[String, float] = {
	"IDLE": 5.0,
	"RECOVERY": 0.5
}

var current_state: String = "IDLE"
var target_node: Node2D
var target_direction: Vector2
var nearby_nodes: Array[Node2D]

###########
# METHODS #
###########

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	$Timers/StateTransitionTimer.start(state_durations[current_state])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	self.nearby_nodes = $Unrotatable/Senses/SenseArea.get_overlapping_bodies()
	self.target_node = _get_current_target()
	self.target_direction = Vector2.ZERO
	
	_check_recovery()
	
	var frame_actions: Actions = Actions.new()
	
	frame_actions.move_x = _get_move_x()
	frame_actions.jump = _get_jump()
	frame_actions.slow_fall = _get_slow_fall()
	frame_actions.ability_1 = _get_ability_1()
	frame_actions.ability_2 = _get_ability_2()
	frame_actions.ability_3 = _get_ability_3()
	frame_actions.ability_combo = _get_ability_combo()
	
	_apply_actions(frame_actions, delta)

func _get_move_x() -> float:
	return 0.0

func _get_jump() -> bool:
	return false

func _get_slow_fall() -> bool:
	return false

func _get_ability_1() -> bool:
	return false

func _get_ability_2() -> bool:
	return false

func _get_ability_3() -> bool:
	return false

func _get_ability_combo() -> bool:
	return false

func _get_current_target() -> Node2D:
	return GameManager.player_ref

func _check_recovery() -> void:
	if $Timers/PanicTimer.time_left > 0:
		return
		
	$Unrotatable/Senses/SenseLeft.global_position = self.global_position
	$Unrotatable/Senses/SenseBelowLeft.global_position = self.global_position
	$Unrotatable/Senses/SenseBelow.global_position = self.global_position
	$Unrotatable/Senses/SenseBelowRight.global_position = self.global_position
	$Unrotatable/Senses/SenseRight.global_position = self.global_position
	
	var successful_rays: int = 0
	
	if $Unrotatable/Senses/SenseBelowLeft.is_colliding():  successful_rays += 1
	if $Unrotatable/Senses/SenseBelow.is_colliding():      successful_rays += 1
	if $Unrotatable/Senses/SenseBelowRight.is_colliding(): successful_rays += 1
	
	if successful_rays <= 1:
		_set_state("RECOVERY")

func _set_state(state: String) -> void:
	current_state = state
	$Timers/StateTransitionTimer.start(state_durations[state])

func get_aim_direction() -> Vector2:
	if self.target_direction == Vector2.ZERO:
		self.target_direction = (target_node.global_position - self.global_position).normalized()
	
	return self.target_direction

func _on_state_transition_timer_timeout() -> void:
	var state_pool: Array = state_graph[current_state]
	_set_state(str(state_pool[randi_range(0, state_pool.size() - 1)]))
