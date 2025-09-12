extends Node2D

func _ready() -> void:
	await get_tree().process_frame
	if Encounter.return_player_pos != Vector2.ZERO:
		var p := $Player
		if p: p.global_position = Encounter.return_player_pos
		Encounter.return_player_pos = Vector2.ZERO
