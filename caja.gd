class_name Caja
extends StaticBody2D

signal destruida(posicion: Vector2)

const TILE := 48

var destructible := false
var destruida_ya := false

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	var tamano := sprite.texture.get_size()
	if sprite.region_enabled:
		tamano = sprite.region_rect.size

	sprite.scale = Vector2(TILE, TILE) / tamano


func recibir_explosion() -> void:
	if not destructible or destruida_ya:
		return

	destruida_ya = true
	destruida.emit(position)
	queue_free()
