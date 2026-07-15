<?php

namespace {{NAMESPACE}}\Tests\Feature;

use {{NAMESPACE}}\Tests\TestCase;

/**
 * Feature test sin base de datos: extiende TestCase directamente.
 * Despacha requests reales por el pipeline y comprueba la respuesta.
 */
class HealthTest extends TestCase {

    public function test_health_responde_ok(): void {
        $response = $this->get('/health');

        $this->assertOk($response);
        $this->assertSame('ok', $this->json($response)['status']);
    }

    public function test_ruta_inexistente_da_404(): void {
        $response = $this->get('/no-existe');

        $this->assertStatus(404, $response);
    }
}
