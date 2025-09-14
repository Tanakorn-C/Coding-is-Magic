extends Node2D
 
@export var player_group : Node2D
@export var enemy_group : Node2D
@export var timeline : HBoxContainer
 
@export var options : VBoxContainer
@export var enemy_button : PackedScene
 
var sorted_array = []
var players : Array[Character]
var enemies : Array[Character]
 
func _ready():
	for player in player_group.get_children():
		players.append(player.character)
 
	for enemy in enemy_group.get_children():
		enemies.append(enemy.character)
 
		var button = enemy_button.instantiate()
		button.character = enemy.character
		%EnemySelection.add_child(button)
 
	sort_and_display()
	EvebtBus.next_attack.connect(next_attack)
 
	next_attack()
 
func sort_combined_queue():
	var player_array = []
	for player in players:
		for i in player.queue:
			player_array.append({"character" : player, "time": i})
 
	var enemy_array = []
	for enemy in enemies:
		for i in enemy.queue:
			enemy_array.append({"character" : enemy, "time": i})
 
	sorted_array = player_array
	sorted_array.append_array(enemy_array)
	sorted_array.sort_custom(sort_by_time)
 
 
func sort_by_time(a,b):
	return a["time"] < b["time"]
 
 
func update_timeline():
	var index : int = 0
	for slot in timeline.get_children():
		slot.find_child("TextureRect").texture = sorted_array[index]["character"].icon
		index += 1
 
 
func sort_and_display():
	sort_combined_queue()
	update_timeline()
	if sorted_array[0]["character"] in players:
		show_options()
 
 
func pop_out():
	sorted_array[0]["character"].pop_out()
	sort_and_display()
 
 
func attack():
	sorted_array[0]["character"].attack(get_tree())
 
 
func next_attack():
	if sorted_array[0]["character"] in players:
		return
	attack()
	pop_out()
	players.pick_random().get_attacked()
 
func set_status(status_type):
	sorted_array[0]["character"].set_status(status_type)
	sort_and_display()
 
 
func show_options():
	options.show()
	options.get_child(0).grab_focus()
 
func choose_enemy():
	%EnemySelection.show()
	%EnemySelection.get_child(0).grab_focus()
 
