class_name PowerUp
extends Area2D

enum Tipo { BOMBA_EXTRA, ALCANCE }

@export var tipo := Tipo.BOMBA_EXTRA

var _recogido := false


func _al_tocar(cuerpo: Node2D) -> void:
	var jugador := cuerpo as Jugador
	if jugador == null or _recogido:
		return

	_recogido = true
	Sonidos.reproducir(self, Sonidos.PODER)

	if tipo == Tipo.BOMBA_EXTRA:
		jugador.aumentar_bombas()
	else:
		jugador.aumentar_alcance()

	queue_free()
