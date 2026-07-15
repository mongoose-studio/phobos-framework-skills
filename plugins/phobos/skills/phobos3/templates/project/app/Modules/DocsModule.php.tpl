<?php

namespace {{NAMESPACE}}\Modules;

use PhobosFramework\Exceptions\NotFoundException;
use PhobosFramework\Http\Response;
use PhobosFramework\Module\ModuleInterface;
use PhobosFramework\Routing\Router;

/**
 * Sirve la documentación de la API.
 *
 *   GET /docs               → Swagger UI (HTML)
 *   GET /docs/openapi.yaml  → el spec crudo, que Swagger UI consume
 *
 * La fuente de verdad es docs/openapi.yaml en la raíz del proyecto; este módulo solo la
 * expone. Swagger UI se carga desde un CDN, así que la página necesita internet; para un
 * entorno aislado, descarga el dist de swagger-ui y sírvelo desde public/.
 *
 * Se monta en ApiModule:  $router->module('/docs', DocsModule::class);
 * Si no quieres exponer la doc en producción, envuelve ese module() en if (!is_prod()).
 */
class DocsModule implements ModuleInterface {

    public function routes(Router $router): void {
        $router->get('/', fn() => Response::html($this->swaggerUi()))->name('docs.ui');
        $router->get('/openapi.yaml', fn() => $this->spec())->name('docs.spec');
    }

    public function middlewares(): array {
        return [];
    }

    public function providers(): array {
        return [];
    }

    private function spec(): Response {
        $path = base_path('docs/openapi.yaml');

        if (!is_file($path)) {
            throw new NotFoundException('openapi.yaml no encontrado');
        }

        return Response::text(file_get_contents($path))
            ->header('Content-Type', 'application/yaml; charset=utf-8');
    }

    private function swaggerUi(): string {
        $title = config('app.name', '{{PROJECT_TITLE}}');

        return <<<HTML
        <!doctype html>
        <html lang="es">
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <title>$title — API Docs</title>
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5/swagger-ui.css">
        </head>
        <body>
            <div id="swagger-ui"></div>
            <script src="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5/swagger-ui-bundle.js"></script>
            <script>
                window.ui = SwaggerUIBundle({
                    url: '/docs/openapi.yaml',
                    dom_id: '#swagger-ui',
                });
            </script>
        </body>
        </html>
        HTML;
    }
}
