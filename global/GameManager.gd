extends Node

var player_max_time: float = 300.0
var player_curr_time: float
var player1_a1_cooldown: float = 0.0
var player1_a2_cooldown: float = 0.0
var player1_a3_cooldown: float = 0.0

var dash_cooldown: float = 1.0
var sword_cooldown: float = 2.0
var grenade_cooldown: float = 2.5


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_curr_time = 300.0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
