class_name Bomba
extends Node2D

signal exploto

const TAM := 48
const TEX: Texture2D = preload("res://assests/Sprites.png")
const ORIGEN := Vector2(0, 64)
const TAM_FRAME := Vector2(80, 80)
const TAM_CELDA := Vector2(16, 16)
const CENTRO := Vector2(2, 2)
const DIRECCIONES: Array[Vector2] = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
const CAPA_BLOQUES := 1

@export var alcance := 1

@onready var cuerpo: StaticBody2D = $StaticBody2D

var _explotando := false


func _ready() -> void:
	$Sprite2D.play()


func _physics_process(_delta: float) -> void:
	if cuerpo.collision_layer == 0 and not _hay_jugador_encima():
		cuerpo.collision_layer = CAPA_BLOQUES


func _explotar() -> void:
	if _explotando:
		return

	_explotando = true
	set_physics_process(false)
	exploto.emit()
	Sonidos.explosion()

	var posiciones: Array[Vector2] = [global_position]
	var partes: Array[Vector2] = [CENTRO]
	_danar(_cuerpos_en(global_position))

	for dir in DIRECCIONES:
		_extender_brazo(dir, posiciones, partes)

	_activar_bombas_vecinas(posiciones)

	cuerpo.collision_layer = 0
	$Sprite2D.hide()
	await _dibujar_llamas(posiciones, partes)
	queue_free()


func _extender_brazo(dir: Vector2, posiciones: Array[Vector2], partes: Array[Vector2]) -> void:
	var ultima := -1

	for i in range(1, alcance + 1):
		var pos := global_position + dir * TAM * i
		var cuerpos := _cuerpos_en(pos)
		var caja := _buscar_caja(cuerpos)

		if caja and not caja.destructible:
			break

		posiciones.append(pos)
		partes.append(CENTRO + dir)
		ultima = posiciones.size() - 1
		_danar(cuerpos)

		if caja:
			break

	if ultima != -1:
		partes[ultima] = CENTRO + dir * 2


func _hay_jugador_encima() -> bool:
	for c in _cuerpos_en(global_position, 1.0):
		if c is Jugador:
			return true
	return false


func _buscar_caja(cuerpos: Array) -> Caja:
	for c in cuerpos:
		if c is Caja:
			return c
	return null


func _activar_bombas_vecinas(posiciones: Array[Vector2]) -> void:
	for otra: Bomba in get_tree().get_nodes_in_group("bombas"):
		for p in posiciones:
			if otra.global_position.distance_to(p) < TAM / 2.0:
				otra._explotar()
				break


func _cuerpos_en(pos: Vector2, escala := 0.8) -> Array:
	var forma := RectangleShape2D.new()
	forma.size = Vector2.ONE * TAM * escala

	var consulta := PhysicsShapeQueryParameters2D.new()
	consulta.shape = forma
	consulta.transform = Transform2D(0.0, pos)

	var cuerpos := []
	for r in get_world_2d().direct_space_state.intersect_shape(consulta):
		cuerpos.append(r.collider)
	return cuerpos


func _danar(cuerpos: Array) -> void:
	for c in cuerpos:
		if c is Caja:
			c.recibir_explosion()
		elif c is Jugador:
			c.morir()


func _dibujar_llamas(posiciones: Array[Vector2], partes: Array[Vector2]) -> void:
	var escala := Vector2.ONE * TAM / TAM_CELDA
	var sprites: Array[Sprite2D] = []

	for p in posiciones:
		var sprite := Sprite2D.new()
		sprite.texture = TEX
		sprite.region_enabled = true
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.scale = escala
		sprite.position = to_local(p)
		sprite.z_index = 5
		add_child(sprite)
		sprites.append(sprite)

	for f in 4:
		var origen := ORIGEN + Vector2(f % 2, floori(f / 2.0)) * TAM_FRAME
		for i in sprites.size():
			sprites[i].region_rect = Rect2(origen + partes[i] * TAM_CELDA, TAM_CELDA)
		await get_tree().create_timer(0.1).timeout
