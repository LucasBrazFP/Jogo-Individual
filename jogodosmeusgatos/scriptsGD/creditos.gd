
extends Control

@export var foto_superior_esquerda: Texture2D
@export var foto_meio_esquerda: Texture2D
@export var foto_inferior_esquerda: Texture2D

@export var foto_superior_direita: Texture2D
@export var foto_meio_direita: Texture2D
@export var foto_inferior_direita: Texture2D

const COR_CEU := Color("0b0e2a")
const TAMANHO_FOTO := Vector2(200, 160)
const MARGEM := 35

func _ready():
	criar_fundo()

	criar_gato(foto_superior_esquerda, Control.PRESET_TOP_LEFT, 1)
	criar_gato(foto_meio_esquerda, Control.PRESET_CENTER_LEFT, -1)
	criar_gato(foto_inferior_esquerda, Control.PRESET_BOTTOM_LEFT, 1)

	criar_gato(foto_superior_direita, Control.PRESET_TOP_RIGHT, -1)
	criar_gato(foto_meio_direita, Control.PRESET_CENTER_RIGHT, 1)
	criar_gato(foto_inferior_direita, Control.PRESET_BOTTOM_RIGHT, -1)

	find_child("Voltar").pressed.connect(_on_voltar)


func criar_fundo():
	var ceu = ColorRect.new()
	ceu.color = COR_CEU
	ceu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ceu)
	ceu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	move_child(ceu, 0)


func criar_gato(textura: Texture2D, posicao: Control.LayoutPreset, sentido: int):
	if textura == null:
		return

	var foto = TextureRect.new()
	foto.texture = textura
	foto.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	foto.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	foto.custom_minimum_size = TAMANHO_FOTO
	foto.size = TAMANHO_FOTO
	foto.pivot_offset = TAMANHO_FOTO / 2.0
	foto.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(foto)

	foto.set_anchors_and_offsets_preset(
		posicao,
		Control.PRESET_MODE_KEEP_SIZE,
		MARGEM
	)

	var giro = create_tween().set_loops()
	giro.tween_property(
		foto,
		"rotation",
		TAU * sentido,
		5.0
	).from(0.0)


func _on_voltar():
	get_tree().change_scene_to_file("res://menu.tscn")
