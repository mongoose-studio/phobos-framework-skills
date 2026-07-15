# Núcleo de Phobos 3 — contrato del framework

Todo lo que sigue está verificado contra el código fuente de `mongoose-studio/phobos-framework` 3.2.0. Namespace raíz: `PhobosFramework\`.

## Ciclo de vida

El entry point es `public/index.php` y siempre tiene esta forma:

```php
<?php
define('ROOT', realpath(dirname(__DIR__)));
define('APPLICATION', dirname(__DIR__) . '/app');
define('CURRENT_TIMESTAMP', date('Y-m-d H:i:s'));

require_once dirname(__DIR__) . '/vendor/autoload.php';

use App\Modules\ApiModule;
use PhobosFramework\Core\Phobos;

Phobos::init(ROOT, APPLICATION)   // raíz del proyecto, y el dir de la app
    ->loadEnvironment()           // lee ROOT/.env
    ->loadConfig()                // lee ROOT/config
    ->middleware(CorsMiddleware::class)  // opcional: middlewares globales
    ->bootstrap(ApiModule::class)        // módulo raíz
    ->run()
    ->send();
```

`Phobos::init($basePath, $appPath = null)` recibe la **raíz** del proyecto como primer argumento (ahí viven `.env`, `config/`, `storage/`, `public/`). El segundo es el directorio de la app; si lo omites, se asume `ROOT/app`. Así `base_path()` es la raíz, `config_path()` es `ROOT/config`, `app_path()` es el dir de la app, sin derivaciones mágicas.

> Si te topas con un entry point viejo que hace `Phobos::init(APPLICATION)` (pasando el dir `app/`), cámbialo a `Phobos::init(ROOT, APPLICATION)`. El framework detecta ese patrón y lanza un error claro con la instrucción (y lo escribe al log), no falla en silencio.

**Phobos no trae manejador global de errores.** `run()` re-lanza cualquier excepción. Por eso el entry point real envuelve la cadena en un `try/catch` que traduce excepciones a JSON. Está en `templates/project/public/index.php.tpl` — cópialo tal cual.

Orden de arranque de `bootstrap()`: registra los providers del módulo → hace `boot()` de todos → registra middlewares del módulo → registra rutas.

## Módulos

```php
use PhobosFramework\Module\ModuleInterface;
use PhobosFramework\Routing\Router;

class VentasModule implements ModuleInterface {
    public function routes(Router $router): void { /* rutas */ }
    public function middlewares(): array { return []; }  // aplican a TODAS las rutas del módulo
    public function providers(): array { return []; }    // solo el módulo raíz suele declarar providers
}
```

Los módulos se anidan con `$router->module('/prefijo', OtroModule::class)`. Así se arma el árbol de rutas: `ApiModule` → `/v1` → `VentasModule` → `/pedidos`.

Los `providers()` de un módulo anidado **no** se registran: solo se procesan los del módulo pasado a `bootstrap()`. Declara todos tus providers en el módulo raíz.

## Routing

```php
$router->get('/pedidos', [PedidosController::class, 'list'])->name('v1.pedidos.list');
$router->post('/pedidos', [PedidosController::class, 'create']);
$router->put('/pedidos/:id', [PedidosController::class, 'update']);
$router->patch('/pedidos/:id/estado', [PedidosController::class, 'updateEstado']);
$router->delete('/pedidos/:id', [PedidosController::class, 'delete']);
$router->all('/**', fn() => throw new NotFoundException('Route not found'));  // catch-all, siempre al final

$router->group(['prefix' => '/v1', 'middleware' => AuthMiddleware::class], function (Router $router) {
    $router->module('/ventas', VentasModule::class);
});
```

Métodos disponibles: `get`, `post`, `put`, `delete`, `patch`, `options`, `all`, `multi(array $methods, ...)`.

- **Parámetros: `:id`**, con dos puntos. `{id}` no funciona.
- **Wildcards**: `*` = un segmento; `**` = todos los que queden. Sus valores llegan como `segment_0`, `segment_1`, `wildcard`.
- Las rutas se evalúan **en orden de registro**. La ruta específica va antes que la genérica: `/pedidos/nuevo` antes que `/pedidos/:id`, o `:id` se comerá `nuevo`.
- `->name()` permite generar URLs con el helper `route('v1.pedidos.list', ['id' => 5])`.

## Controllers

Clases planas, sin clase base. El container inyecta por constructor y por parámetros del método.

```php
use PhobosFramework\Http\Request;
use PhobosFramework\Http\Response;

