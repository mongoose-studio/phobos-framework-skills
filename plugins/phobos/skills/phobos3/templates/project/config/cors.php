<?php

/*
 * Los booleanos se castean aquí, siempre.
 *
 * Desde Phobos 3.3.0 env() ya devuelve booleanos reales, pero en 3.2.x devolvía strings
 * — y en PHP "false" es truthy. Ahí, un CORS_SUPPORTS_CREDENTIALS=false igual emitía
 * 'Access-Control-Allow-Credentials: true', y combinado con allowed_origins='*' (que
 * refleja el Origin de quien llame) dejaba que cualquier sitio hiciera peticiones con
 * cookies contra esta API.
 *
 * filter_var funciona igual con el string y con el booleano, así que este archivo es
 * correcto en cualquier versión. Los números nunca se castean solos: van con (int).
 */

return [
    'allowed_origins' => env('CORS_ALLOWED_ORIGINS', '*'),
    'allowed_methods' => env('CORS_ALLOWED_METHODS', 'GET, POST, PUT, DELETE, PATCH, OPTIONS'),
    'allowed_headers' => env('CORS_ALLOWED_HEADERS', 'Content-Type, Authorization, X-Requested-With'),
    'exposed_headers' => env('CORS_EXPOSED_HEADERS', ''),
    'max_age' => (int)env('CORS_MAX_AGE', 86400),
    'supports_credentials' => filter_var(env('CORS_SUPPORTS_CREDENTIALS', false), FILTER_VALIDATE_BOOL),
];
