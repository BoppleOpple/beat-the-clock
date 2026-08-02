extends Control

# Per-peer id: whether that player has already been told "Game Over". Keeps
# _process() from re-sending it every frame once a player is dead.
var game_over_sent: Dictionary = {}

# Whether the ROUND (not just one player's personal Game Over) has actually
# concluded - either someone won, or everyone died with nobody left to win.
# Reset by _reset() when the host restarts the game. See is_showing() and
# _broadcast_round_complete() below.
var round_complete: bool = false

# The singleplayer Game Over slow-mo tween from _show_overlay() - kept so it
# can be explicitly killed on reset (see _kill_slowmo_tween()).
var _slowmo_tween: Tween = null

func _is_ActorBase(node: Node) -> bool:
		return node is ActorBase

# True while this peer's own Game Over/Victory overlay is on screen. Used by
# Pause so it doesn't pop up on top of this overlay.
func is_showing() -> bool:
	return $UI/Modulate.visible

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$UI/Modulate.hide()
	$UI/Modulate.modulate.a = 0.0
	if _is_server_or_singleplayer():
		# A specific player's own Game Over can fire well before the round
		# actually ends (other players/enemies can still be fighting it out),
		# so the host shouldn't be able to end the round for everyone just
		# because their own run is over. Restart stays disabled until
		# _broadcast_round_complete() says the round has genuinely finished.
		$UI/Modulate/MenuButtons/Restart.disabled = true
		$UI/Modulate/MenuButtons/MainMenu.grab_focus()
	else:
		# Only the host may restart the shared game state.
		$UI/Modulate/MenuButtons/Restart.disabled = true
		$UI/Modulate/MenuButtons/Restart.visible = false
		$UI/Modulate/MenuButtons/MainMenu.grab_focus()

# Only the host/singleplayer instance decides win/loss, polling the
# replicated should_free state each frame rather than actors' local "death"
# signals (those only fire for whoever has authority, so a client would
# never learn about an enemy dying). Game Over is personal (fires the moment
# that player dies); Victory is last-one-standing across players and enemies.
func _process(_delta: float) -> void:
	if not _is_server_or_singleplayer():
		return

	var players: Array = GameManager.get_all_players()

	for p in players:
		if p.should_free:
			var id: int = p.get_multiplayer_authority()
			if not game_over_sent.get(id, false):
				game_over_sent[id] = true
				_send_game_over(id)

	if round_complete or players.is_empty():
		return

	var living_players: Array = players.filter(func(p): return not p.should_free)

	if living_players.is_empty():
		# Everyone died - the round is over even though nobody actually won.
		_broadcast_round_complete_safe()
		return

	if living_players.size() != 1:
		return

	var enemies: Array[Node] = get_tree().get_nodes_in_group("baddies").filter(_is_ActorBase)
	var living_enemies: Array = enemies.filter(func(e): return not e.should_free)
	if living_enemies.is_empty():
		_send_victory(living_players[0].get_multiplayer_authority())
		_broadcast_round_complete_safe()

func _send_game_over(id: int) -> void:
	if multiplayer.multiplayer_peer == null or id == multiplayer.get_unique_id():
		_show_game_over()
	else:
		_show_game_over.rpc_id(id)

func _send_victory(id: int) -> void:
	if multiplayer.multiplayer_peer == null or id == multiplayer.get_unique_id():
		_show_victory()
	else:
		_show_victory.rpc_id(id)

func _on_restart_pressed() -> void:
	if not _is_server_or_singleplayer():
		return  # clients cannot restart the shared game
	var main = get_tree().current_scene
	if main and main.has_method("_restart_game"):
		main._restart_game()

func _on_main_menu_pressed() -> void:
	_kill_slowmo_tween()
	Engine.time_scale = 1.0
	NetworkManager.disconnect_game()
	get_tree().change_scene_to_file("res://ui/main_menu/main_menu.tscn")

func _is_server_or_singleplayer() -> bool:
	return multiplayer.multiplayer_peer == null or multiplayer.is_server()

func _broadcast_round_complete_safe() -> void:
	if multiplayer.multiplayer_peer != null:
		_broadcast_round_complete.rpc()
	else:
		_broadcast_round_complete()

func _kill_slowmo_tween() -> void:
	if _slowmo_tween != null and _slowmo_tween.is_valid():
		_slowmo_tween.kill()
	_slowmo_tween = null

####################
#    RPC METHODS   #
####################

@rpc("authority", "call_remote", "reliable")
func _show_game_over() -> void:
	$UI/Modulate/Title.text = "Game Over"
	$UI/Modulate/Title.modulate = Color.INDIAN_RED
	_show_overlay()

@rpc("authority", "call_remote", "reliable")
func _show_victory() -> void:
	$UI/Modulate/Title.text = "Victory!"
	$UI/Modulate/Title.modulate = Color.LIME
	_show_overlay()

func _show_overlay() -> void:
	$UI/Modulate.show()
	$UI/Modulate.modulate.a = 0.0

	_kill_slowmo_tween()

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property($UI/Modulate, "modulate:a", 1.0, 1.0)
	if multiplayer.multiplayer_peer == null:
		tween.set_ignore_time_scale(true)
		tween.tween_property(Engine, "time_scale", 0.01, 1.0)
		_slowmo_tween = tween
	tween.tween_property($UI/Modulate/Title, "modulate", $UI/Modulate/Title.modulate, 0.1)

@rpc("authority", "call_local", "reliable")
func _broadcast_round_complete() -> void:
	round_complete = true
	if _is_server_or_singleplayer():
		$UI/Modulate/MenuButtons/Restart.disabled = false
		if $UI/Modulate.visible:
			$UI/Modulate/MenuButtons/Restart.grab_focus()

@rpc("authority", "call_local", "reliable")
func _reset() -> void:
	game_over_sent.clear()
	round_complete = false
	Engine.time_scale = 1.0
	get_tree().paused = false
	$UI/Modulate.hide()
	$UI/Modulate.modulate.a = 0.0
	if _is_server_or_singleplayer():
		$UI/Modulate/MenuButtons/Restart.disabled = true
