<?php

/**
 * Router para el servidor embebido de PHP (php -S).
 * Sirve los archivos existentes tal cual y manda todo lo demás a index.php.
 * En Apache/nginx este archivo no se usa: ahí manda el .htaccess / la config del vhost.
 */

if (php_sapi_name() === 'cli-server') {
    $path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
    $file = __DIR__ . $path;

    if ($path !== '/' && file_exists($file) && !is_dir($file)) {
        return false;
    }
}

require_once __DIR__ . '/index.php';