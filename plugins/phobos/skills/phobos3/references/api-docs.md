# Documentación de API en Phobos 3

La API se documenta con **OpenAPI 3.1**, en `docs/openapi.yaml`, escrito y mantenido **a mano**. Es la fuente de verdad de la API.

## Por qué a mano y no por anotaciones

El estándar en PHP es generar el spec desde anotaciones (`zircote/swagger-php`), pero eso arrastra una dependencia pesada y llena los controllers de metadatos. Va en contra de la razón de existir de Phobos: no arrastrar medio Symfony. Un `openapi.yaml` de texto plano no cuesta dependencias, se versiona limpio, se lee sin ejecutar nada y sirve igual a Swagger UI, Redoc, Postman o un generador de clientes.

El costo es que hay que mantenerlo. Por eso es una regla del proyecto, no un extra.

## La ley: una ruta sin documentar es una ruta a medio terminar

Cada vez que agregues, cambies o elimines una ruta, **actualiza `openapi.yaml` en el mismo cambio**. No es un paso posterior ni opcional. Un `POST /v1/pedidos` que existe en el código pero no en el spec es un bug de documentación.

Esto vale también en Modo B (agregar a un proyecto existente): si el proyecto tiene `docs/openapi.yaml`, tu cambio de rutas lo toca. Si no lo tiene, créalo copiando `templates/docs/`.

## Estructura del spec

El seed (`templates/docs/openapi.yaml`) ya trae el patrón; síguelo:

- **`paths`**: un entry por ruta. Agrúpalos con `tags` por dominio. El path usa `{uuid}` (llaves de OpenAPI), aunque en Phobos la ruta se declare con `:uuid` — son notaciones distintas para lo mismo, no las confundas.
- **`components/schemas`**: define una vez el cuerpo de cada recurso y sus payloads de entrada; referéncialos con `$ref`. Marca `readOnly: true` lo que el cliente no manda (`id`, `uuid`, `created_at`, `is_active`).
- **`components/responses`**: `NotFound` (404) y `ValidationError` (422) ya están definidos con la **forma exacta** que devuelve el framework. Reúsalos con `$ref` en cada operación que pueda fallar así; no redefinas errores a mano.

### La forma de error del framework (no la inventes)

Toda `HttpException` serializa como:

```json
{ "error": "Not Found", "message": "...", "status_code": 404 }
```

y `ValidationException` (422) agrega el detalle campo → mensaje:

```json
{ "error": "Unprocessable Entity", "message": "...", "status_code": 422, "errors": { "email": "El email es requerido" } }
```

Los schemas `Error` y `ValidationError` del seed reflejan justo eso. Si documentas otra forma, mientes sobre lo que la API responde.

## Verla y validarla

- **Swagger UI online**: <https://editor.swagger.io> (pega el yaml).
- **Servida en la app**: si el proyecto montó `DocsModule`, `GET /docs` muestra Swagger UI y `GET /docs/openapi.yaml` entrega el spec. Swagger UI se carga desde CDN (necesita internet); para un entorno aislado, vendoriza el dist en `public/`.
- **Validar**: `npx @redocly/cli lint docs/openapi.yaml` antes de cerrar el cambio. Un spec inválido es peor que no tenerlo.

## DocsModule (opción "servir Swagger UI")

Es un módulo normal (`templates/project/app/Modules/DocsModule.php`) que sirve la UI y el spec. Se monta en `ApiModule`:

```php
$router->module('/docs', DocsModule::class);
```

Lee `docs/openapi.yaml` con `base_path('docs/openapi.yaml')` y lo sirve con `Content-Type: application/yaml`. Si no quieres exponer la doc en producción, envuelve el `module()` en `if (!is_prod())`.
