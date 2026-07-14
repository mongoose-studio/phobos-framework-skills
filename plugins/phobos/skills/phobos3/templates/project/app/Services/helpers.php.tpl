<?php

/**
 * Helpers globales de la aplicación.
 * Se cargan vía el bloque "files" del autoload en composer.json.
 *
 * Envuelve siempre en function_exists(): si el nombre choca con un helper
 * del framework, el fatal error es incomprensible.
 */

// if (!function_exists('auth')) {
//     function auth(): \{{NAMESPACE}}\Services\AuthContext {
//         return inject(\{{NAMESPACE}}\Services\AuthContext::class);
//     }
// }