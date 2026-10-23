class_name Sonidos

const PONER_BOMBA := preload("res://assests/sonido_bomba.wav")
const EXPLOSION := preload("res://assests/sonido_explosion.wav")
const PODER := preload("res://assests/sonido_poder.wav")


# Crea un reproductor que se borra solo cuando termina el sonido.
# Se cuelga de la raíz para que el sonido no se corte si quien lo pidió desaparece
# (por ejemplo, el power-up se borra justo al recogerlo).
static func reproducir(desde: Node, sonido: AudioStream, volumen_db := 0.0) -> void:
	var reproductor := AudioStreamPlayer.new()
	reproductor.stream = sonido
	reproductor.volume_db = volumen_db
	reproductor.finished.connect(reproductor.queue_free)
	desde.get_tree().root.add_child(reproductor)
	reproductor.play()
