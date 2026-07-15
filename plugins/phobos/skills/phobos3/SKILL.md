---
name: phobos3
description: Construir backends y APIs REST con Phobos Framework 3 (PHP 8.4+). Úsala para crear un proyecto Phobos desde cero, agregar módulos, controllers, entidades, middleware, services o providers, y para responder dudas sobre routing, DI, query builder o entidades de Phobos (MySQL, SQLite o PostgreSQL). Actívala cuando veas mongoose-studio/phobos-framework en composer.json, clases que implementen ModuleInterface, o entidades que extiendan TableEntity.
---

# Phobos Framework 3 — forma canónica

Phobos es un framework PHP minimalista, modular (inspirado en Angular) y sin dependencias en su núcleo. **No es Laravel.** Muchos reflejos de Laravel producen código que no compila o que rompe en runtime. Esta skill define la única forma correcta de construir con él.

## Antes de escribir código

1. **Lee `references/core.md`** siempre. Es el contrato del framework: routing, módulos, DI, middleware, request/response. No escribas ni una ruta sin haberlo leído en esta sesión.
2. **Lee `references/database.md`** si la tarea toca datos (entidades, queries, transacciones).
3. **Lee `references/testing.md`** si la tarea toca tests (escribir, arreglar o correr pruebas).
4. **Lee `references/api-docs.md`** si agregas, cambias o quitas rutas: el `openapi.yaml` se actualiza en el mismo cambio.
5. **Lee `references/anti-patterns.md`** antes de dar por terminado. Es la lista de errores que se cometen una y otra vez.

Las referencias son la fuente de verdad. Si tu memoria contradice una referencia, gana la referencia.

## Versiones soportadas

| Paquete | Versión | Rol |
|---|---|---|
| `mongoose-studio/phobos-framework` | 3.3.0 | Núcleo: routing, DI, HTTP, middleware |
| `mongoose-studio/phobos-framework-database` | 3.2.1 | Query builder, entidades, transacciones, casts |
| `mongoose-studio/phobos-framework-database-mysql` | 3.2.0 | Driver MySQL / MariaDB |
| `mongoose-studio/phobos-framework-database-sqlite` | 3.2.0 | Driver SQLite (dev y tests) |
| `mongoose-studio/phobos-framework-database-postgres` | 3.2.0 | Driver PostgreSQL (schemas, JSONB, RETURNING) |

**PHP 8.4 o superior.** Todos los paquetes declaran `">=8.4"` en su `composer.json`, y el código usa sintaxis de 8.4 (`new Clase()->metodo()` sin paréntesis envolventes). En 8.3 el primer request muere con un `ParseError`. No bajes el requisito.

Los tres motores tienen driver publicado (MySQL, SQLite, PostgreSQL). Elige según el caso: MySQL/MariaDB por defecto, SQLite para desarrollo local y tests (`:memory:`), PostgreSQL cuando se necesiten schemas reales, JSONB o UUID. La capa genera SQL correcto por dialecto automáticamente.

Dependencias de terceros: solo Guzzle cuando haya que consumir HTTP externo. Nada más sin que el usuario lo pida explícitamente. Phobos existe justamente para no arrastrar un framework completo.

## Alcance: núcleo minimalista, lo demás es opcional

El núcleo **no trae, a propósito**: migraciones, validador, logger, caché, CLI ni sistema de eventos (solo el Observer para depurar). No los inventes ni los metas inline en un proyecto: eso contradice el diseño. Esas capacidades llegarán como **librerías satélite opcionales** (el desarrollador las suma si quiere; el framework no obliga) y como **Deimos**, una CLI-util aparte estilo Artisan.

En concreto, lo que esto significa para ti hoy:

