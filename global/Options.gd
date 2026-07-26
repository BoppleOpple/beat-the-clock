extends Resource
class_name Options

var resolutions: Array[Vector2i] = [
	Vector2i(1280,720),
	Vector2i(1600,900),
	Vector2i(1920,1080),
	Vector2i(2560,1440),
	Vector2i(3840,2160),
]

@export var resolution_x: int = resolutions[2].x
@export var resolution_y: int = resolutions[2].y
@export var fullscreen: bool = false
@export var vsync: bool = false
@export var framerate: int = 60
@export var volume_master: int = 60
@export var volume_music: int = 100
@export var volume_sfx: int = 100
@export var num_of_enemies: int = 1