class PedidosController {
    public function __construct(
        private PedidosService $pedidos,   // autowiring
    ) {}

    public function show(Request $request, string $id): array {
        $pedido = $this->pedidos->find($id);   // $id viene del :id de la ruta
        if (!$pedido) {
            throw new NotFoundException('Pedido no encontrado');
        }
        return ['pedido' => $pedido];   // array → JSON automático
    }
}
```

Lo que devuelve un controller: un `array` (se convierte a JSON), un `string` (HTML), o un `Response`. Nada más.

## Request

```php
$request->method();            // 'GET'
$request->path();              // '/v1/pedidos/12'
$request->param('id');         // parámetro de ruta (:id)
$request->query('page', 1);    // query string, con default
$request->input('email');      // body de POST/PUT
$request->json();              // body JSON completo → stdClass, NO array
$request->json('cliente');     // una clave del JSON (solo primer nivel, sin notación de punto)
$request->body();              // body crudo
$request->header('Authorization');
$request->file('foto');        // archivo subido
$request->isJson(); $request->isPost(); $request->isAjax();
```

**Un body JSON `{...}` se decodifica a `stdClass`** (hace `json_decode($body)` sin el flag asociativo; body vacío o inválido → `stdClass` vacío, no rompe). Como casi todos los payloads son objetos, se accede con `->`, nunca con `[]`, y los services que reciben ese body se tipan `object`, no `array`. (Si el body fuera un array JSON `[...]`, `json()` devuelve un array; para objetos, que es lo normal, es `stdClass`.)

```php
$data = $request->json();
$codigo = $data->codigo ?? null;      // ✓
$codigo = $data['codigo'];            // ✗ fatal: no se puede indexar un stdClass
```

`json('clave')` solo lee el primer nivel (`$json->{$key}`); no hay notación de punto.

## Response

Dos estilos equivalentes: la clase estática y el helper `response()`.

```php
return Response::json(['ok' => true]);
return Response::json($data, 201);
return Response::error('No encontrado', 404);
return Response::empty();                     // 204
return Response::json($d)->header('X-Total', '42')->status(200);

return response()->json($data, 201);
return response()->error('Sin permisos', 403);
return response()->empty();
```

El código de estado acepta tanto el número como el enum: `Response::json($d, 201)` y `Response::json($d, HttpStatus::CREATED)` son equivalentes. Las firmas son `int|HttpStatus` y la respuesta normaliza el enum a su valor internamente (`json`, `error`, `->status()`, todas). El número es más corto; el enum es más explícito. Elige un estilo y sé consistente.

## Middleware

```php
use PhobosFramework\Middleware\MiddlewareInterface;
use PhobosFramework\Http\Request;
use PhobosFramework\Http\Response;
use Closure;

class AuthMiddleware implements MiddlewareInterface {
    public function __construct(private AuthContext $auth) {}   // autowiring, no uses inject() aquí

    public function handle(Request $request, Closure $next): Response {
        $token = $request->header('Authorization');
        if (!$this->esValido($token)) {
            return Response::error('Unauthorized', 401);   // cortar = retornar sin llamar a $next
        }
        $this->auth->setUser($usuario);
        return $next($request);   // continuar
    }
}
```

Tres niveles, se ejecutan en este orden: **global** (`Phobos::middleware()`) → **de módulo** (`ModuleInterface::middlewares()`) → **de ruta** (`->middleware()` o el `middleware` de un `group`) → controller.

## Contenedor de dependencias

Autowiring por reflexión sobre el constructor. Detecta dependencias circulares.

```php
container()->bind(Repo::class, RepoMySQL::class);       // transitorio
container()->singleton(Logger::class, FileLogger::class); // compartido
container()->instance(Config::class, $config);           // instancia ya creada
$logger = container()->make(Logger::class);