- **Schema de producción (crear las tablas): fuera de alcance del framework.** El skill genera entidades y el `tests/schema.php` (solo para tests), pero **no hay migraciones**. Si el usuario pregunta cómo crear las tablas, dile la verdad: por ahora, SQL plano aplicado a mano (o su herramienta de migración preferida); una librería de migraciones / Deimos está planificada. No generes un "migrador" casero.
- **Validación de input**: valida en el service y lanza `ValidationException('...', ['campo' => 'error'])` a mano (ver `references/core.md`). No instales ni escribas un framework de validación.
- Si el usuario pide explícitamente una de estas piezas, constrúyela mínima y aislada, y déjale claro que el core no la provee.

## Modo A — proyecto nuevo

Cuando pidan "créame una API / un backend / un servicio con Phobos".

**Primero pregunta** (usa AskUserQuestion, una sola tanda):

- **Nombre y namespace**: nombre del proyecto (kebab-case, ej. `ventas-api`) y namespace PSR-4 (PascalCase, ej. `VentasApi`).
- **Base de datos**: MySQL/MariaDB, PostgreSQL, SQLite, o ninguna (API sin persistencia). Para MySQL/PostgreSQL pide host, puerto, nombre de la BD, usuario, password y el **schema** (en MySQL schema = nombre de la base; en PostgreSQL es un schema real, por defecto `public`). Para SQLite pide solo la ruta del archivo (o `:memory:`).
- **Autenticación**: ninguna por ahora / middleware propio (stub que tú completas después) / validación de token contra un servidor externo.
- **Documentación de API**: `docs/openapi.yaml` siempre se genera (es ley, no se pregunta). Lo que sí se pregunta: **¿servir Swagger UI en `/docs`?** — solo el `openapi.yaml`, o además el `DocsModule` que lo muestra en el navegador.
- **Extras**: CORS (recomendado si lo consume un frontend), Guzzle.

Con defaults sensatos si no responden: MySQL, sin auth, con CORS, y `openapi.yaml` sin Swagger UI servido.

**Luego genera** copiando desde `templates/project/`. Todos los archivos llevan placeholders `{{...}}` que debes reemplazar (`{{NAMESPACE}}`, `{{PROJECT_NAME}}`, `{{DB_DATABASE}}`, `{{PORT}}`, etc.). No dejes ningún `{{` en el resultado final.

### La base de datos se elige, no se mezcla

Cada motor tiene su propia carpeta en `templates/project/database/`, con la config completa y correcta para ese motor —claves que los otros motores ni entienden— y su bloque de `.env`. **Copia una sola carpeta**, la del motor elegido. No generes un `config/database.php` con drivers comentados: si mañana el proyecto migra de motor, se cambia el archivo entero.

| Motor elegido | Copias de | `{{DB_DRIVER_PACKAGE}}` |
|---|---|---|
| MySQL / MariaDB | `database/mysql/` | `mongoose-studio/phobos-framework-database-mysql` |
| PostgreSQL | `database/postgres/` | `mongoose-studio/phobos-framework-database-postgres` |
| SQLite | `database/sqlite/` | `mongoose-studio/phobos-framework-database-sqlite` |

De la carpeta salen dos cosas:

- `database.php.tpl` → `config/database.php`
- `env.tpl` → reemplaza el **bloque** `{{DB_ENV}}` del `.env.example` (es un placeholder de bloque: se sustituye por el contenido completo del archivo, no por una palabra).

**Si el proyecto no lleva base de datos**, entonces: quita del `composer.json` las dos líneas de `phobos-framework-database` y la de `{{DB_DRIVER_PACKAGE}}`, no generes `config/database.php`, borra el bloque `{{DB_ENV}}` del `.env.example`, y saca `DatabaseServiceProvider::class` de los `providers()` de `ApiModule`. Si lo dejas, el arranque muere con "Database configuration not found".

Notas por motor que cambian lo que generas:

