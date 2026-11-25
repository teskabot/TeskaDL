# TeskaDL

> Un menú verde terminal para bajar audio y video con **yt-dlp**, sin escribir comandos.
> Doble clic, pegás la URL, elegís formato. Listo.

Hecho por **Teska** · [TESKADEV](https://teskadev.ar) · *"Construyo lo que ofrezco"*

```
 ████████╗███████╗███████╗██╗  ██╗ █████╗     ██████╗ ██╗
 ╚══██╔══╝██╔════╝██╔════╝██║ ██╔╝██╔══██╗    ██╔══██╗██║
    ██║   █████╗  ███████╗█████╔╝ ███████║    ██║  ██║██║
    ██║   ██╔══╝  ╚════██║██╔═██╗ ██╔══██║    ██║  ██║██║
    ██║   ███████╗███████║██║  ██╗██║  ██║    ██████╔╝███████╗
    ╚═╝   ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝    ╚═════╝ ╚══════╝
```

---

## Qué es

TeskaDL es un **envoltorio (wrapper)** alrededor de [yt-dlp](https://github.com/yt-dlp/yt-dlp). No reemplaza nada: arma el comando correcto por vos, se encarga de que estén todas las herramientas y te deja el archivo en una carpeta fija.

- **Portable**: todo vive en una carpeta. No instala nada en el sistema ni pide permisos de administrador.
- **Se arma solo**: la primera vez baja lo que falte (yt-dlp, ffmpeg, Deno) a una subcarpeta `bin/`.
- **Windows y Mac** con el mismo menú.
- **Funciona con cientos de sitios**: YouTube, SoundCloud, Instagram, X, Vimeo, Bandcamp... cualquiera que soporte yt-dlp.

> **Usalo con contenido propio o con permiso.** Bajar y resubir laburo ajeno no está bueno ni suele ser legal.

---

## Contenido de la carpeta

```
TeskaDL/
├── TeskaDL.bat                      ← Windows: el programa
├── TeskaDL.command                  ← Mac: el programa
├── Crear acceso directo.bat         ← Windows: acceso en Inicio y Escritorio
├── Crear app para el Dock.command   ← Mac: crea TeskaDL.app para el Dock
├── teskaDL.ico                      ← ícono (lo usan los dos creadores de acceso)
├── LEEME.txt                        ← instrucciones cortas para quien lo recibe
├── README.md                        ← este archivo
├── LICENSE                          ← licencia MIT
└── bin/                             ← se crea solo la primera vez
    ├── yt-dlp(.exe)
    ├── ffmpeg(.exe)
    ├── ffprobe(.exe)
    └── deno(.exe)
```

---

## Instalación y uso rápido

### Windows (10 / 11, x64)

1. Descomprimí la carpeta `TeskaDL` donde quieras dejarla. **No la borres después**: ahí viven las herramientas.
2. Doble clic en **`TeskaDL.bat`**.
3. La primera vez pregunta *"¿Las descargo? [S/N]"*. Respondé `S`.
4. Si Windows muestra *"Windows protegió su PC"*: **Más información → Ejecutar de todas formas**. Pasa una sola vez.
5. Opcional: doble clic en **`Crear acceso directo.bat`** y anclalo a Inicio o a la barra de tareas.

### Mac (Apple Silicon e Intel)

1. Descomprimí la carpeta `TeskaDL`.
2. Doble clic en **`TeskaDL.command`**. macOS lo bloquea porque viene de internet y no está firmado por Apple. Es normal. Para destrabarlo **una sola vez**:
   1. En el cartel, tocá **Listo** (no "Mover a la papelera").
   2. **Ajustes del Sistema → Privacidad y seguridad**.
   3. Bajá hasta el final y tocá **Abrir de todos modos** (te pide la contraseña).
   4. Volvé a abrir `TeskaDL.command` → **Abrir de todos modos**.

   *Atajo por Terminal:* escribí `xattr -dr com.apple.quarantine ` (con el espacio al final), arrastrá la carpeta `TeskaDL` a la ventana y Enter.
3. La primera vez pregunta si baja las herramientas. Respondé `S`.
4. Para el Dock: abrí **`Crear app para el Dock.command`**. Crea `~/Applications/TeskaDL.app` con el ícono puesto. Arrastrala al Dock. macOS va a preguntar si puede controlar Terminal: aceptá.

> La primera vez en Mac puede tardar un rato: además de descargar, el script firma los binarios para que macOS no los mate en silencio.

---

## El menú

| Opción | Qué hace | Flags de yt-dlp |
|:-:|---|---|
| `1` | Audio **MP3**, mejor calidad, con tapa y metadata | `-x --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata` |
| `2` | Audio **WAV** (para el estudio, referencias, samples) | `-x --audio-format wav` |
| `3` | Video **MP4** en la mejor calidad | `-S "res,ext:mp4:m4a" --merge-output-format mp4` |
| `4` | Video **MP4** hasta 1080p | `-S "res:1080,ext:mp4:m4a" --merge-output-format mp4` |
| `5` | **Playlist** completa en MP3, numerada y en su propia carpeta | `--yes-playlist` + las flags de MP3 |
| `6` | **Disco completo** (un video con capítulos) en MP3, **un archivo por canción** | flags de MP3 + `--split-chapters` |
| `7` | **Disco completo** en WAV, un archivo por canción | `-x --audio-format wav --add-metadata --split-chapters` |
| `U` | Actualiza yt-dlp | `yt-dlp -U` |
| `A` | Abre la carpeta de descargas | — |
| `0` | Salir | — |

Cosas a saber:

- Las opciones 1 a 4, 6 y 7 usan `--no-playlist`: si pegás una URL de un video que pertenece a una lista (`...&list=...`), baja **solo ese video**. Para la lista entera, usá la opción 5.
- En la opción 1, `--audio-quality 0` es la mejor calidad **VBR** del encoder MP3. **No es CBR 320 kbps** estricto, aunque el menú lo diga así. Si necesitás calidad sin pérdida, usá WAV.
- La opción 5 guarda como `Descargas/TeskaDL/<nombre de la playlist>/01 - Título.mp3`.

### Discos completos separados por canción (opciones 6 y 7)

Para esos videos de 30-60 minutos con un disco entero dividido en **capítulos**: en vez de un archivo largo, te deja una carpeta con cada tema por separado.

```
Descargas/TeskaDL/<título del video>/
├── 01 - Primer tema.mp3
├── 02 - Segundo tema.mp3
└── ...
```

- Usa los **capítulos del video**. En YouTube salen de la barra de progreso o de los tiempos escritos en la descripción (`00:00 Tema 1`, `03:45 Tema 2`...). Si el video **no tiene capítulos**, no hay nada que cortar: te avisa y te deja el archivo entero en `Descargas/TeskaDL`. Los tiempos que aparecen solo en un comentario no cuentan.
- Cada canción queda con su **título, número de pista (`1/12`) y álbum** (el título del video) en la metadata, así se ordena bien en cualquier reproductor. En MP3 también lleva la tapa. yt-dlp, por sí solo, les deja a todas el título del video entero; TeskaDL lo corrige con ffmpeg después de cortar, sin volver a convertir el audio.
- El corte se hace sin volver a codificar (`-c copy`), así que no pierde calidad extra.
- Mientras trabaja usa una carpeta oculta `Descargas/TeskaDL/.teskadl_tmp`, y la borra al final. Si una descarga se corta a la mitad puede quedar ahí: se limpia sola la próxima vez que uses la opción 6 o 7.
- En los nombres de archivo, caracteres como `: ? / * < > |` aparecen como sus versiones "anchas" (`： ？ ⧸`), porque Windows no los permite. En la metadata (lo que muestra el reproductor) quedan normales.

### Dónde quedan los archivos

| Sistema | Carpeta |
|---|---|
| Windows | `%USERPROFILE%\Downloads\TeskaDL` |
| Mac | `~/Downloads/TeskaDL` |

Para cambiarla, editá la variable `OUT` al principio de `TeskaDL.bat` o `TeskaDL.command`.

---

## Cómo funciona por dentro

### Las tres herramientas

| Herramienta | Para qué | Por qué hace falta |
|---|---|---|
| **yt-dlp** | Hace la descarga | Es el motor |
| **ffmpeg / ffprobe** | Convierte y une audio + video | Sin ellos no hay MP3, WAV ni MP4 combinado |
| **Deno** | Runtime de JavaScript | Desde yt-dlp 2025.11.12, YouTube necesita un runtime JS externo para funcionar completo. Deno es el único habilitado por defecto |

### Flujo de arranque

1. El script agrega `bin/` al principio del `PATH` de esa sesión.
2. Chequea que existan (y, en Mac, que **realmente arranquen**) `yt-dlp`, `ffmpeg`, `ffprobe` y `deno`. Si ya los tenés instalados en el sistema (winget, brew), los usa y **no baja nada**.
3. Si falta algo, pregunta y descarga a `bin/`.
4. Muestra el menú.

### Qué descarga y de dónde

| Herramienta | Windows | Mac |
|---|---|---|
| yt-dlp | `yt-dlp/yt-dlp` releases → `yt-dlp.exe` | `yt-dlp/yt-dlp` releases → `yt-dlp_macos` |
| ffmpeg + ffprobe | [`yt-dlp/FFmpeg-Builds`](https://github.com/yt-dlp/FFmpeg-Builds) → `win64-gpl.zip` (extrae solo `ffmpeg.exe` y `ffprobe.exe`) | [ffmpeg.martin-riedl.de](https://ffmpeg.martin-riedl.de/) → build *release* (arm64 o amd64) |
| Deno | `denoland/deno` releases → `x86_64-pc-windows-msvc.zip` | `denoland/deno` releases → `aarch64` o `x86_64-apple-darwin` |

### Detalles de la versión Windows

- **No usa `tar`.** Descarga con `curl` (si no existe, cae a PowerShell `Invoke-WebRequest`) y descomprime con PowerShell (`System.IO.Compression`). Se evitó `tar.exe` porque algunas PCs no lo traen.
- Si algo falla, avisa **cuál** herramienta falló y dónde bajarla a mano.
- `[U]` actualiza `bin\yt-dlp.exe`; si no existe, intenta `winget upgrade yt-dlp.yt-dlp`.
- Si una descarga falla, el menú lo dice (no muestra "Listo" en falso).

### Detalles de la versión Mac

- Detecta Apple Silicon real (aunque la Terminal corra bajo Rosetta).
- Le saca la cuarentena (`xattr`) a toda la carpeta y **firma ad-hoc** los binarios (`codesign -s -`) para que macOS los deje correr.
- Le pasa a yt-dlp `--ffmpeg-location` explícito, para que nunca dependa de qué ffmpeg encuentre en el `PATH`.
- Si ffmpeg no arranca, muestra el error real de macOS y, si hay Homebrew, ofrece `brew install ffmpeg`.
- `Crear app para el Dock.command` arma una `.app` con `osacompile` que abre Terminal y corre el script. Convierte el ícono con `sips` + `iconutil`, borra el `Assets.car` que genera `osacompile` (le ganaba al ícono propio), re-firma la app y refresca LaunchServices.

---

## Compatibilidad

| | Estado |
|---|---|
| Windows 11 x64 | Probado: flujo completo de primera vez en una PC simulada limpia |
| Windows 10 x64 | Sin probar; debería andar (usa solo `curl`/PowerShell y `cmd`) |
| macOS Apple Silicon | Probado en uso real |
| macOS Intel | Sin probar. Ojo: el servidor de ffmpeg para Mac avisó que **deja de publicar builds *release* para Intel desde enero de 2027** |
| Linux | No soportado (los scripts son para Windows y Mac) |

---

## Problemas comunes

| Síntoma | Causa | Solución |
|---|---|---|
| El menú no abre en Mac, o "no tenés permisos" | El zip perdió el permiso de ejecución, o falta destrabar Gatekeeper | Seguí los pasos de *Abrir de todos modos*. Si persiste: `chmod +x *.command` dentro de la carpeta |
| Tarda mucho al abrir en Mac | Está firmando los binarios (deno pesa ~100 MB) | Esperá; solo pasa cuando baja o repara algo |
| `ffprobe and ffmpeg not found` | ffmpeg no está o macOS lo bloquea | Abrí `TeskaDL.command` de nuevo: detecta herramientas rotas y las repara |
| `"...tar.exe" no se reconoce` (Windows) | Versión vieja del script que dependía de `tar` | Usar esta versión: ya no usa `tar` |
| Una herramienta no se instala en Windows | Conexión, antivirus o firewall | Reintentá; si sigue, bajala a mano y copiala a `bin/` (el mensaje indica los links) |
| Opción 6/7: "Este video no tiene capítulos" | El video no tiene capítulos (ni tiempos en la descripción) | No se puede separar automáticamente; quedó el archivo entero en `Descargas/TeskaDL` |
| La descarga de YouTube falla de golpe | YouTube cambió algo | Opción **`U`** para actualizar yt-dlp. Casi siempre lo arregla |
| `"magick"` / `"winget"` no se reconoce justo después de instalar | La terminal abierta no ve el `PATH` nuevo | Cerrá y abrí una terminal nueva |
| Windows: "Windows protegió su PC" | SmartScreen con archivos de internet | Más información → Ejecutar de todas formas |

---

## Para mantener el proyecto

### Reglas que no hay que romper

- Los `.bat` van con finales de línea **CRLF**. Con LF, `cmd` se comporta raro.
- Los `.command` tienen que tener el **bit de ejecución**. Si se comprime desde Windows, el zip **no** lo conserva: armá el zip desde Mac/Linux, o repará con `chmod +x`.
- Empaquetar:
  ```bash
  chmod 644 TeskaDL/*; chmod 755 TeskaDL/*.command
  zip -r -X TeskaDL.zip TeskaDL      # el zip va sin la carpeta bin/
  ```
- El zip **no debe incluir `bin/`**: cada usuario se baja lo suyo (pesa ~460 MB en Windows).

### Cómo probar la "primera vez" sin una PC limpia

Si tu PC ya tiene yt-dlp/ffmpeg/Deno instalados, el script no entra al flujo de descarga. Para forzarlo, en una carpeta de prueba corré el `.bat` con un `PATH` reducido a las carpetas de Windows:

```bat
if exist bin rmdir /s /q bin
set "PATH=%SystemRoot%\System32;%SystemRoot%;%SystemRoot%\System32\Wbem;%SystemRoot%\System32\WindowsPowerShell\v1.0"
call TeskaDL.bat
```

> Tip: no pasar las respuestas por pipe o archivo (`< respuestas.txt`): con `set /p` se rompe y el menú queda en un loop infinito de "Opción inválida".

### Cosas pendientes

- [ ] El texto del menú dice "320" en la opción 1; en realidad es VBR calidad 0.
- [ ] Probar en Windows 10 y en Mac Intel.
- [ ] Probar una descarga real desde el menú en la última versión de Windows (se probó la instalación de herramientas, no el uso).
- [ ] Probar las opciones 6 y 7 con un disco real de YouTube, en Windows y en Mac. Se probó el corte, los nombres y la metadata sin conexión, con un video de prueba con capítulos (Windows: el `.bat` real; Mac: la misma función en bash 5, no en el bash 3.2 de macOS).

---

## Créditos y licencias

TeskaDL es solo el envoltorio. El laburo pesado lo hacen estos proyectos, cada uno con su propia licencia:

- [yt-dlp](https://github.com/yt-dlp/yt-dlp): el motor de descarga.
- [FFmpeg](https://ffmpeg.org/): conversión de audio y video. Se usan builds de [yt-dlp/FFmpeg-Builds](https://github.com/yt-dlp/FFmpeg-Builds) (Windows) y de [Martin Riedl](https://ffmpeg.martin-riedl.de/) (Mac).
- [Deno](https://deno.com/): runtime de JavaScript que necesita yt-dlp para YouTube.

### Licencia de TeskaDL

Los scripts de este proyecto (`TeskaDL.bat`, `TeskaDL.command` y los creadores de acceso directo) se distribuyen bajo la **licencia MIT**: podés usarlos, modificarlos y redistribuirlos, incluso con fines comerciales, siempre que mantengas el aviso de copyright y el texto de la licencia. Ver el archivo [`LICENSE`](LICENSE).

La licencia MIT cubre **solo** el código de TeskaDL. yt-dlp, FFmpeg y Deno **no** vienen incluidos en el zip: se descargan desde sus sitios oficiales y siguen bajo sus propias licencias.

Copyright (c) 2026 Tomás Sardelic ([TESKADEV](https://teskadev.ar)). El nombre y el logo de TESKADEV no están incluidos en la licencia.

---

<p align="center">
  <b>TESKADEV</b> · Digital Creator & Software Studio<br>
  <a href="https://teskadev.ar">teskadev.ar</a> · <a href="https://instagram.com/teskadev">@teskadev</a>
</p>
