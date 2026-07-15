<?php

namespace {{NAMESPACE}}\Tests\Feature;

use {{NAMESPACE}}\Tests\DatabaseTestCase;

/**
 * Feature test de {{MODULE}}.
 *
 * Extiende DatabaseTestCase si tocas datos; TestCase si no. Cada test corre dentro de una
 * transacción que se revierte, así que empiezas siempre con la base limpia.
 *
 * Helpers disponibles (de TestCase): get(), postJson(), putJson(), patchJson(), delete();
 * json($response) para leer el cuerpo; assertOk() / assertStatus().
 */
class {{MODULE}}Test extends DatabaseTestCase {

    public function test_lista_responde_ok(): void {
        $response = $this->get('/{{ROUTE_PREFIX}}');

        $this->assertOk($response);
    }
}
