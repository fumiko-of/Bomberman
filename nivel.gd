class_name Nivel
extends Node2D

const TILE := 48

@export var escena_dura: PackedScene
@export var escena_blanda: PackedScene
@export var escena_jugador: PackedScene
@export var escenas_poder: Array[PackedScene]
@export_range(1, 2) var num_jugadores := 2
@export_range(0.0, 1.0) var probabilidad_poder := 0.3

@onready var hub: Hub = $HUB

var mapa: Array[String] = [
	"###############",
	"#...*******...#",
	"#.#*#*#*#*#*#.#",
	"#.***********.#",
	"#*#*#*#*#*#*#*#",
	"#**.*******.**#",
	"#*#*#*#*#*#*#*#",
	"#*************#",
	"#*#*#*#*#*#*#*#",
	"#.***********.#",
	"#.#*#*#*#*#*#.#",
	"#...*******...#",
	"###############",
]

var bombas := {}
var jugadores: Array[Jugador] = []
var _terminada := false


func _ready() -> void:
	_cargar_mapa()
	_crear_jugadores()


func _cargar_mapa() -> void:
	for y in mapa.size():
		for x in mapa[y].length():
			match mapa[y][x]:
				"#":
					_crear_caja(escena_dura, Vector2i(x, y))
				"*":
					_crear_caja(escena_blanda, Vector2i(x, y))


func _crear_caja(escena: PackedScene, casilla: Vector2i) -> void:
	var caja := escena.instantiate() as Caja
	caja.position = casilla_a_posicion(casilla)
	caja.destruida.connect(_al_destruir_caja)
	add_child(caja)


func _al_destruir_caja(posicion: Vector2) -> void:
	if randf() >= probabilidad_poder:
		return

	var poder := escenas_poder.pick_random().instantiate() as PowerUp
	poder.position = posicion
	add_child.call_deferred(poder)


func hay_bomba(casilla: Vector2i) -> bool:
	return bombas.has(casilla)


func agregar_bomba(bomba: Bomba, casilla: Vector2i) -> void:
	bombas[casilla] = bomba
	bomba.exploto.connect(_quitar_bomba.bind(casilla))
	add_child(bomba)


func _quitar_bomba(casilla: Vector2i) -> void:
	bombas.erase(casilla)


func _crear_jugadores() -> void:
	_crear_jugador(1, $Inicio1.position)
	if num_jugadores == 2:
		_crear_jugador(2, $Inicio2.position)


func _crear_jugador(id: int, posicion: Vector2) -> void:
	var jugador := escena_jugador.instantiate() as Jugador
	jugador.id_jugador = id
	jugador.position = posicion
	jugador.murio.connect(_al_morir_jugador)
	add_child(jugador)
	jugadores.append(jugador)
	hub.registrar_jugador(jugador)


func _al_morir_jugador(_jugador: Jugador) -> void:
	_revisar_fin.call_deferred()


func _revisar_fin() -> void:
	if _terminada:
		return

	var vivos := 0
	var ganador: Jugador
	var perdedor: Jugador
	for jugador in jugadores:
		if jugador.vivo:
			vivos += 1
			ganador = jugador
		else:
			perdedor = jugador

	if num_jugadores == 1:
		if vivos == 0:
			_terminar("¡Perdiste!", "")
		return

	if vivos > 1:
		return

	if vivos == 0:
		_terminar("¡Empate!", "Los dos jugadores fueron eliminados")
		return

	_terminar(
		"¡Gana el Jugador %d!" % ganador.id_jugador,
		"Jugador %d: perdiste" % perdedor.id_jugador
	)


func _terminar(titulo: String, detalle: String) -> void:
	_terminada = true
	for jugador in jugadores:
		jugador.congelar()
	hub.mostrar_resultado(titulo, detalle)


func casilla_a_posicion(casilla: Vector2i) -> Vector2:
	return Vector2(casilla) * TILE + Vector2(TILE, TILE) / 2.0


func posicion_a_casilla(posicion: Vector2) -> Vector2i:
	return Vector2i(posicion / TILE)
