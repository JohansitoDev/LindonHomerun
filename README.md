# Lindon Homerun

Prototipo de homerun para Android hecho con Godot 4.7. La primera version es local y para un jugador; usa graficos vectoriales originales y no requiere cuenta ni conexion a un servidor.

## Jugar

- La partida dura 90 segundos.
- Toca la pantalla cuando la pelota se acerque a la zona de bateo.
- Un contacto bien sincronizado suma un homerun.
- Un fallo consume una de las tres oportunidades; la partida tambien termina cuando se acaba el tiempo.
- La escena esta configurada en orientacion horizontal.

## Arquitectura

- `src/domain`: estado de la partida y reglas independientes de la interfaz.
- `src/application`: caso de uso de la partida y puerto para obtener lanzamientos.
- `src/adapters/pitch`: adaptador que produce lanzamientos aleatorios.
- `src/adapters/presentation`: escena Godot que dibuja el campo y traduce toques a acciones del caso de uso.

El caso de uso depende del puerto de lanzamientos, no de su implementacion concreta. Esto permite sustituir el adaptador aleatorio por otro (por ejemplo, un modo de practica) sin cambiar las reglas del dominio.

## Verificacion

Con Godot 4.7 instalado, desde la raiz del proyecto:

```powershell
godot --headless --path . --script res://tests/test_game_rules.gd
godot --headless --path . --editor --quit
```

El proyecto incluye un perfil Android. Instala las plantillas de exportacion de la misma version de Godot y configura el Android SDK/JDK en Editor > Editor Settings > Export > Android. Despues exporta un APK de depuracion desde Project > Export o ejecuta:

```powershell
godot --headless --path . --export-debug Android build/android/LindonHomerun.apk
```
