extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_bg_select()


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
