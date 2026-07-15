<?php

/*
 * El booleano se castea aquí. Desde Phobos 3.3.0 env() ya devuelve booleanos reales,
 * pero en 3.2.x devolvía strings — y "false" es truthy en PHP, así que un 'debug' sin
 * castear quedaba SIEMPRE encendido: stack traces expuestos en producción.
 * filter_var acepta ambos, así que este archivo sirve en cualquier versión.
 */

return [
    'name' => env('APP_NAME', '{{PROJECT_TITLE}}'),
    'version' => env('APP_VERSION', '1.0.0'),
    'env' => env('APP_ENV', 'production'),
    'debug' => filter_var(env('APP_DEBUG', false), FILTER_VALIDATE_BOOL),
    'url' => env('APP_URL', 'http://localhost:{{PORT}}'),
];