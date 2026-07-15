# Phobos Framework 3 — guía para agentes

Punto de entrada **agnóstico de herramienta** para construir con Phobos Framework 3 (PHP 8.4+).
El mismo conocimiento que el plugin de Claude Code (`plugins/phobos/`), pero en el formato que
cualquier agente lee: Codex, Claude Code sin el plugin, u otro.

Phobos es minimalista, modular (inspirado en Angular) y **sin dependencias en su núcleo. No es
Laravel** — muchos reflejos de Laravel producen código que no compila o rompe en runtime.

## Cómo usar esta guía

Este archivo es un índice delgado, no la documentación completa. Las reglas de abajo son
obligatorias; el detalle vive en las referencias, que debes **abrir cuando la tarea las toque**
(no las cargues todas de una):

| Lee… | Cuándo |
|---|---|
| `plugins/phobos/skills/phobos3/references/core.md` | Siempre antes de escribir una ruta: routing, módulos, DI, middleware, request/response |
| `plugins/phobos/skills/phobos3/references/database.md` | Si la tarea toca datos: entidades, query builder, transacciones, casts |
| `plugins/phobos/skills/phobos3/references/testing.md` | Si escribes, arreglas o corres tests |
| `plugins/phobos/skills/phobos3/references/api-docs.md` | Si agregas, cambias o quitas rutas (el `openapi.yaml` se actualiza en el mismo cambio) |
| `plugins/phobos/skills/phobos3/references/anti-patterns.md` | Antes de dar cualquier cosa por terminada |

`plugins/phobos/skills/phobos3/SKILL.md` es la fuente de verdad completa (flujo de proyecto
nuevo, generadores, placeholders, checklist). Las referencias están verificadas contra el código
fuente de los paquetes, no contra la documentación — si tu memoria contradice una referencia,
gana la referencia.

### Setup para Codex (u otro agente fuera de Claude Code)

Codex lee este `AGENTS.md` automáticamente desde la raíz del repo. Para que los punteros de arriba
resuelvan, necesitas las `references/` y `templates/` accesibles: clona/vendoriza este repo
(`phobos-framework-skills`) junto a tu proyecto, o copia `plugins/phobos/skills/phobos3/` dentro de
él, y ajusta las rutas de la tabla a donde queden. Los `templates/` son archivos con placeholders
`{{...}}` que reemplazas al generar.

## Reglas de oro (no negociables)

1. **Parámetros de ruta con `:param`, jamás `{param}`.** `$router->get('/users/:id', ...)`.
2. **Un `Module` por carpeta de dominio.** Las rutas se declaran en el módulo, nunca sueltas en el módulo raíz.
3. **La lógica de negocio va en `app/Services/`.** El controller lee el request, llama al service, devuelve. Nada más.
4. **SQL siempre parametrizado**: `['columna = ?' => $valor]`. Nunca interpoles variables en SQL.
5. **Nunca leas `$_POST`/`$_GET`/`$_FILES`.** Usa `$request->input()`, `$request->json()`, `$request->query()`, `$request->file()`.
6. **`$request->json()` devuelve `stdClass`**, no array: accede con `->`, tipa los services con `object`.
7. **Cortar el request es del middleware o de una excepción**, no de un `->send()` a medio constructor.
8. **Nunca un `catch` vacío.** Si no puedes manejar la excepción, déjala subir: el entry point la convierte en JSON.
9. **El `.env` no se commitea nunca.** Solo `.env.example`. `composer.lock` **sí** se commitea (es una aplicación).
10. **PHP 8.4+**: tipos en todos los parámetros y retornos, promoted properties, enums.
11. **Toda ruta nueva o modificada se refleja en `docs/openapi.yaml`** en el mismo cambio. Documentar la API es ley.
12. **Al terminar un cambio con lógica**, corre `composer test`.

## Alcance: núcleo minimalista

El core **no trae, a propósito**: migraciones, validador, logger, caché, CLI ni eventos (solo el
Observer para depurar). No los inventes ni los metas inline. Esas capacidades llegan como librerías
satélite opcionales y como **Deimos** (una CLI-util aparte, en Rust, estilo Artisan). En concreto:
el schema de producción es SQL plano por ahora (no generes un migrador casero); la validación se
hace a mano en el service con `ValidationException('...', ['campo' => 'error'])`.

## Generadores

En `plugins/phobos/skills/phobos3/templates/generators/` (quítales `.tpl` al usar):
`module`, `controller`, `entity`, `service`, `middleware`, `provider`, `test`.
El esqueleto completo de proyecto está en `templates/project/` (con `database/` por motor:
mysql · postgres · sqlite), el kit de tests en `templates/testing/`, y la doc en `templates/docs/`.

## Versiones

| Paquete | Versión |
|---|---|
| `mongoose-studio/phobos-framework` | 3.3.0 |
| `mongoose-studio/phobos-framework-database` | 3.2.1 |
| `mongoose-studio/phobos-framework-database-mysql` · `-sqlite` · `-postgres` | 3.2.0 |

Requiere **PHP 8.4+**. Los tres motores generan SQL correcto por dialecto automáticamente.
