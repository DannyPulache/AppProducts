# IBKProducts

Aplicación iOS desarrollada con UIKit para consultar y mostrar productos del endpoint de Platzi.

## Requisitos de desarrollo

- **Xcode:** 26.6.
- **Swift:** 5.9.
- **iOS mínimo:** 15.0.
- **Validación:** iPhone 17 Pro Simulator con iOS 26.5.
- **Interfaz:** UIKit, sin SwiftUI.

## Funcionalidades

- Tab bar con las secciones **Productos** y **Menú**.
- Listado que muestra únicamente el nombre del producto.
- El endpoint llama `title` a ese dato; la capa Data lo transforma a `Product.name` para que el dominio no dependa del contrato remoto.
- Los registros sin `title`, con `title` nulo o vacío se descartan.
- Detalle con nombre, imagen, descripción, precio y categoría.
- Diseño adaptable a modo claro/oscuro y Dynamic Type.
- Selección del color del tab bar persistida con `UserDefaults`.
- Estados de carga, vacío, error y reintento.
- Pruebas unitarias para listado, paginación, mapper y preferencias.

## Paginación manual

La navegación se realiza con los botones **Anterior** y **Siguiente** ubicados debajo del listado. Cada solicitud pide 20 registros:

```text
limit = 20
offset = (página actual - 1) × 20
```

Por ejemplo, la página 1 usa `offset=0`, la página 2 usa `offset=20` y la página 3 usa `offset=40`. Como este servicio no incluye un endpoint de conteo, la app consulta `/products` sin parámetros para calcular cuántos productos tienen un `title` válido y mostrar `Página X de Y`. Aun así permite avanzar si el catálogo cambia y ese total queda desactualizado. El final real se confirma cuando la consulta paginada devuelve una página vacía; en ese caso se mantiene la última página válida y aparece el diálogo **“Ya no hay más productos que listar”**.

## Arquitectura

Se usa **MVVM** junto con separación por capas:

- **App:** composición de dependencias y navegación con Coordinator.
- **Presentation/Features:** ViewControllers UIKit y ViewModels sin lógica de red.
- **Domain:** modelos, contratos y casos de uso.
- **Data:** DTOs, mapper y repositorio que consume la API.
- **Core:** red, preferencias, formatos y constantes compartidas.

También se aplican Repository, Dependency Injection, Coordinator, Mapper y Protocol-Oriented Programming. Los componentes visuales reutilizables están aislados en el pod local `IBKUIComponents`.

## Ejecución

1. Ejecutar `pod install` en la carpeta del proyecto.
2. Abrir `IBKProducts.xcworkspace`.
3. Seleccionar el esquema `IBKProducts` y ejecutar la app o las pruebas con `⌘U`.
