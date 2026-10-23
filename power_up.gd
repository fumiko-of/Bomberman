class_name PowerUp
extends Area2D

enum Tipo { BOMBA_EXTRA, ALCANCE }

const TAM := 36
const TAM_ZONA := 32
const ALTURA_FLOTE := 4.0
const DURACION_FLOTE := 0.5
const IMAGENES := {
	Tipo.BOMBA_EXTRA: preload("res://assests/poder_bomba.png"),
	Tipo.ALCANCE: preload("res://assests/poder_alcance.png"),
}

var tipo := Tipo.BOMBA_EXTRA
var _recogido := false


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1

	var zona := RectangleShape2D.new()
	zona.size = Vector2.ONE * TAM_ZONA
	var forma := CollisionShape2D.new()
	forma.shape = zona
	add_child(forma)

	var imagen := Sprite2D.new()
	imagen.texture = IMAGENES[tipo]
	imagen.scale = Vector2.ONE * TAM / imagen.texture.get_width()
	add_child(imagen)

	var flote := create_tween().set_loops()
	flote.tween_property(imagen, "position:y", -ALTURA_FLOTE, DURACION_FLOTE)
	flote.tween_property(imagen, "position:y", ALTURA_FLOTE, DURACION_FLOTE)

	body_entered.connect(_al_tocar)


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
