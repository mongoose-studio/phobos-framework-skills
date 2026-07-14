<?php

namespace {{NAMESPACE}}\Providers;

use PhobosFramework\Core\Container;
use PhobosFramework\Core\ServiceProvider;

/**
 * Registro de los servicios de la aplicación.
 *
 * Un singleton aquí vive lo que vive el request: el container se recrea
 * en cada petición. Es el patrón para los "context" (usuario autenticado, etc.).
 */
class AppServiceProvider extends ServiceProvider {

    public function register(Container $container): void {
        // $container->singleton(AuthContext::class, fn() => new AuthContext());
        // $container->singleton(PedidosService::class, fn($c) => new PedidosService($c->make(AuthContext::class)));
    }

    public function boot(Container $container): void {
        // Corre después de registrar todos los providers.
        // Aquí van los alias de schema, por ejemplo:
        // schemaAlias('{{SCHEMA}}', env('DB_DATABASE'));
    }
}