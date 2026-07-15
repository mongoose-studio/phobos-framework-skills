<?php

namespace {{NAMESPACE}}\Tests;

use {{NAMESPACE}}\Modules\ApiModule;
use PhobosFramework\Core\Phobos;
use PhobosFramework\Exceptions\HttpException;
use PhobosFramework\Http\Request;
use PhobosFramework\Http\Response;
use PHPUnit\Framework\TestCase as BaseTestCase;
use ReflectionClass;

/**
 * Base de todos los tests.
 *
 * Arranca la app de verdad y despacha requests por el mismo pipeline que en producción
 * (Phobos::run), sin levantar un servidor HTTP. Esconde dos trampas del framework:
 *
 *   1. Request exige sus nueve argumentos por posición. Los helpers de abajo los rellenan.
 *   2. Phobos::init() es un singleton sin reset. Entre test y test hay que anular la
 *      instancia por reflexión, o el segundo test reutiliza la app (y los singletons de
 *      request) del primero. Eso lo hace resetApp().
 *
 * Si tu test toca la base de datos, extiende DatabaseTestCase en vez de esta.
 */
abstract class TestCase extends BaseTestCase {

    protected Phobos $app;

    protected function setUp(): void {
        parent::setUp();
        $this->app = $this->bootApp();
    }

    protected function tearDown(): void {
        $this->resetApp();
        parent::tearDown();
    }

    /**
     * Arranca la app: misma cadena que public/index.php, sin ->run()->send().
     */
    protected function bootApp(): Phobos {
        $this->resetApp();

        return Phobos::init(ROOT, APPLICATION)
            ->loadConfig()
            ->bootstrap(ApiModule::class);
    }

    /**
     * Anula el singleton de Phobos para que el próximo init() construya una app limpia.
     * El ConnectionManager es su propio singleton y NO se toca aquí: así la base de datos
     * en memoria y su schema sobreviven entre tests (ver DatabaseTestCase).
     */
    protected function resetApp(): void {
        $property = new ReflectionClass(Phobos::class)->getProperty('instance');
        $property->setValue(null, null);
    }

    // ------------------------------------------------------------------ despacho de requests

    /**
     * Construye un Request y lo corre por el pipeline. Devuelve el Response.
     *
     * @param array{query?: array, post?: array, headers?: array, json?: mixed, body?: string} $options
     */
    protected function request(string $method, string $path, array $options = []): Response {
        $headers = $options['headers'] ?? [];
        $body = $options['body'] ?? '';

        if (array_key_exists('json', $options)) {
            $body = json_encode($options['json']);
            $headers['Content-Type'] = 'application/json';
        }

        $request = new Request(
            method: strtoupper($method),
            path: $path,
            query: $options['query'] ?? [],
            post: $options['post'] ?? [],
            files: [],
            cookies: [],
            server: [],
            headers: $headers,
            body: $body,
        );

        // run() re-lanza las excepciones: en producción es el try/catch de public/index.php
        // el que las traduce a JSON. Aquí replicamos ESA traducción para las HttpException
        // (404, 422, 401...), de modo que los tests asserten sobre status codes igual que
        // los ve un cliente. Cualquier otra excepción se deja subir: es un bug real y debe
        // reventar el test, no convertirse en un 500 silencioso.
        try {
            return $this->app->run($request);
        } catch (HttpException $e) {
            return Response::json($e->toArray(), $e->getStatusCode());
        }
    }

    protected function get(string $path, array $query = [], array $headers = []): Response {
        return $this->request('GET', $path, ['query' => $query, 'headers' => $headers]);
    }

    protected function postJson(string $path, mixed $data = [], array $headers = []): Response {
        return $this->request('POST', $path, ['json' => $data, 'headers' => $headers]);
    }

    protected function putJson(string $path, mixed $data = [], array $headers = []): Response {
        return $this->request('PUT', $path, ['json' => $data, 'headers' => $headers]);
    }

    protected function patchJson(string $path, mixed $data = [], array $headers = []): Response {
        return $this->request('PATCH', $path, ['json' => $data, 'headers' => $headers]);
    }

    protected function delete(string $path, array $headers = []): Response {
        return $this->request('DELETE', $path, ['headers' => $headers]);
    }

    // ------------------------------------------------------------------------- aserciones

    /**
     * El cuerpo de la respuesta, decodificado como array asociativo.
     */
    protected function json(Response $response): array {
        return json_decode((string)$response->getContent(), true) ?? [];
    }

    protected function assertStatus(int $expected, Response $response): void {
        $this->assertSame(
            $expected,
            $response->getStatusCode(),
            "Se esperaba HTTP $expected, llegó {$response->getStatusCode()}: " . $response->getContent(),
        );
    }

    protected function assertOk(Response $response): void {
        $this->assertStatus(200, $response);
    }
}
