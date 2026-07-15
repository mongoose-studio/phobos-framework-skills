# Pruebas en Phobos 3

Verificado contra `phobos-framework` 3.3.0 y la capa de datos 3.2.0, corriendo tests reales.

Phobos no trae un framework de tests propio: se usa **PHPUnit ^11** directo. Lo que el kit de plantillas aporta es la parte que el framework hace incómoda por su cuenta — despachar requests sin servidor y aislar la base de datos — encapsulada en dos clases base.

## La idea central: se prueba por `run()`, sin servidor

El ciclo de vida completo de un request es `Phobos::run($request): Response`. Un test construye un `Request`, lo pasa por `run()` y afirma sobre el `Response`. No hay `php -S`, no hay HTTP, no hay sockets: es el mismo pipeline (middlewares, routing, controller) ejecutado en memoria. Rápido y determinista.

```php
$response = $this->get('/health');
$this->assertOk($response);
$this->assertSame('ok', $this->json($response)['status']);
```

## Las dos clases base

- **`TestCase`** — arranca la app y da los helpers de request (`get`, `postJson`, `putJson`, `patchJson`, `delete`), lectura del cuerpo (`json($response)`) y aserciones (`assertOk`, `assertStatus`). Extiéndela para tests **sin** base de datos.
- **`DatabaseTestCase extends TestCase`** — además configura SQLite `:memory:`, corre el schema una vez y envuelve cada test en una transacción que se revierte. Extiéndela cuando el test **toca datos**.

```php
class HealthTest extends TestCase { ... }          // sin BD
class PedidosTest extends DatabaseTestCase { ... }  // con BD
```

## Cinco trampas del framework que el kit ya resuelve

No las reimplementes a mano; están encapsuladas por una razón.

1. **`Request` exige sus nueve argumentos por posición** (`method, path, query, post, files, cookies, server, headers, body`). Los helpers de `TestCase` los rellenan; nunca construyas un `Request` crudo en un test.

2. **`Phobos::init()` es un singleton sin reset.** Entre test y test hay que anular la instancia por reflexión, o el segundo test reutiliza la app del primero (y sus singletons de request). Lo hace `resetApp()` en el `tearDown`.

3. **`run()` re-lanza las excepciones.** En producción es el `try/catch` de `public/index.php` el que traduce una `HttpException` (404, 422, 401...) a JSON. El helper `request()` replica esa traducción, así que los tests asertan sobre status codes como un cliente real. Las demás excepciones se dejan subir: son bugs y deben reventar el test.

4. **`CURRENT_TIMESTAMP` debe estar definida.** Las entidades la usan como valor por defecto de `created_at`, y PHP evalúa ese default al **cargar la clase**. `tests/bootstrap.php` la define igual que el entry point; sin eso, cualquier test que toque una entidad muere con "Undefined constant".

5. **El `ConnectionManager` es un singleton de proceso** y `DatabaseServiceProvider::boot()` re-fija la conexión por defecto a la de producción en cada bootstrap. `DatabaseTestCase` re-apunta el default a `testing` en cada `setUp`, y como la conexión `:memory:` queda cacheada, el schema sobrevive a todos los tests del proceso.

## Por qué los tests corren en SQLite `:memory:` (aunque produzcas en MySQL/PostgreSQL)

La capa genera SQL **por dialecto**, así que el esquema y las queries se comportan igual para lo que un test de negocio necesita comprobar. SQLite `:memory:` es instantáneo, no necesita servidor y no deja rastro. Por eso `DatabaseTestCase` configura una conexión SQLite sin importar el motor de producción — y por eso `phobos-framework-database-sqlite` va en `require-dev` aunque el proyecto sea MySQL o PostgreSQL.

**Salvedad:** SQLite no tiene schemas. Una entidad con `$schema = "ventas"` generaría SQL contra `ventas.pedidos`, que en `:memory:` no existe. `DatabaseTestCase` resuelve esto con `schemaAlias('ventas', '')`, que deja a las entidades sin calificar para que calcen con las tablas de `tests/schema.php`. Si tu proyecto usa varios schemas, agrega un `schemaAlias` por cada uno.

Si necesitas fidelidad total con el motor de producción (índices, tipos exactos, features propias de PG), escribe esos tests contra una base real vía otra conexión; para el grueso de la lógica, `:memory:` es lo correcto.

## `tests/schema.php`: el esquema de la base de test

Devuelve una lista de sentencias `CREATE TABLE` que se ejecutan una vez. Mantén una tabla por cada entidad que tus tests usen, reflejando las columnas de `app/Entities/` en el dialecto de SQLite (`INTEGER PRIMARY KEY AUTOINCREMENT`, `TEXT` para fechas/uuid, `INTEGER` para booleanos, `TEXT` para JSON). No es una migración de producción: es el mínimo que tus tests necesitan.

## Aislamiento: transacción por test

Cada test corre dentro de una transacción abierta en `setUp` y revertida en `tearDown`. Nada de lo que un test escribe llega al siguiente, y no hay que recrear tablas entre tests. Funciona aunque el código bajo prueba use `transaction()`: anida con savepoints dentro de la transacción del test, y el `rollback()` final descarta todo. El aislamiento se sostiene en cualquier orden de ejecución (reverse, random).

## Estructura

```
tests/
├── bootstrap.php          # define ROOT/APPLICATION/CURRENT_TIMESTAMP + autoload
├── TestCase.php           # base sin BD: boot + helpers de request
├── DatabaseTestCase.php   # base con BD: :memory: + schema + transacción
├── schema.php             # DDL de la base de test
├── Unit/                  # lógica aislada (services, utils)
└── Feature/               # endpoints de punta a punta por run()
phpunit.xml                # dos suites: Unit y Feature
```

`composer test` corre todo; `composer test:unit` y `composer test:feature` por suite; `composer test:coverage` genera el reporte HTML en `coverage/` (requiere Xdebug o PCOV).

## Qué va en cada suite

- **Unit** — una pieza aislada. Un service instanciado a mano (`new PedidosService()`), una utilidad pura. Si toca datos, extiende `DatabaseTestCase`; si no, `TestCase` (o `PHPUnit\Framework\TestCase` a secas para algo sin framework).
- **Feature** — un endpoint completo, por su ruta real, afirmando sobre la respuesta HTTP. Es donde se prueba que routing + middleware + controller + service + datos funcionan juntos.

## Anti-patrones

- **Construir un `Request` a mano en el test** en vez de usar los helpers: te vas a equivocar en alguno de los nueve argumentos, y el día que cambie la firma se rompe todo.
- **`expectException(NotFoundException::class)` para un 404**: el helper ya lo traduce a un `Response` 404. Aserta el status, que es lo que ve el cliente. Reserva `expectException` para errores que de verdad deban propagar.
- **No aislar y limpiar tablas a mano** (`DELETE FROM ...` en `tearDown`): frágil y lento. La transacción que revierte es el mecanismo correcto.
- **Probar contra la base de producción/desarrollo**: los tests deben poder correr en cualquier máquina sin una BD levantada. Por eso `:memory:`.
- **Un `assertTrue(true)` o un test sin aserciones** para que "pase": PHPUnit está configurado con `failOnRisky`, así que un test sin aserciones es un fallo. Bien.
