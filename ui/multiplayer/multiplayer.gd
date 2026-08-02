extends Control

@onready var IPText = $MarginContainer/Rows/UpperColumns/RightColumn/IPBox/IPText
@onready var PortText = $MarginContainer/Rows/UpperColumns/RightColumn/PortBox/PortText

var waiting: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MarginContainer/Rows/UpperColumns/RightColumn/IPBox/IPText.text = GameManager.options.last_used_ip
	$MarginContainer/Rows/UpperColumns/RightColumn/PortBox/PortText.text = GameManager.options.last_used_port
	$MarginContainer/Rows/LowerButtons/CreateServer.disabled = false
	$MarginContainer/Rows/LowerButtons/JoinServer.disabled = false
	
	NetworkManager.server_created.connect(_on_connection_ready)
	NetworkManager.player_connected.connect(_on_player_connected)
	NetworkManager.connection_failed.connect(_on_connection_failed)

func _process(delta: float) -> void:
	if waiting == true:
		$MarginContainer/Rows/Waiting/LoadingLabel.show()
		$MarginContainer/Rows/Waiting/LoadingTimer.autostart = true
		$MarginContainer/Rows/Waiting/LoadingTimer.paused = false
	else:
		$MarginContainer/Rows/LowerButtons/CreateServer.disabled = false
		$MarginContainer/Rows/LowerButtons/JoinServer.disabled = false
		$MarginContainer/Rows/Waiting/LoadingLabel.hide()
		$MarginContainer/Rows/Waiting/LoadingTimer.autostart = false
		$MarginContainer/Rows/Waiting/LoadingTimer.paused = true
		
func _on_loading_timer_timeout() -> void:
	match $MarginContainer/Rows/Waiting/LoadingLabel.text:
		"Waiting":
			$MarginContainer/Rows/Waiting/LoadingLabel.text = "Waiting."
		"Waiting.":
			$MarginContainer/Rows/Waiting/LoadingLabel.text = "Waiting.."
		"Waiting..":
			$MarginContainer/Rows/Waiting/LoadingLabel.text = "Waiting..."
		"Waiting...":
			$MarginContainer/Rows/Waiting/LoadingLabel.text = "Waiting"
		_:
			$MarginContainer/Rows/Waiting/LoadingLabel.text = "Waiting"


func _on_create_server_pressed() -> void:
	$MarginContainer/Rows/LowerButtons/CreateServer.disabled = true
	$MarginContainer/Rows/LowerButtons/JoinServer.disabled = true
	var port = int(PortText.text) if PortText.text != "" else 7777
	NetworkManager.host_game(port,16)
	waiting = true

func _on_join_server_pressed() -> void:
	$MarginContainer/Rows/LowerButtons/CreateServer.disabled = true
	$MarginContainer/Rows/LowerButtons/JoinServer.disabled = true
	var ip = IPText.text if IPText.text != "" else "127.0.0.1"
	var port = int(PortText.text) if PortText.text != "" else 7777
	NetworkManager.join_game(ip,port)
	waiting = true

func _on_close_pressed() -> void:
	self.hide()
	waiting = false
	NetworkManager.disconnect_game()
	
func _on_connection_ready() -> void:
	waiting = false
	get_tree().change_scene_to_file("res://main.tscn")
	
func _on_player_connected(id: int) -> void:
	if not is_inside_tree():
		return
	if id == multiplayer.get_unique_id():
		waiting = false
		get_tree().change_scene_to_file("res://main.tscn")
		
func _on_connection_failed() -> void:
	waiting = false
	$MarginContainer/Rows/LowerButtons/CreateServer.disabled = false
	$MarginContainer/Rows/LowerButtons/JoinServer.disabled = false
	
func _exit_tree() -> void:
	if NetworkManager.server_created.is_connected(_on_connection_ready):
		NetworkManager.server_created.disconnect(_on_connection_ready)
	if NetworkManager.player_connected.is_connected(_on_player_connected):
		NetworkManager.player_connected.disconnect(_on_player_connected)
	if NetworkManager.connection_failed.is_connected(_on_connection_failed):
		NetworkManager.connection_failed.disconnect(_on_connection_failed)
