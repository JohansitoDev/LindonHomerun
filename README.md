# Lindon Homerun

Prototipo de homerun para Android hecho con Godot 4.7. La interfaz completa funciona localmente como demostración; no llama a servicios, APIs ni bases de datos.

## Recorrido y juego

- La portada muestra la imagen de la liga y completa una carga de 10 segundos antes de mostrar el inicio de sesión.
- El login y la selección de equipos conservan la orientación horizontal. Puedes continuar con cualquier correo y contraseña no vacíos; no se autentica ninguna cuenta.
- Después del selector aparece el menú. Desde allí están conectados, en modo de demostración, jugar, mi equipo, tienda, ranking y ajustes.
- El botón «Regístrate» muestra un aviso local. Las compras, las estadísticas y el perfil tampoco están conectados a un servicio.
- Entra en «Jugar» para iniciar la partida de 90 segundos.
- La partida dura 90 segundos.
- Toca la pantalla cuando la pelota se acerque a la zona de bateo.
- Un contacto bien sincronizado suma un homerun.
- Un fallo consume una de las tres oportunidades; la partida tambien termina cuando se acaba el tiempo.
- La aplicación permanece en orientación horizontal.

## Arquitectura

- `src/domain`: estado de la partida y reglas independientes de la interfaz.
- `src/application`: caso de uso de la partida y puerto para obtener lanzamientos.
- `src/application/startup_flow_use_case.gd`: flujo de portada, login local, menú y pantallas de demostración.
- `src/adapters/pitch`: adaptador que produce lanzamientos aleatorios.
- `src/adapters/presentation`: presentación de las pantallas con las imágenes proporcionadas y traducción de toques a acciones.

El caso de uso depende del puerto de lanzamientos, no de su implementacion concreta. Esto permite sustituir el adaptador aleatorio por otro (por ejemplo, un modo de practica) sin cambiar las reglas del dominio.

## Verificacion

Con Godot 4.7 instalado, desde la raiz del proyecto:

```powershell
godot --headless --path . --script res://tests/test_game_rules.gd
godot --headless --path . --script res://tests/test_startup_flow.gd
godot --headless --path . --editor --quit
```

El proyecto incluye un perfil Android. Instala las plantillas de exportacion de la misma version de Godot y configura el Android SDK/JDK en Editor > Editor Settings > Export > Android. Despues exporta un APK de depuracion desde Project > Export o ejecuta:

```powershell
godot --headless --path . --export-debug Android build/android/LindonHomerun.apk
```
