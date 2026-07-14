<?php

namespace {{NAMESPACE}}\Modules\{{VERSION}}\{{MODULE}};

use PhobosFramework\Module\ModuleInterface;
use PhobosFramework\Routing\Router;

/**
 * Módulo {{MODULE}}.
 *
 * Se monta desde el módulo padre con:
 *     $router->module('/{{ROUTE_PREFIX}}', {{MODULE}}Module::class);
 *
 * Las rutas de aquí son relativas a ese prefijo.
 */
class {{MODULE}}Module implements ModuleInterface {

    public function routes(Router $router): void {
        // Literales primero: si :id va antes, se come '/exportar'.
        $router->get('/', [{{MODULE}}Controller::class, 'list'])->name('{{ROUTE_NAME}}.list');
        $router->post('/', [{{MODULE}}Controller::class, 'create'])->name('{{ROUTE_NAME}}.create');
        $router->get('/:id', [{{MODULE}}Controller::class, 'get'])->name('{{ROUTE_NAME}}.get');
        $router->patch('/:id', [{{MODULE}}Controller::class, 'update'])->name('{{ROUTE_NAME}}.update');
        $router->delete('/:id', [{{MODULE}}Controller::class, 'delete'])->name('{{ROUTE_NAME}}.delete');
    }

    /**
     * Middlewares que aplican a TODAS las rutas de este módulo.
     */
    public function middlewares(): array {
        return [];
    }

    /**
     * Los providers de un módulo anidado no se registran:
     * decláralos en el módulo raíz.
     */
    public function providers(): array {
        return [];
    }
}