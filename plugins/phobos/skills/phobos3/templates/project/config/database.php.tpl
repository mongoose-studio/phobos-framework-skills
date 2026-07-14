<?php

use PhobosFramework\Database\Drivers\MySQL\MySQLDriver;
// use PhobosFramework\Database\Drivers\Postgres\PostgresDriver;
// use PhobosFramework\Database\Drivers\SQLite\SQLiteDriver;

// La conexión 'main' de abajo es para MySQL. Para PostgreSQL o SQLite cambia el bloque
// de 'connections' (ver forma exacta en la referencia de la capa de datos) y registra
// el driver correspondiente en 'drivers'.

return [
    'default' => env('DB_CONNECTION', 'main'),

    'connections' => [
        'main' => [
            'driver' => 'mysql',
            'host' => env('DB_HOST', 'localhost'),
            'port' => env('DB_PORT', 3306),
            'database' => env('DB_DATABASE', '{{DB_DATABASE}}'),
            'username' => env('DB_USERNAME', 'root'),
            'password' => env('DB_PASSWORD', ''),
            'charset' => env('DB_CHARSET', 'utf8mb4'),
            'collation' => env('DB_COLLATION', 'utf8mb4_unicode_ci'),
            'strict' => true,
            'timezone' => env('DB_TIMEZONE', '-04:00'),

            'options' => [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_OBJ,
                PDO::ATTR_TIMEOUT => 5,
            ],

            'session_variables' => [],
        ],
    ],

    // Sin esta sección, 'driver' => 'mysql' no resuelve a ninguna clase.
    'drivers' => [
        'mysql' => MySQLDriver::class,
        // 'pgsql'  => PostgresDriver::class,
        // 'sqlite' => SQLiteDriver::class,
    ],
];