<?php

namespace {{NAMESPACE}}\Entities\{{SCHEMA}};

use PhobosFramework\Database\Entity\TableEntity;

/**
 * Tabla {{SCHEMA}}.{{TABLE}}
 *
 * El nombre de la clase es el nombre exacto de la tabla (snake_case).
 * Una propiedad pública por columna; nullable si la columna lo es.
 *
 * Nombres reservados que NO puedes usar como propiedad:
 * _isNew, _original, _dirty, _reserved, schema, entity, pk.
 *
 * Después de crear esta clase: composer dump-autoload
 */
class {{TABLE}} extends TableEntity {

    // ?string, nullable. MySQL: el schema es la base. PostgreSQL: un schema real.
    // SQLite: NO tiene schemas — deja null y el nombre lo resuelve el motor.
    public static ?string $schema = "{{SCHEMA}}";
    public static string $entity = "{{TABLE}}";
    public static array $pk = ["id"];

    // Estrategia de PK (opcional): "auto" (por defecto) | "uuidv7" | "manual"
    // Con "uuidv7" el framework genera el id en PHP antes del INSERT, ordenado
    // por tiempo. La columna PK debe ser uuid (PG), CHAR(36) (MySQL) o TEXT (SQLite).
    // protected static string $keyStrategy = "uuidv7";

    // Casteo de columnas (opcional): json | bool | int | float | datetime
    // Imprescindible para JSONB en PostgreSQL.
    // protected static array $casts = [
    //     "meta"   => "json",
    //     "activo" => "bool",
    // ];

    // PK
    public ?int $id = null;
    public ?string $uuid = null;

    // Datos
    // public ?string $nombre = null;

    // Auditoría
    public ?string $created_at = CURRENT_TIMESTAMP;
    public ?string $updated_at = null;
    public ?string $deleted_at = null;
    public ?int $created_by = null;
    public ?int $updated_by = null;
    public ?int $deleted_by = null;
    public int $is_active = 1;
}