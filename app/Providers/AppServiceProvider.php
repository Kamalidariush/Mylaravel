<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Iamfarhad\Prometheus\Collectors\HttpRequestCollector;
use Iamfarhad\Prometheus\Http\Middleware\PrometheusMetricsMiddleware;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        $this->app->bind(
            PrometheusMetricsMiddleware::class,
            function ($app) {
                return new PrometheusMetricsMiddleware(
                    $app->make(HttpRequestCollector::class)
                );
            }
        );
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        //
    }
}