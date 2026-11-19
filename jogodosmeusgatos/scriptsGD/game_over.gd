
extends Control

const COR_CEU := Color("0b0e2a")

func _ready():
	criar_fundo()
	$CenterContainer/VBoxContainer/Again.pressed.connect(_on_tentar_novamente)
	$CenterContainer/VBoxContainer/BotaoMenu.pressed.connect(_on_voltar_menu)
	
func _on_tentar_novamente():
	get_tree().change_scene_to_file("res://mapa.tscn")

func _on_voltar_menu():
	get_tree().change_scene_to_file("res://menu.tscn")

func criar_fundo():
	var ceu = ColorRect.new()
	ceu.color = COR_CEU
	ceu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ceu)
	ceu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	move_child(ceu, 0)
