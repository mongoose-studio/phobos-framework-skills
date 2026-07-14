---
name: phobos3
description: Construir backends y APIs REST con Phobos Framework 3 (PHP 8.4+). Úsala para crear un proyecto Phobos desde cero, agregar módulos, controllers, entidades, middleware, services o providers, y para responder dudas sobre routing, DI, query builder o entidades de Phobos (MySQL, SQLite o PostgreSQL). Actívala cuando veas mongoose-studio/phobos-framework en composer.json, clases que implementen ModuleInterface, o entidades que extiendan TableEntity.
---

# Phobos Framework 3 — forma canónica

Phobos es un framework PHP minimalista, modular (inspirado en Angular) y sin dependencias en su núcleo. **No es Laravel.** Muchos reflejos de Laravel producen código que no compila o que rompe en runtime. Esta skill define la única forma correcta de construir con él.

## Antes de escribir código

1. **Lee `references/core.md`** siempre. Es el contrato del framework: routing, módulos, DI, middleware, request/response. No escribas ni una ruta sin haberlo leído en esta sesión.
2. **Lee `references/database.md`** si la tarea toca datos (entidades, queries, transacciones).
3. **Lee `references/anti-patterns.md`** antes de dar por terminado. Es la lista de errores que se cometen una y otra vez.

Las referencias son la fuente de verdad. Si tu memoria contradice una referencia, gana la referencia.

## Versiones soportadas

| Paquete | Versión | Rol |
|---|---|---|
| `mongoose-studio/phobos-framework` | 3.2.0 | Núcleo: routing, DI, HTTP, middleware |
| `mongoose-studio/phobos-framework-database` | 3.2.0 | Query builder, entidades, transacciones, casts |
| `mongoose-studio/phobos-framework-database-mysql` | 3.2.0 | Driver MySQL / MariaDB |
| `mongoose-studio/phobos-framework-database-sqlite` | 3.2.0 | Driver SQLite (dev y tests) |
| `mongoose-studio/phobos-framework-database-postgres` | 3.2.0 | Driver PostgreSQL (schemas, JSONB, RETURNING) |

**PHP 8.4 o superior.** Todos los paquetes declaran `">=8.4"` en su `composer.json`, y el código usa sintaxis de 8.4 (`new Clase()->metodo()` sin paréntesis envolventes). En 8.3 el primer request muere con un `ParseError`. No bajes el requisito.

Los tres motores tienen driver publicado (MySQL, SQLite, PostgreSQL). Elige según el caso: MySQL/MariaDB por defecto, SQLite para desarrollo local y tests (`:memory:`), PostgreSQL cuando se necesiten schemas reales, JSONB o UUID. La capa genera SQL correcto por dialecto automáticamente.

Dependencias de terceros: solo Guzzle cuando haya que consumir HTTP externo. Nada más sin que el usuario lo pida explícitamente. Phobos existe justamente para no arrastrar un framework completo.

## Modo A — proyecto nuevo

Cuando pidan "créame una API / un backend / un servicio con Phobos".

**Primero pregunta** (usa AskUserQuestion, una sola tanda):

- **Nombre y namespace**: nombre del proyecto (kebab-case, ej. `ventas-api`) y namespace PSR-4 (PascalCase, ej. `VentasApi`).
- **Base de datos**: MySQL/MariaDB, PostgreSQL, SQLite, o ninguna (API sin persistencia). Para MySQL/PostgreSQL pide host, puerto, nombre de la BD, usuario, password y el **schema** (en MySQL schema = nombre de la base; en PostgreSQL es un schema real, por defecto `public`). Para SQLite pide solo la ruta del archivo (o `:memory:`).
- **Autenticación**: ninguna por ahora / middleware propio (stub que tú completas después) / validación de token contra un servidor externo.
- **Extras**: CORS (recomendado si lo consume un frontend), Guzzle.

Con defaults sensatos si no responden: MySQL, sin auth, con CORS.

**Luego genera** copiando desde `templates/project/`. Todos los archivos llevan placeholders `{{...}}` que debes reemplazar (`{{NAMESPACE}}`, `{{PROJECT_NAME}}`, `{{DB_DATABASE}}`, `{{PORT}}`, etc.). No dejes ningún `{{` en el resultado final.

Estructura que produces:

```
{{PROJECT_NAME}}/
├── app/
│   ├── Entities/{{SCHEMA}}/     # una clase por tabla
│   ├── Middleware/
│   ├── Modules/
│   │   ├── ApiModule.php        # módulo raíz
│   │   └── V1/                  # un subdirectorio por dominio
│   ├── Providers/
│   ├── Services/                # lógica de negocio
│   └── Utils/
├── config/                      # app.php, database.php, cors.php
├── public/
│   ├── index.php                # punto de entrada
│   ├── .htaccess
│   └── router.php               # para el server embebido de PHP
├── scripts/runserver.sh
├── .env                         # NUNCA se commitea
├── .env.example
└── composer.json
```

