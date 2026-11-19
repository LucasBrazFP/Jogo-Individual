extends Node2D

@export var inimigo_cena: PackedScene
@export var inimigo_rapido_cena: PackedScene
@export var torre_cena: PackedScene
@export var inimigo_boss_cena: PackedScene
var tipo_atual := 1
var torre_selecionada = null
var onda := 0
var inimigos_para_nascer := 0
var boss_invocado := false
var total_ondas := 5

func _ready():
	
	var musica = AudioStreamPlayer.new()
	musica.stream = load("res://musica_fundo.wav")
	musica.volume_db = -12.0
	add_child(musica)
	musica.finished.connect(musica.play)
	musica.play()
	
	GameManager.reiniciar()
	$HUD.tipo_escolhido.connect(_on_tipo_escolhido)
	$HUD.upgrade_pedido.connect(_on_upgrade_pedido)
	$HUD.marcar_tipo(tipo_atual)
	iniciar_proxima_onda()

func _on_tipo_escolhido(id):
	tipo_atual = id


func iniciar_proxima_onda():
	onda += 1
	var recompensa_wave = 50 + (onda * 10)
	GameManager.ganhar_ouro(recompensa_wave)
	inimigos_para_nascer = 3 + onda * 2
	$HUD.atualizar_onda(onda, total_ondas)
	$TimerSpawn.start()

func _on_timer_spawn_timeout():
	if inimigos_para_nascer <= 0:
		$TimerSpawn.stop()
		if onda >= total_ondas:
			esperar_vitoria()
		else:
			await get_tree().create_timer(5.0).timeout
			if is_inside_tree():
				iniciar_proxima_onda()
		return
	var inimigo
	if onda == total_ondas and inimigos_para_nascer == 1 and not boss_invocado:
		inimigo = inimigo_boss_cena.instantiate()
		boss_invocado = true
	else:
		var cena = inimigo_cena
		if onda >= 2 and inimigo_rapido_cena != null and randf() < 0.4:
			cena = inimigo_rapido_cena
		inimigo = cena.instantiate()
		inimigo.vida = int(inimigo.vida * pow(1.35, onda - 1))
	$Path2D.add_child(inimigo)
	inimigos_para_nascer -= 1

func esperar_vitoria():
	while get_tree().get_nodes_in_group("inimigos").size() > 0:
		await get_tree().create_timer(0.5).timeout
		if not is_inside_tree():
			return
	GameManager.vencer()

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			$HUD.escolher_tipo(1)
		elif event.keycode == KEY_2:
			$HUD.escolher_tipo(2)
		elif event.keycode == KEY_ESCAPE:
			selecionar_torre(null)
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			clique_esquerdo(get_global_mouse_position())
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			selecionar_torre(null)

func clique_esquerdo(pos: Vector2):
	var torre = torre_em(pos)
	if torre != null:
		selecionar_torre(torre)
		return
	if torre_selecionada != null:
		selecionar_torre(null)
		return
	tentar_construir(pos)

func torre_em(pos: Vector2):
	for t in get_tree().get_nodes_in_group("torres"):
		if pos.distance_to(t.global_position) < 30:
			return t
	return null

func selecionar_torre(torre):
	if is_instance_valid(torre_selecionada):
		torre_selecionada.selecionada = false
		torre_selecionada.queue_redraw()
	torre_selecionada = torre
	if torre != null:
		torre.selecionada = true
		torre.queue_redraw()
	$HUD.mostrar_torre(torre)

func _on_upgrade_pedido(tipo):
	if torre_selecionada == null:
		return
	if not torre_selecionada.comprar_upgrade(tipo):
		print("Sem ouro ou nível máximo")
	$HUD.mostrar_torre(torre_selecionada)

func tentar_construir(pos: Vector2):
	var dados = GameManager.tipos_torre[tipo_atual]

	if not posicao_valida(pos):
		print("Posição inválida")
		return

	if not GameManager.gastar_ouro(dados["custo"]):
		print("Sem ouro")
		return

	var torre = torre_cena.instantiate()
	add_child(torre)
	torre.global_position = pos
	torre.configurar(dados)
	torre.add_to_group("torres")

func posicao_valida(pos: Vector2) -> bool:
	var curva = $Path2D.curve
	var mais_proximo = $Path2D.to_global(curva.get_closest_point($Path2D.to_local(pos)))
	if pos.distance_to(mais_proximo) < 40:
		return false
	for t in get_tree().get_nodes_in_group("torres"):
		if pos.distance_to(t.global_position) < 50:
			return false
	return true
