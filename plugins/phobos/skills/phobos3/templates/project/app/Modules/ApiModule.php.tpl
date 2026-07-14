<?php

namespace {{NAMESPACE}}\Modules;

use {{NAMESPACE}}\Providers\AppServiceProvider;
use PhobosFramework\Database\DatabaseServiceProvider;
use PhobosFramework\Exceptions\NotFoundException;
use PhobosFramework\Module\ModuleInterface;
use PhobosFramework\Routing\Router;

/**
 * Módulo raíz. Monta los módulos de dominio y expone el health check.
 * No declares aquí rutas de negocio: van en su propio módulo.
 */
class ApiModule implements ModuleInterface {

    public function routes(Router $router): void {
        $router->get('/', fn() => [
            'service' => config('app.name', '{{PROJECT_TITLE}}'),
            'version' => config('app.version', '1.0.0'),
        ])->name('home');

        $router->get('/health', fn() => [
            'status' => 'ok',
            'service' => '{{PROJECT_TITLE}}',
            'timestamp' => microtime(true),
        ])->name('health');

        // Módulos de dominio. Ejemplo:
        // $router->group(['prefix' => '/v1', 'middleware' => AuthMiddleware::class], function (Router $router) {
        //     $router->module('/ventas', VentasModule::class);
        // });

        // Catch-all: siempre al final.
        $router->all('/**', fn() => throw new NotFoundException('Route not found'));
    }

    public function middlewares(): array {
        return [];
    }

    /**
     * Solo los providers del módulo raíz se registran. Declara todos aquí.
     */
    public function providers(): array {
        return [
            DatabaseServiceProvider::class,
            AppServiceProvider::class,
        ];
    }
}