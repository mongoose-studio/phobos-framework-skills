# Capa de datos de Phobos 3

Verificado contra `phobos-framework-database` 3.2.0 y sus drivers 3.2.0 (MySQL, SQLite, PostgreSQL). Namespace: `PhobosFramework\Database\`.

La capa (`phobos-framework-database`) es un paquete separado del núcleo, y cada motor es su propio paquete de driver. Sin la capa no hay `query()`, ni `TableEntity`, ni conexiones; sin un driver no hay a qué conectarse.

```bash
# La capa + el driver que uses (uno o varios)
composer require mongoose-studio/phobos-framework-database
composer require mongoose-studio/phobos-framework-database-mysql      # MySQL / MariaDB
composer require mongoose-studio/phobos-framework-database-sqlite     # SQLite (dev / tests)
composer require mongoose-studio/phobos-framework-database-postgres   # PostgreSQL
```

Desde 3.2.0 la capa genera SQL **por dialecto**: cita identificadores con el carácter correcto de cada motor (backticks en MySQL, comillas dobles en PostgreSQL/SQLite) y usa `INSERT ... RETURNING` donde corresponde. No tienes que citar nombres a mano.

## Activación (se olvida siempre)

`DatabaseServiceProvider` tiene que estar en los `providers()` del **módulo raíz**. Si no, cualquier `query()` explota con "Database configuration not found".

```php
use PhobosFramework\Database\DatabaseServiceProvider;

public function providers(): array {
    return [
        DatabaseServiceProvider::class,   // primero
        AppServiceProvider::class,
    ];
}
```

Y `config/database.php` debe existir con esta forma exacta:

```php
use PhobosFramework\Database\Drivers\MySQL\MySQLDriver;

return [
    'default' => env('DB_CONNECTION', 'main'),
    'connections' => [
        'main' => [
            'driver'    => 'mysql',
            'host'      => env('DB_HOST', 'localhost'),
            'port'      => env('DB_PORT', 3306),
            'database'  => env('DB_DATABASE'),
            'username'  => env('DB_USERNAME'),
            'password'  => env('DB_PASSWORD'),
            'charset'   => env('DB_CHARSET', 'utf8mb4'),
            'collation' => env('DB_COLLATION', 'utf8mb4_unicode_ci'),
            'strict'    => true,
            'timezone'  => env('DB_TIMEZONE', '-04:00'),
            'options'   => [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_OBJ,
                PDO::ATTR_TIMEOUT => 5,
            ],
        ],
    ],
    'drivers' => [
        'mysql' => MySQLDriver::class,
    ],
];
```

Las tres claves de primer nivel — `default`, `connections`, `drivers` — son obligatorias. `drivers` mapea nombre → clase; sin él, `'driver' => 'mysql'` no resuelve a nada.

### El mismo `drivers`/`connections` para otros motores

```php
use PhobosFramework\Database\Drivers\Postgres\PostgresDriver;
use PhobosFramework\Database\Drivers\SQLite\SQLiteDriver;

'drivers' => [
    'mysql'  => MySQLDriver::class,
    'pgsql'  => PostgresDriver::class,
    'sqlite' => SQLiteDriver::class,
],
```

**PostgreSQL** — conexión con schema real (`search_path`); a diferencia de MySQL, el schema no es la base de datos:

```php
'main' => [
    'driver'      => 'pgsql',
    'host'        => env('DB_HOST', '127.0.0.1'),
    'port'        => env('DB_PORT', 5432),
    'database'    => env('DB_DATABASE'),
    'username'    => env('DB_USERNAME'),
    'password'    => env('DB_PASSWORD'),
    'schema'      => env('DB_SCHEMA', 'public'),   // o 'search_path' => 'app,public'
    // 'sslmode'  => 'require',                      // opcional
    // 'timezone' => 'UTC',                          // opcional
],
```

**SQLite** — ideal para desarrollo local y tests; solo necesita la ruta del archivo (o `:memory:`):

```php
'main' => [
    'driver'   => 'sqlite',
    'database' => env('DB_DATABASE', storage_path('database.sqlite')),  // o ':memory:'
],
```

## Entidades

Una clase por tabla, en `app/Entities/{schema}/`. **El nombre de la clase es el nombre exacto de la tabla**, en snake_case. Es deliberado: rompe PSR-1 pero hace obvio el mapeo y permite generarlas automáticamente.

```php
namespace App\Entities\ventas;

