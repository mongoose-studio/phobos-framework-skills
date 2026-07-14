<?php

namespace {{NAMESPACE}}\Middleware;

use Closure;
use PhobosFramework\Http\Request;
use PhobosFramework\Http\Response;
use PhobosFramework\Middleware\MiddlewareInterface;

/**
 * CORS. Se registra como middleware global en public/index.php,
 * para que también cubra al preflight OPTIONS de rutas protegidas.
 */
class CorsMiddleware implements MiddlewareInterface {

    public function handle(Request $request, Closure $next): Response {
        $origin = $request->header('Origin') ?? '*';

        $allowedOrigins = config('cors.allowed_origins', '*');
        $allowedMethods = config('cors.allowed_methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS');
        $allowedHeaders = config('cors.allowed_headers', 'Content-Type, Authorization, X-Requested-With');
        $exposedHeaders = config('cors.exposed_headers', '');
        $maxAge = config('cors.max_age', 86400);
        $supportsCredentials = config('cors.supports_credentials', false);

        $allowOrigin = $this->resolveOrigin($origin, $allowedOrigins);

        $headers = [
            'Access-Control-Allow-Origin' => $allowOrigin,
            'Access-Control-Allow-Methods' => $allowedMethods,
            'Access-Control-Allow-Headers' => $allowedHeaders,
        ];

        if ($supportsCredentials && $allowOrigin !== '*') {
            $headers['Access-Control-Allow-Credentials'] = 'true';
        }

        if ($exposedHeaders) {
            $headers['Access-Control-Expose-Headers'] = $exposedHeaders;
        }

        // Preflight: se responde aquí, no llega al controller.
        if ($request->method() === 'OPTIONS') {
            $headers['Access-Control-Max-Age'] = (string)$maxAge;
            return Response::empty(204)->withHeaders($headers);
        }

        return $next($request)->withHeaders($headers);
    }

    /**
     * '*' deja pasar a todos. Una lista separada por comas solo refleja
     * el Origin si está en la lista.
     */
    private function resolveOrigin(string $origin, string|array $allowed): string {
        if ($allowed === '*') {
            return $origin;
        }

        $list = is_array($allowed) ? $allowed : explode(',', $allowed);
        $list = array_map('trim', $list);

        return in_array($origin, $list, true) ? $origin : '';
    }
}