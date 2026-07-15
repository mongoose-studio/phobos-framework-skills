<?php

namespace {{NAMESPACE}}\Tests\Feature;

use {{NAMESPACE}}\Entities\{{SCHEMA}}\{{TABLE}};
use {{NAMESPACE}}\Tests\DatabaseTestCase;

/**
 * Feature test CON base de datos: extiende DatabaseTestCase.
 * Recorre el CRUD de punta a punta, por las rutas reales del módulo.
 *
 * Ajusta rutas, payload y aserciones a tu dominio: este archivo es el molde.
 */
class {{MODULE}}Test extends DatabaseTestCase {

    public function test_lista_vacia_al_empezar(): void {
        $response = $this->get('/{{ROUTE_PREFIX}}');

        $this->assertOk($response);
        $this->assertSame([], $this->json($response)['items']);
    }

    public function test_crea_y_luego_lo_devuelve(): void {
        $crear = $this->postJson('/{{ROUTE_PREFIX}}', ['cliente_id' => 42, 'total' => 19990]);
        $this->assertStatus(201, $crear);

        $uuid = $this->json($crear)['item']['uuid'];
        $this->assertNotEmpty($uuid);

        // Round-trip: el mismo uuid se puede volver a leer. Cuando mapees tus campos en
        // el service (create/update), agrega aquí las aserciones sobre sus valores.
        $ver = $this->get("/{{ROUTE_PREFIX}}/$uuid");
        $this->assertOk($ver);
        $this->assertSame($uuid, $this->json($ver)['item']['uuid']);
    }

    public function test_borrar_responde_204_y_desaparece_de_la_lista(): void {
        $uuid = $this->json($this->postJson('/{{ROUTE_PREFIX}}', ['cliente_id' => 7]))['item']['uuid'];

        $this->assertStatus(204, $this->delete("/{{ROUTE_PREFIX}}/$uuid"));
        $this->assertSame(0, {{TABLE}}::count(['is_active = ?' => 1]));
    }
}
