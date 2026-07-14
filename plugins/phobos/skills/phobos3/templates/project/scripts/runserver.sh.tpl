#!/bin/bash
#
# Servidor de desarrollo ({{PROJECT_TITLE}}).
# Uso: ./scripts/runserver.sh [puerto]
#
set -euo pipefail

HOST="0.0.0.0"
PORT="${1:-{{PORT}}}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PUBLIC_DIR="$ROOT_DIR/public"

if [ ! -f "$ROOT_DIR/.env" ]; then
    echo "No existe .env — copiando desde .env.example"
    cp "$ROOT_DIR/.env.example" "$ROOT_DIR/.env"
fi

if [ ! -d "$ROOT_DIR/vendor" ]; then
    echo "No existe vendor/ — ejecuta: composer install"
    exit 1
fi

echo "{{PROJECT_TITLE}} → http://localhost:$PORT"
echo "Health check     → http://localhost:$PORT/health"
echo ""

php -S "$HOST:$PORT" -t "$PUBLIC_DIR" "$PUBLIC_DIR/router.php"