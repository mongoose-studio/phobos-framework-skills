<?php

namespace {{NAMESPACE}}\Tests;

use PhobosFramework\Database\Connection\ConnectionManager;
use PhobosFramework\Database\Drivers\SQLite\SQLiteDriver;

/**
 * Base para tests que tocan la base de datos.
 *
 * Corre siempre contra SQLite en memoria, sin importar qué motor use el proyecto en
 * producción: la capa genera el SQL por dialecto, así que el esquema y las queries se
 * comportan igual para lo que un test de negocio necesita comprobar. Es instantáneo y no
 * deja rastro. (Requiere el paquete phobos-framework-database-sqlite como dependencia de
 * desarrollo, aunque produzcas contra MySQL o PostgreSQL.)
 *
 * Cómo se resuelven las trampas de la capa de datos:
 *
 *   - El ConnectionManager es un singleton de proceso. La conexión :memory: se abre una
 *     vez y se cachea, así que el schema creado en migrate() sobrevive a todos los tests
 *     del proceso. Por eso migramos una sola vez (guardado por $migrated).
 *
 *   - DatabaseServiceProvider::boot() re-fija la conexión por defecto a la de producción
 *     en CADA bootstrap. Como la app se re-arranca en cada test, hay que volver a apuntar
 *     el default a 'testing' en cada setUp. Eso lo hace useInMemoryDatabase().
 *
 *   - El aislamiento entre tests es por transacción: cada test corre dentro de una que se
 *     revierte en tearDown. Nada de lo que un test escribe llega al siguiente, y no hace
 *     falta recrear tablas. Funciona aunque el código bajo prueba use transaction() (anida
 *     con savepoints dentro de la del test).
 */
abstract class DatabaseTestCase extends TestCase {

    private static bool $migrated = false;

    protected function setUp(): void {
        parent::setUp();               // arranca la app
        $this->useInMemoryDatabase();  // re-apunta el default a :memory'
        $this->migrateOnce();          // crea el schema la primera vez
        beginTransaction();            // abre la transacción de aislamiento
    }

    protected function tearDown(): void {
        rollback();                    // descarta todo lo que el test escribió
        parent::tearDown();
    }

    /**
     * Registra (idempotente) una conexión SQLite :memory: llamada 'testing' y la deja por
     * defecto. addConnection() solo guarda config y NO descarta la conexión ya cacheada,
     * de modo que la base en memoria y su schema persisten entre tests.
     */
    protected function useInMemoryDatabase(): void {
        $manager = ConnectionManager::getInstance();
        $manager->registerDriver('sqlite', new SQLiteDriver());
        $manager->addConnection('testing', [
            'driver' => 'sqlite',
            'database' => ':memory:',
            'foreign_keys' => true,
            // Mismo fetch mode que producción (config/database.php). Que el test corra con
            // FETCH_OBJ importa: las filas llegan como stdClass igual que en MySQL/PostgreSQL,
            // y así los tests cazan bugs dependientes del fetch mode en vez de ocultarlos.
            'options' => [
                \PDO::ATTR_DEFAULT_FETCH_MODE => \PDO::FETCH_OBJ,
            ],
        ]);
        $manager->setDefaultConnection('testing');

        // SQLite no tiene schemas: una entidad con $schema = "{{SCHEMA}}" generaría SQL
        // contra "{{SCHEMA}}".tabla, que aquí no existe. Aliaseamos el schema a vacío para
        // que las entidades queden sin calificar y calcen con las tablas de schema.php.
        // Si tu proyecto usa varios schemas, agrega un schemaAlias por cada uno.
        schemaAlias('{{SCHEMA}}', '');
    }

    /**
     * Ejecuta el schema una sola vez por proceso de test.
     */
    protected function migrateOnce(): void {
        if (self::$migrated) {
            return;
        }

        foreach (require ROOT . '/tests/schema.php' as $statement) {
            db()->query($statement);
        }

        self::$migrated = true;
    }
}
