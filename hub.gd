class_name Hub
extends CanvasLayer

const COLOR_J1 := Color.WHITE
const COLOR_J2 := Color(1, 0.5, 0.5)

const ICONO_BOMBA := preload("res://assests/poder_bomba.png")
const ICONO_ALCANCE := preload("res://assests/poder_alcance.png")

const TAM_ICONO := 20
const TAM_ESTADO := 14
const TAM_TITULO := 40
const TAM_DETALLE := 24
const OPACIDAD_ELIMINADO := 0.35

var _estado := HBoxContainer.new()
var _fichas := {}
var _nombres := {}
var _bombas := {}
var _alcances := {}
var _pantalla := ColorRect.new()
var _titulo: Label
var _detalle: Label


func _ready() -> void:
	_estado.position = Vector2(8, 4)
	_estado.add_theme_constant_override("separation", 28)
	add_child(_estado)

	_crear_pantalla_final()


func registrar_jugador(jugador: Jugador) -> void:
	var id := jugador.id_jugador

	var ficha := HBoxContainer.new()
	ficha.add_theme_constant_override("separation", 4)
	_estado.add_child(ficha)

	var nombre := _nueva_etiqueta(ficha, TAM_ESTADO)
	nombre.text = "J%d" % id
	nombre.modulate = COLOR_J2 if id == 2 else COLOR_J1

	_fichas[id] = ficha
	_nombres[id] = nombre
	_bombas[id] = _nuevo_contador(ficha, ICONO_BOMBA)
	_alcances[id] = _nuevo_contador(ficha, ICONO_ALCANCE)

	jugador.poderes_cambiaron.connect(_actualizar_poderes.bind(jugador))
	jugador.murio.connect(_marcar_eliminado)
	_actualizar_poderes(jugador)


func _nuevo_contador(ficha: HBoxContainer, textura: Texture2D) -> Label:
	var icono := TextureRect.new()
	icono.texture = textura
	icono.custom_minimum_size = Vector2(TAM_ICONO, TAM_ICONO)
	icono.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icono.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ficha.add_child(icono)
	return _nueva_etiqueta(ficha, TAM_ESTADO)


func _actualizar_poderes(jugador: Jugador) -> void:
	_bombas[jugador.id_jugador].text = str(jugador.max_bombas)
	_alcances[jugador.id_jugador].text = str(jugador.alcance)


func _marcar_eliminado(jugador: Jugador) -> void:
	_nombres[jugador.id_jugador].text = "J%d fuera" % jugador.id_jugador
	_fichas[jugador.id_jugador].modulate.a = OPACIDAD_ELIMINADO


func mostrar_resultado(titulo: String, detalle: String) -> void:
	_titulo.text = titulo
	_detalle.text = detalle
	_detalle.visible = detalle != ""
	_pantalla.visible = true


func _unhandled_input(event: InputEvent) -> void:
	if _pantalla.visible and event is InputEventKey and event.pressed and event.keycode == KEY_R:
		get_tree().reload_current_scene()


func _crear_pantalla_final() -> void:
	_pantalla.color = Color(0, 0, 0, 0.45)
	_pantalla.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pantalla.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pantalla.visible = false
	add_child(_pantalla)

	var centro := CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pantalla.add_child(centro)

	var columna := VBoxContainer.new()
	centro.add_child(columna)

	_titulo = _nueva_etiqueta(columna, TAM_TITULO)
	_detalle = _nueva_etiqueta(columna, TAM_DETALLE)
	_nueva_etiqueta(columna, TAM_ESTADO).text = "R para jugar de nuevo"


func _nueva_etiqueta(padre: Node, tamano: int) -> Label:
	var etiqueta := Label.new()
	etiqueta.add_theme_font_size_override("font_size", tamano)
	etiqueta.add_theme_color_override("font_outline_color", Color.BLACK)
	etiqueta.add_theme_constant_override("outline_size", 4)
	etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	padre.add_child(etiqueta)
	return etiqueta