$logger = inject(Logger::class);   // helper equivalente a make()
```

Prefiere **inyección por constructor** a llamar `inject()` dentro de la clase: es lo que hace testeable el código.

## Service Providers

```php
use PhobosFramework\Core\ServiceProvider;
use PhobosFramework\Core\Container;

class AppServiceProvider extends ServiceProvider {
    public function register(Container $container): void {
        $container->singleton(AuthContext::class, fn() => new AuthContext());
        $container->singleton(PedidosService::class, fn($c) => new PedidosService($c->make(AuthContext::class)));
    }

    public function boot(Container $container): void {
        // corre después de que TODOS los providers se registraron
    }
}
```

Un "context" de request (datos del usuario autenticado, del tenant, etc.) se modela como singleton: el container se recrea en cada request, así que el singleton dura exactamente lo que dura la petición.

## Excepciones HTTP

`PhobosFramework\Exceptions\`: `BadRequestException` (400), `UnauthorizedException` (401), `ForbiddenException` (403), `NotFoundException` (404), `MethodNotAllowedException` (405), `ValidationException` (422, lleva array de errores), `TooManyRequestsException` (429), `ServiceUnavailableException` (503).

```php
throw new NotFoundException('Cliente no existe');
throw new ValidationException('Datos inválidos', ['email' => 'El email es requerido']);
abort(403, 'Sin permisos');   // helper
```

Lanzar la excepción es preferible a construir un `Response::error()` a mano: el entry point la serializa con su `toArray()`.

## Configuración

`.env` en la raíz, leído con `env('CLAVE', 'default')`. Archivos PHP en `config/` que retornan arrays, leídos con notación de punto: `config('database.connections.main.host')`.

Los archivos de `config/` pueden usar `env()` — es el patrón normal: el `.env` alimenta a `config/`, y el código lee `config()`.

### Qué castea `env()` y qué no

**Desde 3.3.0**, `env()` convierte `true`, `false`, `null` y `empty` a su tipo nativo (insensible a mayúsculas). **Los números no**: un `"007"` no es `7` y un `"1.0"` de versión no es el float `1.0`, así que se mantienen como texto a propósito.

```php
'debug' => env('APP_DEBUG', false),   // bool real desde 3.3.0
'port'  => (int)env('DB_PORT', 3306), // los números SÍ hay que castearlos
```

Y el valor por defecto se aplica **solo si la variable no existe**. Un `DB_PASSWORD=` vacío devuelve `''`, no el default: si el usuario lo escribió, es lo que quiso decir.

> **En 3.2.0 y anteriores `env()` no casteaba nada**, y como en PHP el string `"false"` es *truthy*, un `APP_DEBUG=false` dejaba el debug encendido para siempre — y un `CORS_SUPPORTS_CREDENTIALS=false` igual emitía la cabecera de credenciales. Si trabajas sobre un proyecto que aún está en 3.2.x, ese bug está vivo.

Por eso, en `config/`, castear defensivamente sigue siendo lo correcto: **funciona igual con el string y con el tipo nativo**, así que el mismo archivo es válido en cualquier versión.

```php
'debug' => filter_var(env('APP_DEBUG', false), FILTER_VALIDATE_BOOL),   // ✓ portable
```

El casteo va en `config/`, una sola vez, no regado por el código.

## Helpers globales

`phobos()`, `container()`, `request()`, `response()`, `route($name, $params)`, `inject($class)`, `singleton()`, `bind()`, `instance()`, `env()`, `config()`, `base_path()` (raíz), `app_path()`, `config_path()`, `storage_path()`, `public_path()`, `url()`, `abort()`, `dd()`, `dump()`, `dpre()`, `trace()`, `blank()`, `filled()`, `tap()`, `value()`, `with()`, `collect()`, `is_dev()`, `is_prod()`, `phobos_version()`.

## Observer (debugging)

Registra todo el ciclo de vida: `phobos.*`, `router.*`, `container.*`, `pipeline.*`.

```php
trace('pedido.creado', ['id' => $id]);   // registrar evento propio
Observer::dumpFormatted();               // ver la línea de tiempo completa
Observer::filter('router.*');
```

Es la herramienta para entender por qué una ruta no matchea o por qué el container no resuelve algo.