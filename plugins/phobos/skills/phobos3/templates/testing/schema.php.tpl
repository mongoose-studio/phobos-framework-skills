<?php

/*
 * Schema de la base de datos de test (SQLite en memoria).
 *
 * Devuelve una lista de sentencias DDL que DatabaseTestCase ejecuta una vez, antes del
 * primer test. Mantén aquí una tabla por cada entidad que tus tests usen — refleja las
 * columnas de tus clases de app/Entities/, en el dialecto de SQLite.
 *
 * Notas de portabilidad SQLite (el motor de los tests) frente a MySQL/PostgreSQL:
 *   - Clave autoincremental: INTEGER PRIMARY KEY AUTOINCREMENT.
 *   - No hay tipos ricos: usa TEXT para fechas/uuid, INTEGER para booleanos (0/1).
 *   - Para columnas JSON, TEXT (la capa castea con $casts igual que en producción).
 */

return [
    "CREATE TABLE IF NOT EXISTS pedidos (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid        TEXT,
        cliente_id  INTEGER,
        codigo      TEXT,
        total       REAL,
        created_at  TEXT,
        updated_at  TEXT,
        deleted_at  TEXT,
        created_by  INTEGER,
        updated_by  INTEGER,
        deleted_by  INTEGER,
        is_active   INTEGER NOT NULL DEFAULT 1
    )",
];
