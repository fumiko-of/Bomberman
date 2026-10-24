class_name Hub
extends CanvasLayer

const ESCENA_FICHA := preload("res://ficha.tscn")

@onready var estado: HBoxContainer = $Estado
@onready var pantalla: ColorRect = $PantallaFinal
@onready var titulo: Label = $PantallaFinal/Centro/Columna/Titulo
@onready var detalle: Label = $PantallaFinal/Centro/Columna/Detalle


func registrar_jugador(jugador: Jugador) -> void:
	var ficha := ESCENA_FICHA.instantiate() as Ficha
	estado.add_child(ficha)
	ficha.iniciar(jugador)


func mostrar_resultado(texto_titulo: String, texto_detalle: String) -> void:
	titulo.text = texto_titulo
	detalle.text = texto_detalle
	detalle.visible = texto_detalle != ""
	pantalla.visible = true


func _unhandled_input(event: InputEvent) -> void:
	if pantalla.visible and event.is_action_pressed("reiniciar"):
		get_tree().reload_current_scene()
