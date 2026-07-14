# Anti-patrones

Cada punto es un error visto en código real de Phobos. Revísalos antes de dar una tarea por terminada.

## Routing

**`{id}` en vez de `:id`.** El reflejo de Laravel. La ruta simplemente nunca matchea y te vas a pasar veinte minutos buscando el bug en el controller.

```php
$router->get('/pedidos/{id}', ...);   // ✗ nunca matchea
$router->get('/pedidos/:id', ...);    // ✓
```

**Rutas genéricas antes que específicas.** Se evalúan en orden de registro; la primera que matchea gana.

```php
$router->get('/pedidos/:id', ...);       // ✗ se come '/pedidos/nuevo': $id = 'nuevo'
$router->get('/pedidos/nuevo', ...);
```

Primero las literales, después las paramétricas, y el `all('/**')` al final de todo.

**Rutas sueltas en el módulo raíz.** `ApiModule` monta módulos y declara `/health`. Nada más. Si le cuelgas rutas de negocio, en seis meses tiene doscientas líneas y nadie encuentra nada.

## Controllers

**Cortar el request desde el constructor.**

```php
public function __construct(private AuthContext $auth) {
    if (!$this->auth->isAuthenticated()) {
        response()->error("Unauthorized", 401)->send();   // ✗ manda headers y SIGUE ejecutando
    }
}
```

`send()` escribe la respuesta pero no detiene nada: el método del controller se ejecuta igual, con un usuario no autenticado y probablemente un fatal después. La autenticación **es trabajo del middleware**. Si de verdad necesitas cortar desde dentro, lanza `throw new UnauthorizedException(...)`.

**Leer los superglobales.**

```php
$data = json_decode($_POST['data']);   // ✗
$data = $request->input('data');       // ✓
$json = $request->json();              // ✓ body JSON completo
$file = $request->file('foto');        // ✓
```

Saltarse el `Request` rompe los tests, ignora el parseo del framework y hace que el mismo endpoint se comporte distinto según cómo llegue el body.

**Tratar `$request->json()` como array cuando el body es un objeto.** Un body JSON `{...}` se decodifica a `stdClass`.

```php
$data = $request->json();
$data['codigo'];                      // ✗ fatal: no se puede indexar un stdClass
$data->codigo ?? null;                // ✓
public function create(array $data)   // ✗ TypeError: se le pasa un stdClass
public function create(object $data)  // ✓
```

**Lógica de negocio en el controller.** Si el método arma queries, aplica reglas y persiste en tres tablas, eso es un service. El controller lee el request, llama al service y devuelve. Nada más.

**Envolver todo en `try { ... } catch (Throwable $th) { return response()->json(['error' => $th->getMessage()], 500); }`.** Convierte cualquier bug en un 500 con el mensaje crudo hacia afuera (fuga de información), y borra el stack trace. Deja que la excepción suba: el entry point ya la maneja y respeta `APP_DEBUG`. Solo captura cuando de verdad vas a *hacer* algo con el error.

## Base de datos

**Olvidar `DatabaseServiceProvider`.** Sin él en los `providers()` del módulo raíz, el primer `query()` muere con "Database configuration not found". Es el error número uno al empezar un proyecto.

**Olvidar `composer dump-autoload` después de crear una entidad.** "Class not found" en una clase que estás viendo en el editor.

**Paginar con `find($where, $order, $desde, $hasta)`.** Los parámetros 3 y 4 son **limit** y **offset**, en ese orden — no "desde/hasta". `find($w, $o, 0, 20)` produce `LIMIT 0` y devuelve `[]` sin lanzar nada: parece que la tabla está vacía. Lo correcto es `find($w, $o, $perPage, ($page - 1) * $perPage)`.

**Interpolar variables en SQL.**

```php
->where(["nombre = '$nombre'"])        // ✗ inyección SQL
->where(['nombre = ?' => $nombre])     // ✓
```

**Tabla como string literal.**

```php
->from('ventas.pedidos', 'p')                    // ✗ se rompe si cambia el schema
->from(pedidos::getIdentification(), 'p')        // ✓
```

**Tragarse el commit.**

```php
try { commit(); } catch (Throwable $th) {}   // ✗ si el commit falla, nadie se entera
```

Un `catch` vacío convierte "los datos no se guardaron" en "la API respondió 200". Usa el helper `transaction(fn)`: commitea o revierte, y no te deja mentir.

**Borrado físico donde se espera soft delete.** Si la tabla tiene `is_active` / `deleted_at`, `remove()` es casi siempre un error: rompe históricos y referencias. Marca, no borres.

**Leer sin filtrar los borrados.** Si usas soft delete, toda lectura lleva `['is_active = ?' => 1]`. Si no, los registros "eliminados" reaparecen.

## Dependencias

**`inject()` dentro del constructor en vez de inyección por constructor.**

```php
public function __construct() {
    $this->sso = inject(SSOService::class);   // ✗ dependencia oculta, imposible de mockear
}

public function __construct(private SSOService $sso) {}   // ✓ el autowiring ya lo resuelve
```

**Instalar librerías porque sí.** Phobos existe para no arrastrar medio Symfony. Guzzle si hay que hablar HTTP hacia afuera; el resto se pregunta antes.

## Configuración

**Commitear el `.env`.** Va en `.gitignore` siempre. Se comparte `.env.example` con valores de ejemplo, nunca con credenciales reales.

**`env()` regado por todo el código.** El `.env` alimenta a `config/`; el código lee `config('database.connections.main.host')`. Así un solo archivo describe la configuración y se puede sobreescribir en tiempo de ejecución.

## PHP

**Tipos faltantes.** PHP 8.4: tipos en todos los parámetros y retornos. Sin `mixed` salvo que no haya alternativa (ej: una propiedad casteada con `$casts`).

**Código comentado.** Bórralo. Para eso está git.