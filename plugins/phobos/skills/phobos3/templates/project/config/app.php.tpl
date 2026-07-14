<?php

return [
    'name' => env('APP_NAME', '{{PROJECT_TITLE}}'),
    'version' => env('APP_VERSION', '1.0.0'),
    'env' => env('APP_ENV', 'production'),
    'debug' => env('APP_DEBUG', false),
    'url' => env('APP_URL', 'http://localhost:{{PORT}}'),
];