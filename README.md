# Phobos3 Framework - Skills

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/mongoose-studio/phobos-framework/main/phobos-banner-dark.png">
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/mongoose-studio/phobos-framework/main/phobos-banner.png">
  <img alt="Phobos Framework" height="64px" src="https://raw.githubusercontent.com/mongoose-studio/phobos-framework/main/phobos-banner-dark.png">
</picture>

Plugin de [Claude Code](https://claude.com/claude-code) para construir backends y APIs con **[Phobos Framework 3](https://github.com/mongoose-studio/phobos-framework)** (PHP 8.4+).

Enseña la forma canónica del framework, levanta proyectos completos desde cero y genera módulos, controllers, entidades, services, middleware y providers siguiendo un único estándar.

## Instalación

```
/plugin marketplace add mongoose-studio/phobos-framework-skills
/plugin install phobos@mongoose-studio
```

Reinicia Claude Code (o corre `/reload-plugins`) y listo.

## Uso

La skill se activa sola cuando Claude detecta que estás trabajando en un proyecto Phobos (`mongoose-studio/phobos-framework` en el `composer.json`, clases que implementan `ModuleInterface`, entidades que extienden `TableEntity`). También la puedes invocar a mano:

```
/phobos:phobos3
```

**Proyecto nuevo.** Pídeselo en lenguaje natural: *"créame una API con Phobos para gestionar pedidos"*. Claude va a preguntarte el nombre y el namespace, los datos de la base, si necesitas autenticación y qué extras quieres, y con eso genera el proyecto completo: entry point, config, módulo raíz, CORS, `.env.example`, script de desarrollo, un kit de pruebas PHPUnit listo para correr (`composer test`), CI de GitHub Actions y la documentación de la API en `docs/openapi.yaml` (con opción de servir Swagger UI en `/docs`).

**Agregar cosas a un proyecto existente.** *"agrega un módulo de facturas"*, *"crea la entidad clientes"*, *"necesito un middleware que valide el tenant"*. Claude detecta la estructura real del proyecto y se adapta a ella.

## Qué trae

```
plugins/phobos/skills/phobos3/
├── SKILL.md                  # flujo, reglas de oro, checklist
├── references/
│   ├── core.md               # routing, módulos, DI, middleware, request/response
│   ├── database.md           # entidades, query builder, transacciones
│   ├── testing.md            # PHPUnit: cómo se prueba una app Phobos
│   ├── api-docs.md           # OpenAPI: cómo se documenta una app Phobos
│   └── anti-patterns.md      # los errores que se repiten
└── templates/
    ├── project/              # esqueleto completo de un proyecto
    │   └── database/         # config + .env por motor: mysql | postgres | sqlite
    ├── testing/              # kit de PHPUnit: bases, bootstrap, schema, ejemplos
    ├── docs/                 # openapi.yaml sembrado + README
    └── generators/           # module, controller, entity, service, middleware, provider, test
```

Las referencias están verificadas contra el código fuente de los paquetes, no contra la documentación.

### Portabilidad a otros agentes

El plugin es la entrega nativa para Claude Code (auto-activación, `/phobos:phobos3`). Para usar el
mismo conocimiento desde **Codex u otro agente**, la raíz del repo trae un [`AGENTS.md`](AGENTS.md):
un índice delgado con las reglas no-negociables y punteros a las referencias/templates para carga
on-demand. No hay que rehacer nada — el contenido (referencias + templates) es agnóstico de
herramienta; solo cambia el envoltorio. El `AGENTS.md` también sirve como memoria de proyecto para
Claude Code cuando trabajas dentro de un repo Phobos sin el plugin cargado.

Cada motor tiene su propia carpeta bajo `templates/project/database/`: el proyecto generado recibe un `config/database.php` completo y correcto para **su** motor, no una plantilla con drivers comentados. Las claves no son intercambiables entre motores (SQLite no tiene `host` ni `username`; PostgreSQL no tiene `collation`; MySQL no tiene `search_path`), y el skill lo respeta.

## Versiones cubiertas

| Paquete | Versión |
|---|---|
| `mongoose-studio/phobos-framework` | 3.3.0 |
| `mongoose-studio/phobos-framework-database` | 3.2.1 |
| `mongoose-studio/phobos-framework-database-mysql` | 3.2.0 |
| `mongoose-studio/phobos-framework-database-sqlite` | 3.2.0 |
| `mongoose-studio/phobos-framework-database-postgres` | 3.2.0 |

**Requiere PHP 8.4+**: los paquetes declaran `>=8.4` y el código usa sintaxis de 8.4. Los proyectos generados exigen `>=8.4`.

Los tres motores tienen driver: MySQL/MariaDB, SQLite (dev y tests) y PostgreSQL (schemas, JSONB, RETURNING, UUIDv7). La capa genera SQL correcto por dialecto.

## Desarrollo

Para probar cambios sin instalar:

```bash
claude --plugin-dir ./plugins/phobos
```

Y dentro de la sesión, `/reload-plugins` recarga sin reiniciar.

Antes de publicar un cambio:

```bash
claude plugin validate ./plugins/phobos
```

Al actualizar: sube la `version` en `plugins/phobos/.claude-plugin/plugin.json` **y** en `.claude-plugin/marketplace.json` (si no, los usuarios instalados no reciben la actualización), commitea y pushea. Del otro lado se actualiza con `/plugin marketplace update`.

## Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE.txt) para más detalles.

## Autor

**Marcel Rojas**  
[marcelrojas16@gmail.com](mailto:marcelrojas16@gmail.com)  
__Mongoose Studio__

## Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/amazing-feature`)
3. Commit tus cambios (`git commit -m 'Add amazing feature'`)
4. Push a la rama (`git push origin feature/amazing-feature`)
5. Abre un Pull Request

---

**Phobos Framework** by Mongoose Studio