use PhobosFramework\Database\Entity\TableEntity;

class pedidos extends TableEntity {
    public static ?string $schema = "ventas";    // alias de schema (?string: nullable, ver abajo)
    public static string $entity = "pedidos";    // nombre real de la tabla
    public static array $pk = ["id"];            // array: soporta PK compuesta

    // PK
    public ?int $id = null;
    public ?string $uuid = null;

    // Datos: una propiedad pública por columna, tipo nullable si la columna lo es
    public int $cliente_id;
    public ?string $codigo = null;
    public ?float $total = null;

    // Auditoría (convención del framework)
    public ?string $created_at = CURRENT_TIMESTAMP;
    public ?string $updated_at = null;
    public ?string $deleted_at = null;
    public ?int $created_by = null;
    public ?int $updated_by = null;
    public ?int $deleted_by = null;
    public int $is_active = 1;
}
```

**El tipo de `$schema` es `?string`** (nullable). Contra 3.2.0 el padre lo declara `protected static ?string $schema = null`; si lo declaras `public static string $schema` (sin el `?`) PHP tira un fatal de incompatibilidad de tipo. Si la entidad no tiene schema, déjalo en `null` y el nombre lo resuelve el motor (el `search_path` en PostgreSQL).

Después de crear una entidad: **`composer dump-autoload`**. Si no, "class not found".

**Nombres prohibidos como propiedad** (los usa el motor de cambios): `_isNew`, `_original`, `_dirty`, `_reserved`, y los estáticos `schema`, `entity`, `pk`.

### Casteo de atributos (`$casts`)

Mapea columnas entre su forma en la base y su tipo nativo en PHP, en ambos sentidos. Es driver-neutral (funciona igual en los tres motores) e imprescindible para JSONB en PostgreSQL.

```php
class cuentas extends TableEntity {
    public static ?string $schema = null;
    public static string $entity = "cuentas";
    public static array $pk = ["id"];

    protected static array $casts = [
        "meta"       => "json",      // JSONB / TEXT  <->  array PHP
        "activo"     => "bool",      // entiende 't'/'f' de PostgreSQL y 1/0 de MySQL
        "intentos"   => "int",
        "saldo"      => "float",
        "creado_en"  => "datetime",  // string  <->  DateTimeImmutable
    ];

    public ?int $id = null;
    public mixed $meta = null;       // se lee y escribe como array PHP
    public mixed $activo = null;
}
```

Tipos: `json`, `bool`, `int`, `float`, `datetime`. Sin `$casts`, un array a una columna JSONB revienta y al leer vuelve como string.

### Estrategia de clave primaria (`$keyStrategy`)

Para PK de una sola columna. Por defecto `auto` (el motor genera el id).

```php
protected static string $keyStrategy = "auto";     // SERIAL/AUTO_INCREMENT; el id se relee tras el INSERT
protected static string $keyStrategy = "uuidv7";   // el framework genera un UUIDv7 en PHP antes del INSERT
protected static string $keyStrategy = "manual";   // la app asigna el valor
```

- `uuidv7` genera claves ordenadas por tiempo (índices contiguos, sin round-trip). La columna PK debe ser `uuid` (PostgreSQL), `CHAR(36)` (MySQL) o `TEXT` (SQLite).
- En PostgreSQL, `auto` lee el id con `INSERT ... RETURNING`; en MySQL/SQLite con `lastInsertId()`. Es transparente: `save()` deja el id en la propiedad igual.
- Un PK ya asignado **siempre gana**: se persiste tal cual, sin generar ni releer.

`CURRENT_TIMESTAMP` es una constante definida en `public/index.php`, no una función de SQL.

### CRUD

```php
// Crear
$pedido = new pedidos();
$pedido->cliente_id = 42;
$pedido->total = 19990;
$pedido->save();          // INSERT; deja el id autogenerado en $pedido->id

// Leer
$uno    = pedidos::findFirst(['uuid = ?' => $uuid]);          // ?static
$varios = pedidos::find(['is_active = ?' => 1], 'created_at DESC', 0, 20);
$porPk  = pedidos::findByPk(12);
$cuenta = pedidos::count(['cliente_id = ?' => 42]);
$hay    = pedidos::exists(['codigo = ?' => 'P-0001']);

