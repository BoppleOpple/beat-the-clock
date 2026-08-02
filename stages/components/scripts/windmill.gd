extends Node2D

const MAX_SPEED = 3.0

@onready var Blade1: TileMapLayer = $"Blade1"
@onready var Blade2: TileMapLayer = $"Blade2"

var time_elapsed: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_elapsed += delta
	var speed = lerp(0.5, MAX_SPEED, time_elapsed/30)
	Blade1.rotate(delta * speed)
	Blade2.rotate(delta * -speed)
