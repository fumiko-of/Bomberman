# Proyecto de videojuego en Godot

## Descripción del proyecto

Este proyecto fue desarrollado utilizando el motor de juego Godot. El objetivo principal fue implementar mecánicas e interactividad mediante scripts, lógica de programación y la integración de animaciones basadas en sprites.

El juego es un Bomberman hecho en Godot 4 con GDScript. Se puede jugar con 1 o 2 jugadores. Cada jugador pone bombas para romper cajas y eliminar al otro. Gana el último que quede vivo.

## Cómo jugar

- Cada jugador se mueve y pone bombas con sus propias teclas (están en el Mapa de Entrada, con los nombres que empiezan por `j1_` y `j2_`).
- Las bombas explotan en cruz y rompen las cajas blandas. Las cajas duras no se rompen.
- Algunas cajas sueltan poderes: una bomba extra o más alcance.
- Si una explosión toca a un jugador, queda eliminado.
- Al terminar la partida se oscurece la pantalla y con la tecla R se reinicia.

## Carpetas

```
assets/     imágenes y sonidos
bomba/      la bomba y su explosión
caja/       las cajas duras y blandas
jugador/    el jugador
poder/      los poderes
hud/        lo que se ve arriba (bombas y alcance) y la pantalla final
nivel/      el mapa y las reglas de la partida
sonidos/    los efectos de sonido
```

## Qué hace cada script

**nivel.gd**
Es el que arma todo. Tiene el mapa escrito como texto: `#` es una caja dura, `*` una caja blanda y `.` un espacio vacío. Recorre ese texto y va creando las cajas. También crea a los jugadores en los puntos `Inicio1` e `Inicio2`, y revisa cuándo termina la partida.

**jugador.gd**
Se encarga de mover al jugador, ponerle la animación y poner bombas. Guarda cuántas bombas puede tener y qué tan lejos llega la explosión. Cuando lo toca una explosión llama a `morir()`.

**bomba.gd**
Cuando se acaba el Timer, la bomba explota. Revisa cada dirección (arriba, abajo, izquierda y derecha) hasta donde llegue el alcance. Si encuentra una caja dura, se detiene. Si encuentra una caja blanda, la rompe y se detiene. Después dibuja las llamas con el spritesheet y se borra. Si la explosión toca otra bomba, esa también explota.

**caja.gd, caja_blanda.gd y caja_dura.gd**
`Caja` es la base. La caja blanda se destruye cuando le llega una explosión y avisa con la señal `destruida`. La caja dura hereda de `Caja` y no hace nada.

**power_up.gd**
Es el poder que se recoge. Tiene un `tipo` que se elige en el Inspector: bomba extra o alcance. Cuando un jugador lo toca, le sube esa mejora y el poder desaparece.

**hub.gd y ficha.gd**
El `Hub` es la parte de arriba de la pantalla. Por cada jugador crea una ficha que muestra su número de bombas y su alcance. Cuando un jugador muere, su ficha se pone más transparente. También muestra la pantalla final.

**sonidos.gd**
Es un Autoload con tres sonidos: poner bomba, explosión y poder. Desde cualquier script se llama con `Sonidos.explosion()`, por ejemplo.

## Uso de inteligencia artificial en el proyecto

En este proyecto utilizamos Claude (Anthropic) como herramienta de asistencia y guía durante la etapa de desarrollo. La idea fue guiarnos en la resolución de dudas, arquitectura del proyecto y animaciones de sprites.

Enlaces a las conversaciones en Claude:

- https://claude.ai/share/16f6682d-a30f-471c-9fbb-0bdae38810fd
- https://claude.ai/share/b23fb62b-f8a2-4fb3-bdf7-7d48fa3c0968
- https://claude.ai/share/991bee11-2fea-4df9-b94f-0440f007c9c5

## Aclaración sobre el historial del repositorio

Debido a un problema técnico, se borraron las versiones anteriores e historial del repositorio. Por esta razón, todo el proyecto está subido en su versión final desde una sola persona.

## Integrantes

- Paola Andrea Ramírez López
- Juan Durán
- Gina Pardo
