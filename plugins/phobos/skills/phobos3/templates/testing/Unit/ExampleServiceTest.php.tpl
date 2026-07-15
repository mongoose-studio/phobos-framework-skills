<?php

namespace {{NAMESPACE}}\Tests\Unit;

use {{NAMESPACE}}\Entities\{{SCHEMA}}\{{TABLE}};
use {{NAMESPACE}}\Services\{{MODULE}}Service;
use {{NAMESPACE}}\Tests\DatabaseTestCase;

/**
 * Test unitario de un service contra la base de datos en memoria.
 *
 * Extiende DatabaseTestCase porque el service persiste entidades. Se instancia el service
 * directo (sin pasar por el pipeline HTTP) y se verifica su efecto sobre los datos.
 */
class ExampleServiceTest extends DatabaseTestCase {

    private {{MODULE}}Service ${{MODULE_VAR}};

    protected function setUp(): void {
        parent::setUp();
        $this->{{MODULE_VAR}} = new {{MODULE}}Service();
    }

    public function test_create_persiste_y_asigna_uuid(): void {
        $data = (object)['cliente_id' => 42, 'total' => 19990];

        $item = $this->{{MODULE_VAR}}->create($data);

        $this->assertNotNull($item->id);
        $this->assertNotNull($item->uuid);
        $this->assertSame(1, {{TABLE}}::count(['is_active = ?' => 1]));
    }

    public function test_delete_es_soft_delete(): void {
        $item = $this->{{MODULE_VAR}}->create((object)['cliente_id' => 1]);

        $this->{{MODULE_VAR}}->delete($item->uuid);

        // El registro sigue existiendo, pero marcado como inactivo.
        $this->assertSame(0, {{TABLE}}::count(['is_active = ?' => 1]));
        $this->assertSame(1, {{TABLE}}::count([]));
    }
}
