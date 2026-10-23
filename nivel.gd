class_name Nivel
extends Node2D

const TILE := 48
const COLOR_PISO := Color(0.2, 0.55, 0.2)
const VOLUMEN_MUSICA := -12.0

@export var escena_dura: PackedScene
@export var escena_blanda: PackedScene
@export var escena_jugador: PackedScene
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

var cajas := {}
var bombas := {}
var jugadores: Array[Jugador] = []
var _terminada := false


func _ready() -> void:
	_cargar_mapa()
	_crear_jugadores()
	_iniciar_musica()


func _draw() -> void:
	var tamano := Vector2(mapa[0].length(), mapa.size()) * TILE
	draw_rect(Rect2(Vector2.ZERO, tamano), COLOR_PISO)


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
	add_child(caja)
	cajas[casilla] = caja
	caja.tree_exited.connect(func(): cajas.erase(casilla))
	caja.destruida.connect(_al_destruir_caja)


func _al_destruir_caja(posicion: Vector2) -> void:
	if randf() >= probabilidad_poder:
		return

	var poder := PowerUp.new()
	poder.tipo = PowerUp.Tipo.values().pick_random()
	poder.position = posicion
	add_child.call_deferred(poder)


func hay_bomba(casilla: Vector2i) -> bool:
	return bombas.has(casilla)


func agregar_bomba(bomba: Bomba, casilla: Vector2i) -> void:
	bombas[casilla] = bomba
	bomba.exploto.connect(func(): bombas.erase(casilla))
	add_child(bomba)


func _crear_jugadores() -> void:
	var inicios: Array[Vector2i] = [
		Vector2i(1, 1),
		Vector2i(mapa[0].length() - 2, mapa.size() - 2),
	]
	for i in num_jugadores:
		_crear_jugador(i + 1, inicios[i])


func _crear_jugador(id: int, casilla: Vector2i) -> void:
	var jugador := escena_jugador.instantiate() as Jugador
	jugador.id_jugador = id
	jugador.position = casilla_a_posicion(casilla)
	jugador.murio.connect(_al_morir_jugador)
	add_child(jugador)
	jugadores.append(jugador)
	hub.registrar_jugador(jugador)


func _al_morir_jugador(_jugador: Jugador) -> void:
	_revisar_fin.call_deferred()


func _revisar_fin() -> void:
	if _terminada:
		return

	var vivos := jugadores.filter(func(j: Jugador): return j.vivo)

	if num_jugadores == 1:
		if vivos.is_empty():
			_terminar("¡Perdiste!", "")
		return

	if vivos.size() > 1:
		return

	if vivos.is_empty():
		_terminar("¡Empate!", "Los dos jugadores fueron eliminados")
		return

	var ganador: Jugador = vivos[0]
	var perdedor: Jugador = jugadores.filter(func(j: Jugador): return not j.vivo)[0]
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


func _iniciar_musica() -> void:
	var stream: AudioStreamOggVorbis = load("res://assests/musica_fondo.ogg")
	stream.loop = true

	var musica := AudioStreamPlayer.new()
	musica.stream = stream
	musica.volume_db = VOLUMEN_MUSICA
	add_child(musica)
	musica.play()
