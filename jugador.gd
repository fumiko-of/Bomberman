class_name Jugador
extends CharacterBody2D

signal murio(jugador: Jugador)
signal poderes_cambiaron

const ESCENA_BOMBA := preload("res://bomba.tscn")
const COLOR_J2 := Color(1, 0.5, 0.5)
const LIMITE_BOMBAS := 6
const LIMITE_ALCANCE := 8

@export var id_jugador := 1
@export var velocidad := 150.0
@export var alcance := 1
@export var max_bombas := 1

@onready var nivel: Nivel = get_parent()
@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var forma: CollisionShape2D = $CollisionShape2D
@onready var _prefijo := "j%d_" % id_jugador

var vivo := true
var _congelado := false
var _bombas_activas := 0


func _ready() -> void:
	if id_jugador == 2:
		modulate = COLOR_J2


func _physics_process(delta: float) -> void:
	var direccion := _leer_direccion()
	velocity = direccion * velocidad
	_alinear_al_carril(direccion, delta)
	move_and_slide()
	_animar(direccion)

	if Input.is_action_just_pressed(_prefijo + "bomba"):
		_poner_bomba()


func _alinear_al_carril(direccion: Vector2, delta: float) -> void:
	if direccion == Vector2.ZERO:
		return

	var centro := nivel.casilla_a_posicion(nivel.posicion_a_casilla(position))
	var paso := velocidad * delta

	if direccion.x != 0:
		position.y = move_toward(position.y, centro.y, paso)
	else:
		position.x = move_toward(position.x, centro.x, paso)


func _poner_bomba() -> void:
	if _bombas_activas >= max_bombas:
		return

	var casilla := nivel.posicion_a_casilla(nivel.to_local(forma.global_position))
	if nivel.hay_bomba(casilla):
		return

	var bomba: Bomba = ESCENA_BOMBA.instantiate()
	bomba.alcance = alcance
	bomba.position = nivel.casilla_a_posicion(casilla)
	nivel.agregar_bomba(bomba, casilla)

	_bombas_activas += 1
	bomba.exploto.connect(_al_terminar_bomba)
	Sonidos.reproducir(self, Sonidos.PONER_BOMBA)


func _al_terminar_bomba() -> void:
	_bombas_activas -= 1


func aumentar_bombas() -> void:
	max_bombas = mini(max_bombas + 1, LIMITE_BOMBAS)
	poderes_cambiaron.emit()


func aumentar_alcance() -> void:
	alcance = mini(alcance + 1, LIMITE_ALCANCE)
	poderes_cambiaron.emit()


func morir() -> void:
	if not vivo or _congelado:
		return

	vivo = false
	velocity = Vector2.ZERO
	hide()
	forma.set_deferred("disabled", true)
	set_physics_process(false)
	murio.emit(self)


func congelar() -> void:
	_congelado = true
	velocity = Vector2.ZERO
	sprite.stop()
	set_physics_process(false)


func _animar(direccion: Vector2) -> void:
	if direccion == Vector2.ZERO:
		sprite.stop()
		sprite.frame = 0
		return

	sprite.flip_h = direccion.x < 0
	if direccion.x != 0:
		sprite.play("lado")
	elif direccion.y > 0:
		sprite.play("abajo")
	else:
		sprite.play("arriba")


func _leer_direccion() -> Vector2:
	var direccion := Input.get_vector(
		_prefijo + "izquierda", _prefijo + "derecha",
		_prefijo + "arriba", _prefijo + "abajo"
	)
	if absf(direccion.x) > absf(direccion.y):
		return Vector2(signf(direccion.x), 0)
	return Vector2(0, signf(direccion.y))
