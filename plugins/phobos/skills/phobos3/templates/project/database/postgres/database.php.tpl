<?php

use PhobosFramework\Database\Drivers\Postgres\PostgresDriver;

/*
 * Configuración de PostgreSQL.
 *
 * Las tres claves de primer nivel son obligatorias:
 *   default     → la conexión que se usa cuando no se pide otra
 *   connections → los datos de cada conexión
 *   drivers     → mapea el nombre del driver a su clase; sin esto,
 *                 'driver' => 'pgsql' no resuelve a nada
 *
 * A diferencia de MySQL, el schema NO es la base de datos: es un schema real
 * dentro de ella, y la resolución de nombres no calificados la gobierna el
 * search_path de la sesión.
 */

return [
    'default' => env('DB_CONNECTION', 'main'),

    'connections' => [
        'main' => [
            'driver' => 'pgsql',
            'host' => env('DB_HOST', '127.0.0.1'),
            'port' => env('DB_PORT', 5432),
            'database' => env('DB_DATABASE', '{{DB_DATABASE}}'),
            'username' => env('DB_USERNAME', 'postgres'),
            'password' => env('DB_PASSWORD', ''),

            // Un solo schema. Para varios, cambia a:
            //   'search_path' => env('DB_SEARCH_PATH', 'app,public'),
            'schema' => env('DB_SCHEMA', 'public'),

            'timezone' => env('DB_TIMEZONE', 'UTC'),
            'client_encoding' => env('DB_ENCODING', 'UTF8'),

            // Aparece en los logs y en pg_stat_activity: hace obvio quién abrió la conexión.
            'application_name' => env('APP_NAME', '{{PROJECT_TITLE}}'),

            // disable | allow | prefer | require | verify-ca | verify-full
            'sslmode' => env('DB_SSLMODE', 'prefer'),

            'options' => [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_OBJ,
                PDO::ATTR_TIMEOUT => 5,
            ],
        ],
    ],

    'drivers' => [
        'pgsql' => PostgresDriver::class,
    ],
];