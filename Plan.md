Aquí tienes un plan completo y detallado para el desarrollo de la aplicación **Multisave** (nombre sugerido) en Flutter y Dart.

Este plan se centra en la **arquitectura limpia**, el **mantenimiento** y la **experiencia de usuario (UX)**, dividiendo la app en capas lógicas.

---

## 1. Arquitectura General y Estructura de Carpetas

Para garantizar el mantenimiento, utilizaremos la **Arquitectura Limpia (Clean Architecture)**. Esto significa que la lógica de negocio está separada de la interfaz de usuario y la capa de datos.

La estructura de la carpeta principal `lib` será la siguiente:

```text
lib/
├── core/                  # Capa de Inferencia y Utilidades Comunes
│   ├── constants/         # Constantes (URLs base, IDs, Temas)
│   ├── errors/            # Clases personalizadas de error (ErrorCode, ErrorMessage)
│   ├── utils/             # Funciones auxiliares (formateo de fechas, validación)
│   └── theme/             # Configuración de colores y tipografías
│
├── data/                  # Capa de Datos (Repositorios y Modelos)
│   ├── models/            # Clases de datos (DTOs) para guardar la información
│   ├── repositories/      # Lógica para obtener datos de la red o base de datos
│   └── services/          # Servicios específicos (ej. scraper de HTML)
│
├── domain/                # Capa de Dominio (Reglas de negocio)
│   ├── entities/          # Entidades principales (ej. DownloadItem)
│   ├── repositories/      # Implementaciones de las interfaces de datos
│   └── usecases/          # Casos de uso (Lógica de negocio)
│
└── presentation/          # Capa de Presentación (Pantallas y Estado)
    ├── screens/           # Las pantallas de la app
    ├── widgets/           # Widgets reutilizables (botones, carruseles, etc.)
    └── providers/         # Gestión de estado (Riverpod o Bloc)
```

---

## 2. Pantallas (Screens) y Flujos de Usuario

La app se divide en 4 pantallas principales para una navegación fluida.

### Pantalla 1: Inicio (Home)
*   **Propósito:** Mostrar el historial de descargas recientes y un botón de "Nueva Búsqueda".
*   **Elementos:**
    *   Lista de archivos descargados (imagenes/videos) con miniaturas y fechas.
    *   Botón "Explorar Web" (abre la pantalla de escaneo).
*   **Mantenimiento:** La lógica de filtrado de la lista se maneja en el *Domain Layer* (Use Cases), no en la pantalla.

### Pantalla 2: Explorar / Escanear (Scan)
*   **Propósito:** La pantalla central donde el usuario ingresa una URL y la app "escanea" el contenido para encontrar multimedia.
*   **Elementos:**
    *   Campo de texto para la URL.
    *   Botón "Buscar Multimedia".
    *   **Visualización en tiempo real:** Mientras la app descarga la página, muestra un preview (vistas previas) de las imágenes y videos encontrados en la página.
    *   Botón "Seleccionar" (solo visible si se encontraron medios).
*   **Mantenimiento:** La lógica de parsing (extraer imágenes/videos de HTML) está aislada en el *Data Layer*. Si la página web cambia, solo se actualiza el *Repository*.

### Pantalla 3: Selección y Descarga (Select & Download)
*   **Propósito:** Mostrar las opciones seleccionadas por el usuario y permitir el descarga final.
*   **Elementos:**
    *   Galería de miniaturas (Grid) de los medios seleccionados.
    *   Botón grande "Descargar".
    *   Barra de progreso y mensaje de confirmación.
*   **Mantenimiento:** Esta pantalla es la interfaz de interacción. Se mantiene limpia separando la lógica de "cargar galería" de la lógica de "escritura en disco".

### Pantalla 4: Biblioteca / Historial
*   **Propósito:** Ver todos los archivos descargados de forma organizada.
*   **Elementos:**
    *   Lista de archivos (imagenes/videos) con información (Título, URL original, Fecha).
    *   Botones para "Ver Detalle" (ver el preview completo) o "Eliminar".
*   **Mantenimiento:** Usa *List Views* eficientes (LazyLoading) para no consumir memoria.

---

## 3. Capa de Datos (Data Layer)

Esta capa se encarga de la comunicación con el exterior y el almacenamiento local.

### Modelos (lib/data/models)
*   `DownloadItem`: Clase que contiene el `String` (URL original), `String` (nombre del archivo), `String` (tipo MIME - imagen/video), `DateTime` (fecha de descarga) y `String` (URL de descarga directa si es necesario).

