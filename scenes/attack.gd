extends Button
 
 
func _on_pressed():
	owner.choose_enemy()
	get_parent().hide()
