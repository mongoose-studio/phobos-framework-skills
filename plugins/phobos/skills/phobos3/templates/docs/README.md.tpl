# Documentación de {{PROJECT_TITLE}}

`openapi.yaml` es la **fuente de verdad** de esta API: un documento [OpenAPI 3.1](https://spec.openapis.org/oas/v3.1.0) escrito y mantenido a mano. No se genera desde anotaciones ni arrastra dependencias — es texto que describe la API, y se actualiza junto con las rutas.

## Regla del proyecto

Cada vez que agregues, cambies o elimines una ruta, **actualiza `openapi.yaml` en el mismo cambio**. Una ruta sin documentar es una ruta a medio terminar.

## Cómo verla

- **Swagger UI online**: pega el contenido en <https://editor.swagger.io>.
- **Redoc** (un solo comando, requiere Node): `npx @redocly/cli preview-docs docs/openapi.yaml`.
- **Servida en la app** *(si elegiste esa opción al crear el proyecto)*: levanta el servidor y abre <http://localhost:{{PORT}}/docs>.

## Cómo mantenerla

- Un `path` por ruta; agrúpalos con `tags` por dominio.
- Reutiliza: define los cuerpos y errores en `components/schemas` y referéncialos con `$ref`. El esquema `Error` y `ValidationError` ya reflejan la forma exacta que devuelve el framework.
- Valida el documento antes de dar por cerrado un cambio: `npx @redocly/cli lint docs/openapi.yaml`.
