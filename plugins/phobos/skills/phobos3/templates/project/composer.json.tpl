{
    "name": "{{VENDOR}}/{{PROJECT_NAME}}",
    "description": "{{DESCRIPTION}}",
    "type": "project",
    "require": {
        "php": ">=8.4",
        "ext-pdo": "*",
        "mongoose-studio/phobos-framework": "^3.1",
        "mongoose-studio/phobos-framework-database": "^3.2",
        "mongoose-studio/phobos-framework-database-mysql": "^3.2"
    },
    "autoload": {
        "psr-4": {
            "{{NAMESPACE}}\\": "app/"
        },
        "files": [
            "app/Services/helpers.php"
        ]
    },
    "config": {
        "optimize-autoloader": true,
        "sort-packages": true
    }
}