### Repositorios (lib/data/repositories)
*   **Repository Principal:** Interfaz que define cómo se obtienen los datos.
*   **Implementación (ScraperService):** Utiliza la librería `parsley` (para parsear HTML) o `select2` para extraer URLs de imágenes y videos de la página web.
*   **Lógica de Descarga:** Utiliza `path_provider` para guardar los archivos en la carpeta de descargas de Android y `share` para compartir si es necesario.

### Servicio de Red (lib/data/services)
*   Clase `WebService` que utiliza `http` o `dio` para hacer peticiones GET a la URL proporcionada por el usuario.

---

## 4. Capa de Dominio (Domain Layer)

Aquí es donde la app se vuelve mantenible. Los desarrolladores no tocan la pantalla para cambiar reglas de negocio.

### Casos de Uso (lib/domain/usecases)
*   `getRecentDownloads()`: Obtiene la lista de archivos recientes.
*   `scanUrl(String url)`: Inicia el proceso de búsqueda en la web.
*   `downloadItem(DownloadItem item)`: Maneja la lógica de guardar el archivo en el dispositivo.

---

## 5. Gestión de Estado (Presentation Layer)

Recomendamos usar **Riverpod** o **Bloc** para gestionar el estado global de la app. Esto permite que las pantallas se actualicen automáticamente cuando cambia los datos.

### Ejemplo de flujo en Riverpod:

1.  **Inicio:** La pantalla `Home` pide el historial.
    *   *Provider:* `downloadsProvider` (inicializa con datos vacíos).
2.  **Explorar:** El usuario escribe una URL.
    *   *Provider:* `scanProvider` emite un estado `loading` -> `scanning`.
3.  **Selección:** El usuario selecciona una imagen.
    *   *Provider:* `selectionProvider` actualiza la lista de imágenes mostradas en la pantalla `Select`.
4.  **Descarga:** El usuario pulsa descargar.
    *   *Provider:* `downloadProvider` emite un estado `saving` -> `succeeded` o `failed`.

---

## 6. Detalles Técnicos y Dependencias

Para que la app funcione correctamente en Android, necesitarás estas dependencias clave en `pubspec.yaml`:

1.  **Core:**
    *   `flutter`: Framework base.
    *   `provider` o `riverpod`: Gestión de estado.
    *   `path_provider`: Para acceder a la carpeta `Downloads` de Android.
    *   `shared_preferences`: Para guardar preferencias simples (ej. última URL buscada).

2.  **Data:**
    *   `http` o `dio`: Para hacer peticiones HTTP.
    *   `parsley`: Para analizar el HTML de la página web y extraer los medios.
    *   `image_picker`: (Opcional) Si el usuario quiere seleccionar una imagen *antes* de escanear (para comparar).

3.  **Presentation:**
    *   `flutter_media_player`: Para reproducir videos descargados (opcional).
    *   `shared_preferences`: Para guardar el historial de descargas.

---

## 7. Guía de Mantenimiento (Best Practices)

Para que el código sea fácil de mantener a largo plazo:

1.  **Separación de Responsabilidades:** Nunca pongas lógica de negocio (como "si la descarga es exitosa, mostrar este botón") dentro de un widget (pantalla). Mueve esa lógica al *Domain Layer*.
2.  **Manejo de Errores:** Crea una clase `Error` con un código y un mensaje. Si la descarga falla, el usuario ve un mensaje genérico, pero los desarrolladores saben exactamente qué falló (ej. "Error de red" vs "Error de espacio en disco").
3.  **Testing:** Escribe pruebas unitarias para los *Use Cases* (Domain) y pruebas de integración para los *Repositories*.
4.  **Performance:** Usa `cached_network_image` si mostras previews de imágenes en la pantalla de exploración para que no se bloquee la app al cargar la imagen.

## Resumen del Flujo de Trabajo

1.  **Usuario** abre la app y ve la **Pantalla de Inicio**.
2.  Toca **Explorar** y escribe una URL.
3.  La pantalla **Explorar** llama al **Repository** (`scanUrl`).
4.  El **Repository** usa `WebService` para obtener la página y `Parsley` para encontrar imágenes/videos.
5.  La pantalla **Explorar** muestra las miniaturas (Previews) en tiempo real.
6.  El usuario toca una imagen y va a la pantalla **Selección**.
7.  En **Selección** se muestra una galería de miniaturas.
8.  El usuario pulsa **Descargar**.
9.  La pantalla **Biblioteca** se actualiza para mostrar el archivo descargado.

Esta estructura permite que si mañana la página web cambia su estructura, solo tienes que modificar el *Repository* (parsing), sin tocar la interfaz de usuario.