Al terminar: `composer install`, y verifica que `GET /health` responde. Si no puedes ejecutarlo, dilo — no afirmes que funciona sin haberlo visto.

## Modo B — agregar algo a un proyecto existente

Identifica primero el namespace y la estructura reales del proyecto (lee `composer.json` y `app/Modules/`). Adáptate a ellos; no impongas los nombres de la plantilla.

Los generadores viven en `templates/generators/`:

| Pides | Usas | Y además |
|---|---|---|
| Módulo nuevo | `module.php.tpl` + `controller.php.tpl` | Móntalo en el módulo padre con `$router->module('/prefijo', TuModule::class)` |
| Controller en módulo existente | `controller.php.tpl` | Registra sus rutas en el `Module` del mismo directorio |
| Entidad | `entity.php.tpl` | Una propiedad pública por columna. Corre `composer dump-autoload` |
| Middleware | `middleware.php.tpl` | Decide su alcance: global, de módulo o de ruta |
| Service | `service.php.tpl` | Regístralo en `AppServiceProvider` |
| Provider | `provider.php.tpl` | Agrégalo al array `providers()` del módulo raíz |

## Placeholders de las plantillas

| Placeholder | Qué es | Ejemplo |
|---|---|---|
| `{{VENDOR}}` | Vendor de Composer | `mongoose-studio` |
| `{{PROJECT_NAME}}` | Nombre del proyecto, kebab-case | `ventas-api` |
| `{{PROJECT_TITLE}}` | Nombre legible | `Ventas API` |
| `{{DESCRIPTION}}` | Descripción de una línea | `API de gestión de pedidos` |
| `{{NAMESPACE}}` | Namespace PSR-4 raíz | `VentasApi` |
| `{{PORT}}` | Puerto de desarrollo | `8080` |
| `{{SCHEMA}}` | Schema/base de datos (en MySQL son lo mismo) | `ventas` |
| `{{DB_DATABASE}}` | Nombre de la base | `ventas` |
| `{{VERSION}}` | Versión de la API | `V1` |
| `{{MODULE}}` | Módulo en PascalCase | `Pedidos` |
| `{{MODULE_VAR}}` | El módulo como variable, camelCase | `pedidos` |
| `{{ROUTE_PREFIX}}` | Prefijo de ruta, kebab-case | `pedidos` |
| `{{ROUTE_NAME}}` | Prefijo de nombres de ruta | `v1.pedidos` |
| `{{TABLE}}` | Tabla en snake_case (= nombre de la clase entidad) | `pedidos` |
| `{{MIDDLEWARE}}` | Middleware en PascalCase, sin el sufijo | `Auth` |
| `{{PROVIDER}}` | Provider en PascalCase, sin el sufijo | `Storage` |

Los archivos de plantilla terminan en `.tpl` para no confundirse con código real. Al generar, quítales esa extensión: `index.php.tpl` → `index.php`, `gitignore.tpl` → `.gitignore`, `htaccess.tpl` → `.htaccess`, `.env.example.tpl` → `.env.example`.

## Reglas de oro (no negociables)

1. **Parámetros de ruta con `:param`**, jamás `{param}`. `$router->get('/users/:id', ...)`.
2. **Un `Module` por carpeta de dominio.** Las rutas se declaran en el módulo, nunca sueltas en el módulo raíz.
3. **La lógica de negocio va en `app/Services/`.** Los controllers orquestan: leen el request, llaman a un service, devuelven la respuesta. Un controller con 200 líneas de reglas de negocio está mal.
4. **SQL siempre parametrizado**: `['columna = ?' => $valor]`. Nunca concatenes ni interpoles variables en SQL.
5. **Nunca leas `$_POST`, `$_GET` ni `$_FILES` directamente.** Usa `$request->input()`, `$request->json()`, `$request->query()`, `$request->file()`.
6. **Cortar el request es trabajo del middleware o de una excepción**, no de un `->send()` a mitad de un constructor.
7. **Nunca te tragues una excepción con un `catch` vacío.** Si no la puedes manejar, deja que suba: el entry point ya la convierte en JSON.
8. **El `.env` no se commitea nunca.** Solo `.env.example` con valores de ejemplo.
9. **PHP 8.4+**: tipos en todos los parámetros y retornos, promoted properties, enums.

## Checklist antes de entregar

- [ ] No quedó ningún placeholder `{{...}}`.
- [ ] Las rutas nuevas están montadas en la cadena de módulos que cuelga de `ApiModule`.
- [ ] Si creaste una entidad: corriste `composer dump-autoload`.
- [ ] Si usas base de datos: `DatabaseServiceProvider::class` está en `providers()` del módulo raíz.
- [ ] Revisaste `references/anti-patterns.md`.
- [ ] Probaste que el servidor levanta y que la ruta responde — o dijiste explícitamente que no pudiste probarlo.