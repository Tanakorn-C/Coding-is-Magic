extends Node
class_name Encounter

var enemy_name := "Enemy"
var enemy_tex: Texture2D
var enemy_max_hp := 30

var return_scene_path := ""
var return_player_pos := Vector2.ZERO

func enter_battle(name: String, tex: Texture2D, max_hp: int, player_pos: Vector2) -> void:
	enemy_name = name
	enemy_tex = tex
	enemy_max_hp = max(1, max_hp)
	return_player_pos = player_pos
	return_scene_path = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file("res://scenes/battle/Battle.tscn")

func leave_battle() -> void:
	if return_scene_path != "":
		get_tree().change_scene_to_file(return_scene_path)
