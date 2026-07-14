<?php

namespace {{NAMESPACE}}\Modules\{{VERSION}}\{{MODULE}};

use {{NAMESPACE}}\Services\{{MODULE}}Service;
use PhobosFramework\Exceptions\NotFoundException;
use PhobosFramework\Http\Request;
use PhobosFramework\Http\Response;

/**
 * El controller orquesta: lee el request, llama al service, devuelve.
 * Las reglas de negocio viven en {{MODULE}}Service, no aquí.
 *
 * No captures excepciones para convertirlas en 500: el entry point ya
 * las traduce a JSON y respeta APP_DEBUG.
 */
class {{MODULE}}Controller {

    public function __construct(
        private {{MODULE}}Service ${{MODULE_VAR}},
    ) {}

    public function list(Request $request): array {
        $page = (int)$request->query('page', 1);
        $items = $this->{{MODULE_VAR}}->list($page);

        return [
            'items' => $items,
            'page' => $page,
        ];
    }

    public function get(string $id): array {
        $item = $this->{{MODULE_VAR}}->find($id);

        if (!$item) {
            throw new NotFoundException('{{MODULE}} no encontrado');
        }

        return ['item' => $item];
    }

    public function create(Request $request): Response {
        // OJO: json() devuelve stdClass, no array. Se accede con ->, no con [].
        $data = $request->json();
        $item = $this->{{MODULE_VAR}}->create($data);

        // El código puede ser el número (201) o el enum (HttpStatus::CREATED); ambos funcionan.
        return response()->json(['item' => $item], 201);
    }

    public function update(Request $request, string $id): array {
        $item = $this->{{MODULE_VAR}}->update($id, $request->json());

        return ['item' => $item];
    }

    public function delete(string $id): Response {
        $this->{{MODULE_VAR}}->delete($id);

        return response()->empty();
    }
}