extends Control

@export var foto_esquerda: Texture2D
@export var foto_direita: Texture2D
@export var castelo: Texture2D

const TAMANHO_FOTO := Vector2(200, 160)   
const MARGEM := 35.0                     
const ESCALA_CASTELO := 0.85              
const COR_CEU := Color("0b0e2a")          

func _ready():
	find_child("Jogar").pressed.connect(_on_jogar)
	find_child("Creditos").pressed.connect(_on_creditos)
	find_child("Sair").pressed.connect(_on_sair)

	ajustar_interface()
	criar_fundo()
	criar_gato(foto_esquerda, true)
	criar_gato(foto_direita, false)

func ajustar_interface():
	for nome in ["Jogar", "Creditos", "Sair"]:
		var b: Button = find_child(nome)
		b.custom_minimum_size = Vector2(380, 64)
		b.add_theme_font_size_override("font_size", 28)

	var titulos = find_children("*", "Label", true, false)
	if not titulos.is_empty():
		var t: Label = titulos[0]
		t.custom_minimum_size = Vector2(640, 0)
		t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		t.add_theme_font_size_override("font_size", 44)
		t.add_theme_color_override("font_outline_color", Color.BLACK)
		t.add_theme_constant_override("outline_size", 12)

func criar_fundo():
	var posicao := 0

	var ceu = ColorRect.new()
	ceu.color = COR_CEU
	ceu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ceu)
	ceu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	move_child(ceu, posicao)
	posicao += 1

	if castelo != null:
		var img = TextureRect.new()
		img.texture = castelo
		img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		img.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(img)
		img.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		img.pivot_offset = get_viewport_rect().size / 2.0
		img.scale = Vector2(ESCALA_CASTELO, ESCALA_CASTELO)
		move_child(img, posicao)

func criar_camada_estrelas(caminho: String, velocidade: Vector2, posicao: int) -> int:
	if not ResourceLoader.exists(caminho):
		push_warning("Imagem de estrelas não encontrada: " + caminho)
		return posicao
	var camada = Sprite2D.new()
	camada.set_script(load("res://fundo_estrelas.gd"))
	camada.texture = load(caminho)
	camada.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	camada.set("velocidade", velocidade)
	add_child(camada)
	move_child(camada, posicao)
	return posicao + 1

func criar_gato(textura: Texture2D, esquerda: bool):
	if textura == null:
		return
	var foto = TextureRect.new()
	foto.texture = textura
	foto.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	foto.stretch_mode = TextureRect.STRETCH_SCALE
	foto.custom_minimum_size = TAMANHO_FOTO
	foto.size = TAMANHO_FOTO
	foto.pivot_offset = TAMANHO_FOTO / 2.0
	foto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(foto)

	var canto = Control.PRESET_TOP_LEFT if esquerda else Control.PRESET_TOP_RIGHT
	foto.set_anchors_and_offsets_preset(canto, Control.PRESET_MODE_KEEP_SIZE, int(MARGEM))

	var zoom = create_tween().set_loops()
	zoom.tween_property(foto, "scale", Vector2(1.1, 1.1), 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	zoom.tween_property(foto, "scale", Vector2(0.8, 0.8), 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	var giro = create_tween().set_loops()
	var alvo = TAU if esquerda else -TAU
	giro.tween_property(foto, "rotation", alvo, 5.0).from(0.0)
func _on_jogar():
	get_tree().change_scene_to_file("res://mapa.tscn")

func _on_creditos():
	get_tree().change_scene_to_file("res://creditos.tscn")

func _on_sair():
	get_tree().quit()
