extends Control

func _ready():
	var b = find_child("BotaoMenu")
	if b != null:
		b.pressed.connect(_on_menu_pressed)
func _on_button_pressed():
	get_tree().change_scene_to_file("res://mapa.tscn")
func _on_menu_pressed():
	get_tree().change_scene_to_file("res://menu.tscn")
