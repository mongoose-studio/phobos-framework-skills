<?php

define('ROOT', realpath(dirname(__DIR__)));
define('APPLICATION', dirname(__DIR__) . '/app');
define('CURRENT_TIMESTAMP', date('Y-m-d H:i:s'));

require_once dirname(__DIR__) . '/vendor/autoload.php';

use {{NAMESPACE}}\Middleware\CorsMiddleware;
use {{NAMESPACE}}\Modules\ApiModule;
use PhobosFramework\Core\Phobos;
use PhobosFramework\Exceptions\HttpException;
use PhobosFramework\Exceptions\NotFoundException;

/*
 * Phobos no trae manejador global de errores: run() re-lanza cualquier excepción.
 * Este try/catch es el único punto donde se traducen a JSON.
 */
try {
    Phobos::init(ROOT, APPLICATION)
        ->loadEnvironment()
        ->loadConfig()
        ->middleware(CorsMiddleware::class)
        ->bootstrap(ApiModule::class)
        ->run()
        ->send();
} catch (NotFoundException $e) {
    http_response_code(404);
    header('Content-Type: application/json');
    echo json_encode([
        'error' => 'Not Found',
        'message' => $e->getMessage(),
        'status_code' => 404,
    ]);
} catch (HttpException $e) {
    http_response_code($e->getStatusCode());
    header('Content-Type: application/json');
    echo json_encode($e->toArray());
} catch (Throwable $e) {
    http_response_code(500);
    header('Content-Type: application/json');

    $debug = filter_var($_ENV['APP_DEBUG'] ?? false, FILTER_VALIDATE_BOOL);

    echo json_encode($debug ? [
        'error' => 'Internal Server Error',
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
        'trace' => array_slice($e->getTrace(), 0, 5),
    ] : [
        'error' => 'Internal Server Error',
        'message' => 'An unexpected error occurred',
    ]);
}