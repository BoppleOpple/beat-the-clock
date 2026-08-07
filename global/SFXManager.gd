extends Node

const THROTTLE_WINDOW_SEC: float = 0.06
const MAX_CONCURRENT_PER_SOUND: int = 4

var _recent_start_times: Dictionary = {}  # AudioStream -> Array[float]

func try_play(player: AudioStreamPlayer, stream: AudioStream, from_position: float = 0.0, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	if stream == null or player == null:
		return

	var now := Time.get_ticks_msec() / 1000.0
	var recent: Array = _recent_start_times.get(stream, [])
	recent = recent.filter(func(t): return now - t < THROTTLE_WINDOW_SEC)

	if recent.size() >= MAX_CONCURRENT_PER_SOUND:
		_recent_start_times[stream] = recent
		return

	recent.append(now)
	_recent_start_times[stream] = recent

	var playback := player.get_stream_playback() as AudioStreamPlaybackPolyphonic
	if playback:
		playback.play_stream(stream, from_position, volume_db, pitch_scale)
