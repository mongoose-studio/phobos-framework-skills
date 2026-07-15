<?php

use PhobosFramework\Database\Drivers\MySQL\MySQLDriver;

/*
 * Configuración de MySQL / MariaDB.
 *
 * Las tres claves de primer nivel son obligatorias:
 *   default     → la conexión que se usa cuando no se pide otra
 *   connections → los datos de cada conexión
 *   drivers     → mapea el nombre del driver a su clase; sin esto,
 *                 'driver' => 'mysql' no resuelve a nada
 *
 * En MySQL "schema" y "base de datos" son lo mismo.
 */

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

            // Variables de sesión (SET SESSION ...), si el proyecto las necesita.
            'session_variables' => [],
        ],
    ],

    'drivers' => [
        'mysql' => MySQLDriver::class,
    ],
];