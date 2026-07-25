class_name EnemyBase
extends ActorBase


###########
# GLOBALS #
###########

var state_graph: Dictionary[String, Array] = {
	"IDLE": ["IDLE"]
}

var state_durations: Dictionary[String, float] = {
	"IDLE": 5.0
}

var current_state: String = "IDLE"

###########
# METHODS #
###########

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	$Timers/StateTransitionTimer.start(state_durations[current_state])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
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

func get_aim_direction() -> Vector2:
	var target: Node2D = _get_current_target()
	
	return (target.global_position - self.global_position).normalized()

func _on_state_transition_timer_timeout() -> void:
	var state_pool: Array = state_graph[current_state]
	current_state = str(state_pool[randi_range(0, state_pool.size() - 1)])
	$Timers/StateTransitionTimer.start(state_durations[current_state])
