class_name Ficha
extends HBoxContainer

const OPACIDAD_ELIMINADO := 0.35

var jugador: Jugador

@onready var nombre: Label = $Nombre
@onready var bombas: Label = $Bombas
@onready var alcance: Label = $Alcance


func iniciar(nuevo_jugador: Jugador) -> void:
	jugador = nuevo_jugador
	nombre.text = "J%d" % jugador.id_jugador
	nombre.modulate = jugador.modulate
	jugador.poderes_cambiaron.connect(actualizar)
	jugador.murio.connect(marcar_eliminado)
	actualizar()


func actualizar() -> void:
	bombas.text = str(jugador.max_bombas)
	alcance.text = str(jugador.alcance)


func marcar_eliminado(_jugador: Jugador) -> void:
	nombre.text = "J%d fuera" % jugador.id_jugador
	modulate.a = OPACIDAD_ELIMINADO
