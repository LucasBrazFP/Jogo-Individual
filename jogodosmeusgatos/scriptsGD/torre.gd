extends Node2D

const MAX_NIVEL := 3
const VELOCIDADE_GIRO := 15.0
@export var bala_cena: PackedScene
@export var jorge_normal: Texture2D
@export var jorge_atacando: Texture2D
@export var li_normal: Texture2D
@export var li_atacando: Texture2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var timer_ataque_visual: Timer = $AttackVisualTimer

var som_tiro: AudioStreamPlayer
var pitch_base := 1.0
var imagem_normal_atual: Texture2D
var imagem_atacando_atual: Texture2D

var alvos: Array = []

var nome_torre := "Gato"
var dano := 10
var alcance := 120.0
var cadencia := 1.0

var nivel_alcance := 0
var nivel_velocidade := 0
var nivel_dano := 0

var selecionada := false


func _ready():
	sprite.scale = Vector2(0.233, 0.233)
	sprite.visible = true
	sprite.modulate = Color.WHITE

	timer_ataque_visual.one_shot = true
	timer_ataque_visual.wait_time = 0.25
	if not timer_ataque_visual.timeout.is_connected(voltar_imagem_normal):
		timer_ataque_visual.timeout.connect(voltar_imagem_normal)

	som_tiro = AudioStreamPlayer.new()
	som_tiro.stream = load("res://tiro.wav")
	som_tiro.volume_db = -6.0
	add_child(som_tiro)


func configurar(dados: Dictionary):
	nome_torre = dados["nome"]
	dano = dados["dano"]
	alcance = dados["alcance"]
	cadencia = dados["cadencia"]

	match nome_torre:
		"Gato Jorge":
			imagem_normal_atual = jorge_normal
			imagem_atacando_atual = jorge_atacando
			pitch_base = 1.15
		"Gato Li":
			imagem_normal_atual = li_normal
			imagem_atacando_atual = li_atacando
			pitch_base = 0.8
		_:
			push_error("Nome de torre não reconhecido: " + nome_torre)
			return

	if imagem_normal_atual == null or imagem_atacando_atual == null:
		push_error("Faltam imagens da torre " + nome_torre + " (veja o Inspetor)")
		return

	sprite.texture = imagem_normal_atual

	var forma = CircleShape2D.new()
	forma.radius = alcance
	$Area2D/CollisionShape2D.shape = forma

	$Timer.wait_time = 1.0 / cadencia
	queue_redraw()


func _process(delta):
	alvos = alvos.filter(func(a): return is_instance_valid(a))
	if alvos.is_empty():
		return

	# O topo da imagem aponta para o inimigo.
	# Direção.angle() considera "direita" como 0, e o topo do sprite é "cima",
	# por isso somamos PI/2 (90 graus).
	var direcao: Vector2 = alvos[0].global_position - global_position
	var angulo_alvo = direcao.angle() + PI / 2.0
	sprite.rotation = lerp_angle(sprite.rotation, angulo_alvo, 1.0 - exp(-VELOCIDADE_GIRO * delta))


func _draw():
	if selecionada:
		draw_circle(Vector2.ZERO, alcance, Color(1, 1, 1, 0.15))
		draw_arc(Vector2.ZERO, alcance, 0, TAU, 64, Color(1, 1, 1, 0.7), 2.0)


func nivel_de(tipo: String) -> int:
	match tipo:
		"alcance":
			return nivel_alcance
		"velocidade":
			return nivel_velocidade
		"dano":
			return nivel_dano
	return 0


func custo_upgrade(tipo: String) -> int:
	return 30 + nivel_de(tipo) * 30


func comprar_upgrade(tipo: String) -> bool:
	if nivel_de(tipo) >= MAX_NIVEL:
		return false
	if not GameManager.gastar_ouro(custo_upgrade(tipo)):
		return false

	match tipo:
		"alcance":
			nivel_alcance += 1
			alcance *= 1.2
			$Area2D/CollisionShape2D.shape.radius = alcance
		"velocidade":
			nivel_velocidade += 1
			cadencia *= 1.3
			$Timer.wait_time = 1.0 / cadencia
		"dano":
			nivel_dano += 1
			dano = int(dano * 1.5)

	queue_redraw()
	return true


func _on_area_2d_area_entered(area):
	if area.is_in_group("inimigos"):
		var inimigo = area.get_parent()
		if not alvos.has(inimigo):
			alvos.append(inimigo)


func _on_area_2d_area_exited(area):
	alvos.erase(area.get_parent())


func _on_timer_timeout():
	alvos = alvos.filter(func(a): return is_instance_valid(a))
	if alvos.is_empty():
		return

	var alvo = alvos[0]

	# Vira na hora para o alvo antes de atirar
	var direcao: Vector2 = alvo.global_position - global_position
	sprite.rotation = direcao.angle() + PI / 2.0

	var bala = bala_cena.instantiate()
	get_tree().current_scene.add_child(bala)
	bala.global_position = global_position
	bala.alvo = alvo
	bala.dano = dano

	
	som_tiro.pitch_scale = pitch_base + randf_range(-0.05, 0.05)
	som_tiro.play()

	sprite.texture = imagem_atacando_atual
	timer_ataque_visual.start()


func voltar_imagem_normal():
	sprite.texture = imagem_normal_atual
