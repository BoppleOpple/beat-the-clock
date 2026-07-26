extends Control

@export var background_scale_x: float = 1.0
@export var background_scale_y: float = 1.0
@export var offset_x: float = -512.0
@export var offset_y: float = 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_bg_select()
	_apply_background_scale()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$BG.scroll_offset -= Vector2(20,0) * delta

func _bg_select(choice: int = 0) -> void:
	if choice == 0:
		choice = randi_range(1,8)
	$BG/"1"/Texture.texture = load("res://assets/textures/Clouds/Clouds " + str(choice) + "/1.png")
	$BG/"2"/Texture.texture = load("res://assets/textures/Clouds/Clouds " + str(choice) + "/2.png")
	$BG/"3"/Texture.texture = load("res://assets/textures/Clouds/Clouds " + str(choice) + "/3.png")
	$BG/"4"/Texture.texture = load("res://assets/textures/Clouds/Clouds " + str(choice) + "/4.png")
	if ResourceLoader.exists("res://assets/textures/Clouds/Clouds " + str(choice) + "/5.png"):
		$BG/"5"/Texture.texture = load("res://assets/textures/Clouds/Clouds " + str(choice) + "/5.png")
	if ResourceLoader.exists("res://assets/textures/Clouds/Clouds " + str(choice) + "/6.png"):
		$BG/"6"/Texture.texture = load("res://assets/textures/Clouds/Clouds " + str(choice) + "/6.png")
		
func _apply_background_scale() -> void:
	var scale_vec = Vector2(background_scale_x, background_scale_y)
	for layer_name in ["1", "2", "3", "4", "5", "6"]:
		var texture_node = get_node_or_null("BG/" + layer_name + "/Texture")
		if texture_node:
			texture_node.scale = texture_node.scale * scale_vec
			texture_node.position = texture_node.position + Vector2(offset_x,offset_y)
