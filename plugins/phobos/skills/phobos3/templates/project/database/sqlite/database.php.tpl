<?php

use PhobosFramework\Database\Drivers\SQLite\SQLiteDriver;

/*
 * Configuración de SQLite.
 *
 * Las tres claves de primer nivel son obligatorias:
 *   default     → la conexión que se usa cuando no se pide otra
 *   connections → los datos de cada conexión
 *   drivers     → mapea el nombre del driver a su clase; sin esto,
 *                 'driver' => 'sqlite' no resuelve a nada
 *
 * SQLite no tiene servidor: no hay host, ni puerto, ni usuario, ni password,
 * ni charset de conexión. Todo lo que se ajusta se ajusta con PRAGMAs.
 */

return [
    'default' => env('DB_CONNECTION', 'main'),

    'connections' => [
        'main' => [
            'driver' => 'sqlite',

            // Ruta al archivo, o ':memory:' para una base efímera (ideal en tests).
            'database' => env('DB_DATABASE', storage_path('database.sqlite')),

            // SQLite trae las claves foráneas APAGADAS por defecto. El driver las
            // enciende salvo que pongas false aquí. Déjalo en true.
            'foreign_keys' => true,

            // WAL permite leer mientras se escribe: es lo que quieres salvo que la
            // base viva en un sistema de archivos de red.
            'journal_mode' => env('DB_JOURNAL_MODE', 'WAL'),

            // Milisegundos que espera ante un bloqueo antes de rendirse.
            'busy_timeout' => env('DB_BUSY_TIMEOUT', 5000),

            // OFF | NORMAL | FULL | EXTRA. Con WAL, NORMAL es el punto sensato.
            'synchronous' => env('DB_SYNCHRONOUS', 'NORMAL'),

            'options' => [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_OBJ,
            ],
        ],
    ],

    'drivers' => [
        'sqlite' => SQLiteDriver::class,
    ],
];