// Actualizar: solo viajan los campos que cambiaron (change tracking)
$pedido->total = 24990;
$pedido->save();          // UPDATE ... SET total = ?

// Borrar
$pedido->remove();                              // DELETE físico
pedidos::delete(['is_active = ?' => 0], 100);   // DELETE masivo con límite
```

### Los límites de `find()`: primero cuántos, después saltando cuántos

Los parámetros 3 y 4 son `$limit` y `$offset` (en 3.2.0 se corrigieron los nombres, que antes eran engañosos). **El tercero es "cuántos"; el cuarto es "saltando cuántos".** El orden importa y equivocarlo falla en silencio.

```php
pedidos::find($where, 'id DESC', 0, 20);   // ✗ LIMIT 0 OFFSET 20 → array vacío, sin error
pedidos::find($where, 'id DESC', 20, 0);   // ✓ los primeros 20
pedidos::find($where, 'id DESC', 20, 40);  // ✓ 20 registros, saltando 40 (página 3)
```

Paginar, entonces, es así:

```php
{{TABLE}}::find($where, $order, $perPage, ($page - 1) * $perPage);
```

Un `offset` sin `limit` se ignora (no es SQL válido): manda el limit.

Firmas exactas:

- `find(array $where = [], string|array|null $order = null, ?int $limit = null, ?int $offset = null, bool $dryRun = false): array`
- `findFirst(array $where = [], string|array|null $order = null, bool $dryRun = false): static|null`
- `findByPk(mixed ...$pkValues): ?static`
- `count(array $where = []): int` · `exists(array $where): bool`
- `save(): bool` · `remove(): bool` · `refresh(): bool`

### Soft delete

La convención es no borrar: marcar. Es lo que espera el resto del sistema.

```php
$pedido->is_active  = 0;
$pedido->deleted_at = date('Y-m-d H:i:s');
$pedido->deleted_by = $this->auth->userId();
$pedido->save();
```

Y entonces toda lectura filtra por `['is_active = ?' => 1]`.

### Vistas

`ViewEntity` en vez de `TableEntity`: mismo `$schema`/`$entity`, sin `$pk`, y solo expone `find()`, `findFirst()` y `count()`. Es de solo lectura.

## Formato del WHERE

**Siempre** array asociativo: la clave es la condición con `?`, el valor es el binding.

```php
['estado = ?' => 'activo']
['nombre LIKE ?' => '%' . $texto . '%']
['cliente_id = ?' => $id, 'is_active = ?' => 1]     // se unen con AND
```

Nunca interpoles: `["nombre = '$nombre'"]` es una inyección SQL. El array con `?` es la única forma correcta.

## Query Builder

Para todo lo que no sea CRUD de una sola tabla: joins, agregaciones, selects parciales.

```php
$filas = query()
    ->select('p.id', 'p.codigo', 'c.nombre AS cliente')
    ->from(pedidos::getIdentification(), 'p')          // ← usa getIdentification(), no strings
    ->innerJoin(clientes::getIdentification(), 'c', 'c.id = p.cliente_id')
    ->leftJoin(pagos::getIdentification(), 'g', 'g.pedido_id = p.id')
    ->where(['p.is_active = ?' => 1, 'p.cliente_id = ?' => $clienteId])
    ->orderBy('p.created_at DESC')
    ->limit(20, 40)          // limit, offset
    ->fetch();               // array de objetos (por el FETCH_OBJ del config)
