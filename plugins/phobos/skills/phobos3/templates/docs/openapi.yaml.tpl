openapi: 3.1.0

info:
  title: {{PROJECT_TITLE}}
  description: {{DESCRIPTION}}
  version: 1.0.0

servers:
  - url: http://localhost:{{PORT}}
    description: Desarrollo local

tags:
  - name: Sistema
    description: Salud y metadatos del servicio
  - name: {{MODULE}}
    description: Gestión de {{ROUTE_PREFIX}}

paths:
  /health:
    get:
      tags: [Sistema]
      summary: Health check
      operationId: health
      responses:
        "200":
          description: El servicio está operativo
          content:
            application/json:
              schema:
                type: object
                properties:
                  status: { type: string, example: ok }
                  service: { type: string }
                  timestamp: { type: number }

  # ---------------------------------------------------------------------------
  # Recurso de ejemplo. Refleja el módulo {{MODULE}} generado por la skill.
  # Al agregar o cambiar rutas, actualiza estos paths: este archivo es la
  # fuente de verdad de la API, y se mantiene a mano (sin anotaciones ni deps).
  # ---------------------------------------------------------------------------
  /v1/{{ROUTE_PREFIX}}:
    get:
      tags: [{{MODULE}}]
      summary: Lista {{ROUTE_PREFIX}}
      operationId: list{{MODULE}}
      parameters:
        - $ref: "#/components/parameters/Page"
      responses:
        "200":
          description: Página de resultados
          content:
            application/json:
              schema:
                type: object
                properties:
                  items:
                    type: array
                    items: { $ref: "#/components/schemas/{{MODULE}}" }
                  page: { type: integer, example: 1 }
    post:
      tags: [{{MODULE}}]
      summary: Crea un {{ROUTE_PREFIX}}
      operationId: create{{MODULE}}
      requestBody:
        required: true
        content:
          application/json:
            schema: { $ref: "#/components/schemas/{{MODULE}}Input" }
      responses:
        "201":
          description: Creado
          content:
            application/json:
              schema:
                type: object
                properties:
                  item: { $ref: "#/components/schemas/{{MODULE}}" }
        "422": { $ref: "#/components/responses/ValidationError" }

  /v1/{{ROUTE_PREFIX}}/{uuid}:
    parameters:
      - $ref: "#/components/parameters/Uuid"
    get:
      tags: [{{MODULE}}]
      summary: Obtiene un {{ROUTE_PREFIX}} por uuid
      operationId: get{{MODULE}}
      responses:
        "200":
          description: Encontrado
          content:
            application/json:
              schema:
                type: object
                properties:
                  item: { $ref: "#/components/schemas/{{MODULE}}" }
        "404": { $ref: "#/components/responses/NotFound" }
    patch:
      tags: [{{MODULE}}]
      summary: Actualiza un {{ROUTE_PREFIX}}
      operationId: update{{MODULE}}
      requestBody:
        required: true
        content:
          application/json:
            schema: { $ref: "#/components/schemas/{{MODULE}}Input" }
      responses:
        "200":
          description: Actualizado
          content:
            application/json:
              schema:
                type: object
                properties:
                  item: { $ref: "#/components/schemas/{{MODULE}}" }
        "404": { $ref: "#/components/responses/NotFound" }
        "422": { $ref: "#/components/responses/ValidationError" }
    delete:
      tags: [{{MODULE}}]
      summary: Elimina un {{ROUTE_PREFIX}} (soft delete)
      operationId: delete{{MODULE}}
      responses:
        "204":
          description: Eliminado (sin contenido)
        "404": { $ref: "#/components/responses/NotFound" }

components:
  parameters:
    Uuid:
      name: uuid
      in: path
      required: true
      description: Identificador público del recurso
      schema: { type: string, format: uuid }
    Page:
      name: page
      in: query
      required: false
      description: Número de página (desde 1)
      schema: { type: integer, minimum: 1, default: 1 }

  schemas:
    {{MODULE}}:
      type: object
      properties:
        id: { type: integer, readOnly: true }
        uuid: { type: string, format: uuid, readOnly: true }
        cliente_id: { type: integer }
        codigo: { type: [string, "null"] }
        total: { type: [number, "null"] }
        is_active: { type: integer, enum: [0, 1], readOnly: true }
        created_at: { type: [string, "null"], readOnly: true }

    {{MODULE}}Input:
      type: object
      required: [cliente_id]
      properties:
        cliente_id: { type: integer }
        codigo: { type: string }
        total: { type: number }

    # Forma exacta de un error del framework (HttpException::toArray()).
    Error:
      type: object
      properties:
        error: { type: string, example: Not Found }
        message: { type: string }
        status_code: { type: integer }

    # 422: además de lo anterior, el detalle campo → mensaje (ValidationException).
    ValidationError:
      type: object
      properties:
        error: { type: string, example: Unprocessable Entity }
        message: { type: string }
        status_code: { type: integer, example: 422 }
        errors:
          type: object
          additionalProperties: { type: string }
          example: { email: "El email es requerido" }

  responses:
    NotFound:
      description: Recurso no encontrado
      content:
        application/json:
          schema: { $ref: "#/components/schemas/Error" }
    ValidationError:
      description: Datos inválidos
      content:
        application/json:
          schema: { $ref: "#/components/schemas/ValidationError" }
