/vendor/
.env
.idea/
.DS_Store
*.log
/storage/logs/*

# Tests
/.phpunit.cache/
/coverage/

# SQLite: la base local no se commitea (el WAL y el shm, tampoco)
/storage/*.sqlite
/storage/*.sqlite-wal
/storage/*.sqlite-shm

# composer.lock SÍ se commitea: es una aplicación, no una librería.
# Es lo que garantiza que todos instalen exactamente las mismas versiones.