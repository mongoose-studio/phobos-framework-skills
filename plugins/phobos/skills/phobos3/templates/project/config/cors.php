<?php

return [
    'allowed_origins' => env('CORS_ALLOWED_ORIGINS', '*'),
    'allowed_methods' => env('CORS_ALLOWED_METHODS', 'GET, POST, PUT, DELETE, PATCH, OPTIONS'),
    'allowed_headers' => env('CORS_ALLOWED_HEADERS', 'Content-Type, Authorization, X-Requested-With'),
    'exposed_headers' => env('CORS_EXPOSED_HEADERS', ''),
    'max_age' => env('CORS_MAX_AGE', 86400),
    'supports_credentials' => env('CORS_SUPPORTS_CREDENTIALS', false),
];