extends Node

signal ouro_mudou(valor)
signal vida_mudou(valor)

var ouro := 0
var vida_base := 10
var fim := false

var tipos_torre := {
	1: {"nome": "Gato Jorge", "custo": 50, "dano": 10, "alcance": 150.0, "cadencia": 1.0, "cor": Color(0.5, 0.7, 1.0)},
	2: {"nome": "Gato Li", "custo": 100, "dano": 30, "alcance": 220.0, "cadencia": 0.5, "cor": Color(1.0, 0.6, 0.8)},
}

func reiniciar():
	ouro = 0
	vida_base = 10
	fim = false
	ouro_mudou.emit(ouro)
	vida_mudou.emit(vida_base)

func ganhar_ouro(v):
	ouro += v
	ouro_mudou.emit(ouro)

func gastar_ouro(v) -> bool:
	if ouro < v:
		return false
	ouro -= v
	ouro_mudou.emit(ouro)
	return true


func perder_vida(v):
	if fim:
		return

	vida_base -= v
	vida_mudou.emit(vida_base)

	if vida_base <= 0:
		fim = true
		await tocar_som_e_mudar_cena("res://som_derrota.wav", "res://game_over.tscn")


func vencer():
	if fim:
		return

	fim = true
	await tocar_som_e_mudar_cena("res://som_vitoria.wav", "res://vitoria.tscn")


func tocar_som_e_mudar_cena(caminho: String, cena: String):
	var audio = AudioStreamPlayer.new()
	audio.stream = load(caminho)
	add_child(audio)
	audio.play()

	await audio.finished

	get_tree().change_scene_to_file(cena)
	audio.queue_free()
