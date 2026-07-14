<?php

namespace {{NAMESPACE}}\Middleware;

use Closure;
use PhobosFramework\Http\Request;
use PhobosFramework\Http\Response;
use PhobosFramework\Middleware\MiddlewareInterface;

/**
 * Middleware {{MIDDLEWARE}}.
 *
 * Tres formas de aplicarlo, de más amplia a más estrecha:
 *   global  → Phobos::middleware({{MIDDLEWARE}}Middleware::class) en public/index.php
 *   módulo  → ModuleInterface::middlewares() → cubre todas las rutas del módulo
 *   ruta    → $router->get(...)->middleware({{MIDDLEWARE}}Middleware::class)
 *
 * Orden de ejecución: global → módulo → ruta → controller.
 */
class {{MIDDLEWARE}}Middleware implements MiddlewareInterface {

    /**
     * Inyección por constructor: el container la resuelve sola.
     * No uses inject() aquí dentro — esconde la dependencia y rompe los tests.
     */
    public function __construct(
        // private AuthContext $auth,
    ) {}

    public function handle(Request $request, Closure $next): Response {
        // Cortar = retornar sin llamar a $next().
        // if (!$ok) {
        //     return Response::error('Unauthorized', 401);
        // }

        // Continuar = pasar el request al siguiente eslabón.
        return $next($request);
    }
}