```

`Entidad::getIdentification()` devuelve `schema.tabla` ya resuelto (y sin schema, solo la tabla). Úsalo siempre en `from()` y en los `join()`: si el schema cambia de nombre, tu query sigue funcionando.

La capa cita automáticamente los identificadores en las posiciones estructurales (tabla, columnas de `select`/`group by`/`order by`, columnas de INSERT/UPDATE) con el carácter del dialecto. Las condiciones de `where()`, `having()` y el `ON` de los joins se pasan **tal cual**: ahí escribes tú, así que sigue parametrizando con `?` y no cites nombres a mano.

Métodos: `select`, `distinct`, `from`, `where`, `orWhere`, `join`, `innerJoin`, `leftJoin`, `rightJoin`, `groupBy`, `having`, `orderBy`, `limit`, `offset`, `union`, `unionAll`, `whereSubQuery`, `whereExists`, `whereNotExists`, `asSubQuery`, `fromSubQuery`.

Ejecución: `fetch()` (array de filas), `fetchFirst()` (una fila o null), `fetchColumn()` (un valor escalar).

Escrituras sueltas, cuando la entidad no aporta:

```php
insert()->into(pedidos::getIdentification())->values(['cliente_id' => 42])->executeAndGetId();
update()->table(pedidos::getIdentification())->set(['total' => 100])->where(['id = ?' => 5])->execute();
delete()->from(pedidos::getIdentification())->where(['id = ?' => 5])->limit(1)->execute();
```

`DELETE ... LIMIT` funciona en MySQL y SQLite, pero **PostgreSQL no lo soporta**: ahí `->limit()` en un delete lanza una excepción clara en vez de emitir SQL inválido. Acota con `where()`.

### Depurar una query

```php
$qb = query()->select('*')->from(pedidos::getIdentification())->where(['id = ?' => 5]);
dd($qb->getQueryWithBindings());   // ['query' => 'SELECT ...', 'bindings' => [5]]
```

Los métodos de entidad también aceptan `$dryRun = true` y devuelven lo mismo sin tocar la base.

## Transacciones

La forma correcta es el helper `transaction()`: hace commit si todo sale bien y rollback si algo lanza.

```php
transaction(function () use ($datos) {
    $pedido = new pedidos();
    $pedido->cliente_id = $datos['cliente_id'];
    $pedido->save();

    foreach ($datos['lineas'] as $linea) {
        $l = new pedidos_lineas();
        $l->pedido_id = $pedido->id;
        $l->save();
    }
});
```

Manual, solo si necesitas control fino:

```php
beginTransaction();
try {
    // ...
    commit();
} catch (Throwable $e) {
    rollback();
    throw $e;          // re-lanzar SIEMPRE: si no, el error desaparece
}
```

Anidan mediante savepoints (`beginTransaction()` dentro de otra transacción crea un savepoint). Helpers: `inTransaction()`, `getTransactionLevel()`.

## Alias de schema

El `$schema` de una entidad es un **alias lógico**. Permite que las entidades digan `ventas` y que en producción eso apunte a otra base/schema, sin tocar el código.

```php
schemaAlias('ventas', env('DB_DATABASE'));                       // en el boot() de un provider
schemaBulkAlias(['ventas' => 'ventas_prod', 'core' => 'core_v2']);
```

En MySQL "schema" y "base de datos" son lo mismo. En PostgreSQL es un schema real. Si no registras alias, `$schema` se usa literal.

**Schema-per-tenant (re-apuntar en runtime).** Como el alias se resuelve en cada operación, puedes mapearlo a un schema físico distinto por request —por ejemplo en un middleware, según el tenant— y todas las entidades con ese `$schema` siguen la redirección sin cambios:

```php
schemaAlias('ventas', "tenant_{$tenantId}");   // ahora ventas.pedidos escribe/lee en tenant_42.pedidos
```

## PostgreSQL: schemas, JSONB y RETURNING

Lo que cambia respecto a MySQL, ya cubierto arriba pero junto:

- **Schemas reales**: usa `$schema` en la entidad (`"ventas".pedidos`) o deja `$schema = null` y resuelve por `search_path` (config `schema`/`search_path`). Son alias re-apuntables (ver arriba).
- **JSONB**: declara la columna en `$casts` como `json`; guardas y lees un array PHP. Para **consultar dentro** del JSONB usa `where()` crudo con operadores que no choquen con los `?` de PDO (`->>`, `@>`, `#>>`), nunca los operadores `?`/`?|`/`?&`:

  ```php
  cuentas::find(["meta->>'plan' = ?" => 'pro']);   // ✓
  ```

- **Id autogenerado**: `$keyStrategy = 'auto'` lo lee con `INSERT ... RETURNING`; `uuidv7` lo genera en PHP. Transparente para `save()`.
- **Sin `DELETE ... LIMIT`**: acota con `where()`.
- **Booleans**: la capa persiste bool como `1`/`0` y castea `'t'`/`'f'` de vuelta a bool; declara la columna en `$casts` como `bool`.

## Múltiples conexiones

Agrega otra entrada en `connections` y apunta la entidad con `protected static ?string $connection = 'reportes';`. Los helpers aceptan el nombre: `query('reportes')`, `db('reportes')`, `transaction($fn, 'reportes')`.