extends Area2D

@export var velocidade := 400.0
@export var dano := 10
var alvo: Node2D = null

func _ready():
	area_entered.connect(_on_area_entered)

func _process(delta):
	if not is_instance_valid(alvo):
		queue_free()
		return
	var direcao = (alvo.global_position - global_position).normalized()
	global_position += direcao * velocidade * delta

func _on_area_entered(area):
	if area.is_in_group("inimigos"):
		area.get_parent().levar_dano(dano)
		queue_free()
