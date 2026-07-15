<?php

/*
 * Bootstrap de PHPUnit. Lo carga phpunit.xml antes de cualquier test.
 *
 * Define las MISMAS constantes que public/index.php. No es opcional:
 *   - APPLICATION la usa Phobos::init() para localizar app/.
 *   - CURRENT_TIMESTAMP la usan las entidades como valor por defecto de created_at
 *     (`public ?string $created_at = CURRENT_TIMESTAMP;`). PHP evalúa ese default al
 *     CARGAR la clase, así que sin la constante definida cualquier test que toque una
 *     entidad muere con "Undefined constant CURRENT_TIMESTAMP" antes de correr.
 */

define('ROOT', realpath(dirname(__DIR__)));
define('APPLICATION', dirname(__DIR__) . '/app');
define('CURRENT_TIMESTAMP', date('Y-m-d H:i:s'));

require_once dirname(__DIR__) . '/vendor/autoload.php';
