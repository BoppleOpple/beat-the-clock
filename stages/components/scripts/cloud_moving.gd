extends Node2D

const MAXIMUM_RANGE_X = 128.0
const MAXIMUM_RANGE_Y = 64
const SPEED = 0.5

@onready var platform_left: TileMapLayer = $"Platform Left"
@onready var platform_right: TileMapLayer = $"Platform Right"

var platform_left_position: Vector2
var platform_right_position: Vector2
var time_elapsed: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	platform_left_position = platform_left.position
	platform_right_position = platform_right.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_elapsed += delta
	var offset = Vector2.ZERO
	offset.x = MAXIMUM_RANGE_X * sin(1.5 * time_elapsed * SPEED) 
	offset.y = MAXIMUM_RANGE_Y * cos(0.5 * time_elapsed * SPEED)
	platform_left.position = Vector2(platform_left_position.x + offset.x, platform_left_position.y + offset.y - MAXIMUM_RANGE_Y)
	platform_right.position = Vector2(platform_right_position.x - offset.x, platform_left_position.y - offset.y - MAXIMUM_RANGE_Y)
