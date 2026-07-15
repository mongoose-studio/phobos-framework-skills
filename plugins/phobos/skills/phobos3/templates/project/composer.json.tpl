{
    "name": "{{VENDOR}}/{{PROJECT_NAME}}",
    "description": "{{DESCRIPTION}}",
    "type": "project",
    "require": {
        "php": ">=8.4",
        "ext-pdo": "*",
        "mongoose-studio/phobos-framework": "^3.3",
        "mongoose-studio/phobos-framework-database": "^3.2.1",
        "{{DB_DRIVER_PACKAGE}}": "^3.2"
    },
    "require-dev": {
        "phpunit/phpunit": "^11.0",
        "mongoose-studio/phobos-framework-database-sqlite": "^3.2"
    },
    "autoload": {
        "psr-4": {
            "{{NAMESPACE}}\\": "app/"
        },
        "files": [
            "app/Services/helpers.php"
        ]
    },
    "autoload-dev": {
        "psr-4": {
            "{{NAMESPACE}}\\Tests\\": "tests/"
        }
    },
    "scripts": {
        "test": "phpunit",
        "test:unit": "phpunit --testsuite Unit",
        "test:feature": "phpunit --testsuite Feature",
        "test:coverage": "phpunit --coverage-html coverage"
    },
    "config": {
        "optimize-autoloader": true,
        "sort-packages": true
    }
}