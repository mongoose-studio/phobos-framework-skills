name: CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest
    name: Tests (PHP ${{ matrix.php }})
    strategy:
      fail-fast: false
      matrix:
        php: ["8.4"]

    steps:
      - uses: actions/checkout@v4

      - name: Configurar PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: ${{ matrix.php }}
          # pdo_sqlite basta: los tests corren en SQLite :memory:, sin servidor de BD.
          extensions: pdo, pdo_sqlite
          coverage: none

      - name: Cachear dependencias de Composer
        uses: actions/cache@v4
        with:
          path: vendor
          key: composer-${{ runner.os }}-php${{ matrix.php }}-${{ hashFiles('composer.lock') }}
          restore-keys: composer-${{ runner.os }}-php${{ matrix.php }}-

      - name: Instalar dependencias
        run: composer install --no-interaction --prefer-dist --no-progress

      - name: Correr tests
        run: composer test
