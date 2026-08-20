# 🌐 WMDA — Web Media Downloader App

<p align="center">
  <img src="https://raw.githubusercontent.com/flutter/website/master/src/assets/images/shared/brand/flutter/logo/flutter-lockup.png" width="220" alt="Flutter Logo"/>
</p>

<p align="center">
  <strong>Una aplicación multiplataforma moderna y eficiente desarrollada en Flutter para escanear sitios web y descargar contenido multimedia (imágenes y videos) con arquitectura limpia.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Architecture-Clean%20Architecture-4CAF50?style=for-the-badge" alt="Clean Architecture">
  <img src="https://img.shields.io/badge/State%20Management-Riverpod-blueviolet?style=for-the-badge" alt="Riverpod">
  <img src="https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge" alt="License">
</p>

---

## 📌 Tabla de Contenidos

- [Características](#-características)
- [Arquitectura del Proyecto](#-arquitectura-del-proyecto)
- [Estructura de Directorios](#-estructura-de-directorios)
- [Tecnologías y Dependencias](#-tecnologías-y-dependencias)
- [Requisitos Previos](#-requisitos-previos)
- [Instalación y Ejecución](#-instalación-y-ejecución)
- [Flujo de Usuario](#-flujo-de-usuario)
- [Contribución](#-contribución)
- [Licencia](#-licencia)

---

## ✨ Características

- 🔍 **Web Scraping Inteligente:** Extrae imágenes, videos y etiquetas Open Graph (`og:image`, `og:video`, Twitter Cards) desde cualquier URL web.
- ⚡ **Descarga con Streaming y Progreso:** Monitoreo en tiempo real del progreso de descarga (0% a 100%) mediante streams de HTTP.
- 📱 **Diseño Responsivo y Moderno:** Interfaz intuitiva optimizada para móviles.
- 💾 **Historial Persistente:** Guarda y administra el registro local de medios descargados.
- 🧱 **Clean Architecture:** Separación estricta de responsabilidades (Dominio, Datos, Presentación y Core), facilitando el mantenimiento y las pruebas unitarias.

---

## 🏛 Arquitectura del Proyecto

El proyecto sigue los principios de **Clean Architecture**:

```text
┌─────────────────────────────────────────────────────────┐
│                   Presentation Layer                    │
│   (Screens, Widgets Reutilizables, Riverpod Providers)  │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│                      Domain Layer                       │
│    (Entities, Use Cases, Interfaces de Repositorios)    │
└───────────────────────────▲─────────────────────────────┘
                            │
┌───────────────────────────┴─────────────────────────────┐
│                       Data Layer                        │
│    (Models/DTOs, Repositories Impl, Servicios/Scraper)  │
└─────────────────────────────────────────────────────────┘
```

---

## 📂 Estructura de Directorios

```text
lib/
├── core/                  # Utilidades globales, errores y constantes
│   ├── constants/         # Valores constantes y configuración
│   ├── errors/            # Clases de fallos y excepciones personalizadas
│   ├── theme/             # Paleta de colores, estilos y temas
│   └── utils/             # Funciones auxiliares (UrlHelper, etc.)
│
├── data/                  # Implementación de datos y APIs externas
│   ├── models/            # DTOs y serialización de datos (MediaItemModel)
│   ├── repositories/      # Implementación del MediaRepository
│   └── services/          # Scraper de HTML, extractores y servicio de descarga
│
├── domain/                # Capa central independiente (Lógica de negocio pura)
│   ├── entities/          # Entidades centrales (MediaItem, MediaType)
│   ├── repositories/      # Contratos abstractos de repositorios
│   └── usecases/          # Casos de uso (ScanUrl, DownloadMedia, GetHistory)
│
├── presentation/          # Interfaz gráfica y reactividad
│   ├── providers/         # Controladores de estado con Riverpod
│   ├── screens/           # Pantallas (Home, Scan, Selection, History)
│   └── widgets/           # Componentes visuales modulares
│
└── main.dart              # Punto de entrada de la aplicación
```

---

## 🛠 Tecnologías y Dependencias

| Paquete | Versión | Propósito |
| :--- | :---: | :--- |
| **[flutter_riverpod](https://pub.dev/packages/flutter_riverpod)** | `^2.6.1` | Gestión de estado reactiva y desacoplada |
| **[http](https://pub.dev/packages/http)** | `^1.2.0` | Cliente de peticiones HTTP para scraping y descargas |
| **[html](https://pub.dev/packages/html)** | `^0.15.4` | Parseo y manipulación del árbol DOM HTML |
| **[path_provider](https://pub.dev/packages/path_provider)** | `^2.1.2` | Acceso a directorios del sistema de archivos |
| **[shared_preferences](https://pub.dev/packages/shared_preferences)** | `^2.2.2` | Persistencia de datos locales en clave-valor |
| **[cached_network_image](https://pub.dev/packages/cached_network_image)** | `^3.3.1` | Caché eficiente de miniaturas e imágenes remotas |

---

## 📋 Requisitos Previos

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (`^3.13.0` o superior)
- [Dart SDK](https://dart.dev/get-dart) (`^3.13.0` o superior)
- Android Studio / VS Code con extensiones de Flutter/Dart configuradas.

---

## 🚀 Instalación y Ejecución

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/tu-usuario/download_multimedia.git
   cd download_multimedia
   ```

2. **Instalar dependencias:**
   ```bash
   flutter pub get
   ```

3. **Verificar el análisis estático:**
   ```bash
   flutter analyze
   ```

4. **Ejecutar la aplicación:**
   ```bash
   # Para ejecutar en un dispositivo o emulador conectado
   flutter run

   # Para ejecutar en la web
   flutter run -d chrome

   # Para ejecutar en Windows Desktop
   flutter run -d windows
   ```

---

## 📱 Flujo de Usuario

1. **Inicio (`Home`):** Muestra el historial reciente de descargas y acceso rápido al escáner.
2. **Explorador (`Scan`):** Ingreso de URL web y extracción en tiempo real de todos los archivos multimedia.
3. **Galería & Descarga (`Select & Download`):** Visualización en cuadrícula (Grid) de los medios detectados con opción de descarga y barra de progreso interactiva.
4. **Biblioteca (`History`):** Explorador de archivos descargados con opciones de previsualización y eliminación.

---

## 📄 Licencia

Distribuido bajo la Licencia **MIT**. Consulta el archivo `LICENSE` para más información.
