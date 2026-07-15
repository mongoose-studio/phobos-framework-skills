<?php

namespace {{NAMESPACE}}\Services;

use {{NAMESPACE}}\Entities\{{SCHEMA}}\{{TABLE}};
use PhobosFramework\Database\Support\Uuid;
use PhobosFramework\Exceptions\NotFoundException;

/**
 * Lógica de negocio de {{MODULE}}.
 *
 * Regístralo en AppServiceProvider:
 *     $container->singleton({{MODULE}}Service::class, fn() => new {{MODULE}}Service());
 *
 * $data llega como stdClass: es lo que devuelve Request::json().
 */
class {{MODULE}}Service {

    /**
     * @return {{TABLE}}[]
     */
    public function list(int $page = 1, int $perPage = 20): array {
        // Los parámetros 3 y 4 de find() son (limit, offset): "cuántos" y
        // "saltando cuántos". Pasar (0, 20) genera LIMIT 0 y devuelve [] sin error.
        return {{TABLE}}::find(
            ['is_active = ?' => 1],
            'created_at DESC',
            $perPage,                // limit
            ($page - 1) * $perPage,  // offset
        );
    }

    public function find(string $uuid): ?{{TABLE}} {
        return {{TABLE}}::findFirst(['uuid = ?' => $uuid, 'is_active = ?' => 1]);
    }

    public function create(object $data): {{TABLE}} {
        $item = new {{TABLE}}();
        $item->uuid = Uuid::v7();   // UUIDv7 del framework: ordenado por tiempo, índices contiguos
        // $item->nombre = $data->nombre;
        $item->created_at = date('Y-m-d H:i:s');
        $item->save();

        return $item;
    }

    public function update(string $uuid, object $data): {{TABLE}} {
        $item = $this->find($uuid);

        if (!$item) {
            throw new NotFoundException('{{MODULE}} no encontrado');
        }

        // $item->nombre = $data->nombre ?? $item->nombre;
        $item->updated_at = date('Y-m-d H:i:s');
        $item->save();   // solo viajan los campos que cambiaron

        return $item;
    }

    /**
     * Soft delete: se marca, no se borra.
     */
    public function delete(string $uuid): void {
        $item = $this->find($uuid);

        if (!$item) {
            throw new NotFoundException('{{MODULE}} no encontrado');
        }

        $item->is_active = 0;
        $item->deleted_at = date('Y-m-d H:i:s');
        $item->save();
    }
}