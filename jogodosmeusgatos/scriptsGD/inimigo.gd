extends PathFollow2D

@export var velocidade := 80.0
@export var vida := 30
@export var recompensa := 10

@export_enum("Direita", "Baixo", "Esquerda", "Cima") var frente := 1


@export var textura_morto: Texture2D
@export var tempo_morto := 2.0

const ANGULOS_FRENTE := [0.0, 90.0, 180.0, -90.0]   
const VELOCIDADE_GIRO := 12.0
var barra_vida: ProgressBar
var vida_maxima: int
var sprite: Sprite2D = null
var ultima_pos := Vector2.ZERO
var primeira_vez := true
var morrendo := false

func _ready():
	rotates = false  
	loop = false
	for n in get_children():
		if n is Sprite2D:
			sprite = n
			break
	ultima_pos = global_position
	vida_maxima = vida
	barra_vida = ProgressBar.new()
	barra_vida.max_value = vida_maxima
	barra_vida.value = vida
	barra_vida.show_percentage = false
	barra_vida.custom_minimum_size = Vector2(35, 5)
	barra_vida.size = Vector2(35, 5)
	barra_vida.position = Vector2(-17.5, 20)
	barra_vida.rotation = 0
	barra_vida.z_index = 10
	add_child(barra_vida)

func _process(delta):
	ultima_pos = global_position
	progress += velocidade * delta

	if progress_ratio >= 1.0:
		GameManager.perder_vida(1)
		queue_free()
		return

	if sprite != null:
		virar_para_o_movimento(delta)

func virar_para_o_movimento(delta):
	var d = global_position - ultima_pos
	if d.length_squared() < 0.0001:
		return
	var alvo = d.angle() - deg_to_rad(ANGULOS_FRENTE[frente])
	if primeira_vez:
		sprite.rotation = alvo
		primeira_vez = false
	else:
		sprite.rotation = lerp_angle(sprite.rotation, alvo, 1.0 - exp(-VELOCIDADE_GIRO * delta))

func levar_dano(valor):
	if morrendo:
		return
	vida -= valor
	barra_vida.value = max(vida, 0)
	if vida <= 0:
		morrendo = true
		GameManager.ganhar_ouro(recompensa)
		criar_cadaver()
		queue_free()

func criar_cadaver():
	if sprite == null:
		return
	var cena = get_tree().current_scene
	var c = Sprite2D.new()
	if textura_morto != null:
		c.texture = textura_morto
	else:
		c.texture = sprite.texture
		c.modulate = Color(0.45, 0.45, 0.45, 1.0)
	c.texture_filter = sprite.texture_filter
	cena.add_child(c)
	cena.move_child(c, get_parent().get_index())  
	c.global_position = sprite.global_position
	c.global_rotation = sprite.global_rotation
	c.global_scale = sprite.global_scale

	var tw = c.create_tween()
	tw.tween_interval(tempo_morto)
	tw.tween_property(c, "modulate:a", 0.0, 0.3)
	tw.tween_callback(c.queue_free)
