extends CanvasLayer

signal tipo_escolhido(tipo)
signal upgrade_pedido(tipo)

var botoes_torre := {}
var botoes_up := {}
var painel: PanelContainer
var label_info: Label

func _ready():
	GameManager.ouro_mudou.connect(atualizar_ouro)
	GameManager.vida_mudou.connect(atualizar_vida)
	atualizar_ouro(GameManager.ouro)
	atualizar_vida(GameManager.vida_base)
	criar_barra_construcao()
	criar_painel_upgrade()

func atualizar_ouro(v):
	$LabelOuro.text = "Ouro: " + str(v)

func atualizar_vida(v):
	$LabelVida.text = "Vida: " + str(v)

func atualizar_onda(n, total):
	$LabelOnda.text = "Onda: %d/%d" % [n, total]

# ---------- Barra para escolher o gato ----------
func criar_barra_construcao():
	var barra = HBoxContainer.new()
	barra.mouse_filter = Control.MOUSE_FILTER_STOP
	var tela = get_viewport().get_visible_rect().size
	barra.position = Vector2(20, tela.y - 70)
	for id in GameManager.tipos_torre:
		var d = GameManager.tipos_torre[id]
		var b = Button.new()
		b.text = "%d - %s ($%d)" % [id, d["nome"], d["custo"]]
		b.toggle_mode = true
		b.pressed.connect(escolher_tipo.bind(id))
		barra.add_child(b)
		botoes_torre[id] = b
	add_child(barra)

func escolher_tipo(id):
	tipo_escolhido.emit(id)
	marcar_tipo(id)

func marcar_tipo(id):
	for k in botoes_torre:
		botoes_torre[k].button_pressed = (k == id)

# ---------- Painel de upgrade ----------
func criar_painel_upgrade():
	painel = PanelContainer.new()
	var tela = get_viewport().get_visible_rect().size
	painel.position = Vector2(tela.x - 290, 90)
	painel.custom_minimum_size = Vector2(270, 0)
	painel.visible = false
	var caixa = VBoxContainer.new()
	painel.add_child(caixa)
	label_info = Label.new()
	caixa.add_child(label_info)
	for tipo in ["alcance", "velocidade", "dano"]:
		var b = Button.new()
		b.pressed.connect(pedir_upgrade.bind(tipo))
		caixa.add_child(b)
		botoes_up[tipo] = b
	add_child(painel)

func pedir_upgrade(tipo):
	upgrade_pedido.emit(tipo)

func mostrar_torre(torre):
	if torre == null:
		painel.visible = false
		return
	painel.visible = true
	label_info.text = "%s\nDano: %d | Alcance: %d\nAtaque: %.1f tiros/s" % [torre.nome_torre, torre.dano, int(torre.alcance), torre.cadencia]
	var nomes = {"alcance": "Alcance", "velocidade": "Vel. de ataque", "dano": "Dano"}
	for tipo in botoes_up:
		var nivel = torre.nivel_de(tipo)
		var b = botoes_up[tipo]
		if nivel >= torre.MAX_NIVEL:
			b.text = "%s (MAX)" % nomes[tipo]
			b.disabled = true
		else:
			b.text = "%s  Nv %d  -  $%d" % [nomes[tipo], nivel, torre.custo_upgrade(tipo)]
			b.disabled = false
