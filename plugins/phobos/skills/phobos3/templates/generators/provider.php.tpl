<?php

namespace {{NAMESPACE}}\Providers;

use PhobosFramework\Core\Container;
use PhobosFramework\Core\ServiceProvider;

/**
 * Provider {{PROVIDER}}.
 *
 * Agrégalo al array providers() del MÓDULO RAÍZ (ApiModule):
 * los providers de módulos anidados no se registran.
 */
class {{PROVIDER}}Provider extends ServiceProvider {

    /**
     * Registro de bindings. Corre antes que cualquier boot().
     */
    public function register(Container $container): void {
        // singleton: una instancia por request
        // $container->singleton(MiService::class, fn($c) => new MiService($c->make(Otro::class)));

        // bind: instancia nueva cada vez que se pide
        // $container->bind(RepoInterface::class, RepoMySQL::class);
    }

    /**
     * Corre cuando TODOS los providers ya se registraron.
     * Aquí es seguro resolver servicios de otros providers.
     */
    public function boot(Container $container): void {
    }
}