- **SQLite no tiene schemas.** Las entidades van con `$schema = null` y en `app/Entities/` plano, sin subdirectorio de schema. Crea el directorio `storage/`.
- **PostgreSQL sí tiene schemas reales**, y no son la base de datos: `{{SCHEMA}}` es un schema dentro de `{{DB_DATABASE}}` (por defecto `public`).
- **MySQL**: schema y base son lo mismo, así que `{{SCHEMA}}` y `{{DB_DATABASE}}` coinciden.

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
├── docs/                        # openapi.yaml (fuente de verdad) + README
├── public/
│   ├── index.php                # punto de entrada
│   ├── .htaccess
│   └── router.php               # para el server embebido de PHP
├── tests/                       # PHPUnit: bootstrap, bases, schema, Unit/, Feature/
├── .github/workflows/ci.yml     # corre composer test en cada push/PR
├── scripts/runserver.sh
├── phpunit.xml
├── .env                         # NUNCA se commitea
├── .env.example
└── composer.json
```

**La documentación de API va en todo proyecto nuevo** (ver `references/api-docs.md`). Copia `templates/docs/` a `docs/` (quitando `.tpl`): salen `docs/openapi.yaml` (la fuente de verdad, sembrada con `/health` y el recurso de ejemplo) y `docs/README.md`. Esto es incondicional — documentar la API es ley.

Si además pidieron **servir Swagger UI**: copia `app/Modules/DocsModule.php.tpl` y móntalo en `ApiModule` con `$router->module('/docs', DocsModule::class);`. Queda en `GET /docs` (UI) y `GET /docs/openapi.yaml` (spec). Si no lo pidieron, no copies el `DocsModule`.

**El kit de tests va en todo proyecto nuevo** (ver `references/testing.md`). Copia `templates/testing/` a `tests/` (quitando `.tpl`), y `phpunit.xml.tpl` a la raíz como `phpunit.xml`. El `composer.json` ya trae `require-dev` (PHPUnit + driver SQLite), `autoload-dev` y los scripts `test`.

**CI va en todo proyecto nuevo.** Copia `templates/project/github/workflows/ci.yml.tpl` a `.github/workflows/ci.yml`. Corre `composer install` + `composer test` en cada push y PR. Es autocontenido: los tests usan SQLite `:memory:`, así que **no necesita servicios de base de datos** en el runner. ⚠️ Ese archivo usa expresiones `${{ ... }}` de GitHub Actions (con `$`) que **no** son placeholders del skill: déjalas intactas, no las reemplaces.

- Los tests corren siempre en SQLite `:memory:`, sea cual sea el motor de producción. Por eso `phobos-framework-database-sqlite` va en `require-dev`. **Si el proyecto ya es SQLite**, ese paquete está en `require`: quítalo de `require-dev` (tenerlo en ambos hace que Composer advierta "can lead to unexpected behavior").
- **Si el proyecto no lleva base de datos**, copia solo `TestCase`, `bootstrap.php`, `phpunit.xml` y los tests de `Feature/` que no toquen datos; omite `DatabaseTestCase`, `schema.php` y los ejemplos con BD.
- Ajusta `tests/schema.php` a las tablas reales, y los tests de ejemplo a tu dominio.

Al terminar: `composer install`, verifica que `GET /health` responde, y corre `composer test`. Si no puedes ejecutarlos, dilo — no afirmes que pasan sin haberlo visto.

## Modo B — agregar algo a un proyecto existente

Identifica primero el namespace y la estructura reales del proyecto (lee `composer.json` y `app/Modules/`). Adáptate a ellos; no impongas los nombres de la plantilla.

Los generadores viven en `templates/generators/`:

| Pides | Usas | Y además |
|---|---|---|
| Módulo nuevo | `module.php.tpl` + `controller.php.tpl` | Móntalo en el módulo padre con `$router->module('/prefijo', TuModule::class)`, y agrega sus rutas a `docs/openapi.yaml` |
| Controller en módulo existente | `controller.php.tpl` | Registra sus rutas en el `Module` del mismo directorio, y documéntalas en `docs/openapi.yaml` |
| Entidad | `entity.php.tpl` | Una propiedad pública por columna. Corre `composer dump-autoload` |
| Middleware | `middleware.php.tpl` | Decide su alcance: global, de módulo o de ruta |
| Service | `service.php.tpl` | Regístralo en `AppServiceProvider` |
| Provider | `provider.php.tpl` | Agrégalo al array `providers()` del módulo raíz |
| Test | `test.php.tpl` | Va en `tests/Feature/`. Si el proyecto aún no tiene `tests/`, copia primero el kit de `templates/testing/` (ver `references/testing.md`) |

Cuando agregues una entidad a un proyecto con tests, refleja su tabla en `tests/schema.php`. Al terminar cualquier cambio con lógica, corre `composer test`. Y toda ruta nueva o modificada se refleja en `docs/openapi.yaml` en el mismo cambio (ver `references/api-docs.md`).

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
| `{{DB_DRIVER_PACKAGE}}` | Paquete Composer del driver elegido | `mongoose-studio/phobos-framework-database-mysql` |
| `{{DB_ENV}}` | **Bloque**: el `env.tpl` del motor elegido, completo | (ver arriba) |
| `{{VERSION}}` | Versión de la API | `V1` |
| `{{MODULE}}` | Módulo en PascalCase | `Pedidos` |
| `{{MODULE_VAR}}` | El módulo como variable, camelCase | `pedidos` |
| `{{ROUTE_PREFIX}}` | Prefijo de ruta, kebab-case | `pedidos` |
| `{{ROUTE_NAME}}` | Prefijo de nombres de ruta | `v1.pedidos` |
| `{{TABLE}}` | Tabla en snake_case (= nombre de la clase entidad) | `pedidos` |
| `{{MIDDLEWARE}}` | Middleware en PascalCase, sin el sufijo | `Auth` |
| `{{PROVIDER}}` | Provider en PascalCase, sin el sufijo | `Storage` |

Los archivos de plantilla terminan en `.tpl` para no confundirse con código real. Al generar, quítales esa extensión: `index.php.tpl` → `index.php`, `gitignore.tpl` → `.gitignore`, `htaccess.tpl` → `.htaccess`, `.env.example.tpl` → `.env.example`, `phpunit.xml.tpl` → `phpunit.xml`. Los de `templates/testing/` van a `tests/` conservando su ruta relativa (`testing/Feature/HealthTest.php.tpl` → `tests/Feature/HealthTest.php`), salvo `phpunit.xml` que va a la raíz. Los de `templates/docs/` van a `docs/` (`openapi.yaml.tpl` → `docs/openapi.yaml`, `README.md.tpl` → `docs/README.md`). El directorio `github/` mapea al oculto `.github/` (`project/github/workflows/ci.yml.tpl` → `.github/workflows/ci.yml`).

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

- [ ] No quedó ningún placeholder `{{...}}` — incluido el bloque `{{DB_ENV}}`.
- [ ] Las rutas nuevas están montadas en la cadena de módulos que cuelga de `ApiModule`.
- [ ] Si creaste una entidad: corriste `composer dump-autoload`.
- [ ] Si usas base de datos: `DatabaseServiceProvider::class` está en `providers()` del módulo raíz, y el `config/database.php` es el **del motor elegido** (un solo driver, sin bloques comentados de otros).
- [ ] Si **no** usas base de datos: sacaste `DatabaseServiceProvider` de `providers()`.
- [ ] El `composer.lock` quedó dentro del repo (es una aplicación, no una librería).
- [ ] Hay tests: `templates/testing/` copiado, `tests/schema.php` refleja tus tablas, y `composer test` pasa (o dijiste que no pudiste correrlo).
- [ ] `docs/openapi.yaml` existe y refleja **todas** las rutas actuales (las nuevas incluidas). Si montaste `DocsModule`, `GET /docs` carga.
- [ ] `.github/workflows/ci.yml` está presente y sus expresiones `${{ }}` quedaron intactas.
- [ ] En un proyecto SQLite, quitaste el driver sqlite de `require-dev` (ya está en `require`; si no, Composer advierte).
- [ ] Revisaste `references/anti-patterns.md`.
- [ ] Probaste que el servidor levanta y que la ruta responde — o dijiste explícitamente que no pudiste probarlo.