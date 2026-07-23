extends ParallaxLayer

const TEXTURE_WIDTH: int = 576
const TEXTURE_HEIGHT: int = 324

@onready var rect: TextureRect = $Texture

func _ready():
	get_viewport().size_changed.connect(_update_size)
	_update_size()
	
func _update_size():
	var size = get_viewport().get_visible_rect().size
	var scale = size.y / TEXTURE_HEIGHT
	
	rect.scale = Vector2(scale,scale)
	rect.size = Vector2(size.x / scale + TEXTURE_WIDTH, TEXTURE_HEIGHT)
	
	motion_mirroring = Vector2(TEXTURE_WIDTH * scale, 0)
