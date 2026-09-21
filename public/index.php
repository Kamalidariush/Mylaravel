<?php

use Illuminate\Foundation\Application;
use Illuminate\Http\Request;

define('LARAVEL_START', microtime(true));

// Determine if the application is in maintenance mode...
if (file_exists($maintenance = __DIR__.'/../storage/framework/maintenance.php')) {
    require $maintenance;
}

// Prevent OpenTelemetry SDK from initializing during Composer autoload.
putenv('OTEL_PHP_AUTOLOAD_ENABLED=false');

// Register the Composer autoloader...
require __DIR__.'/../vendor/autoload.php';

// Register OTLP exporters before OpenTelemetry SDK initialization.
require_once __DIR__.'/../vendor/open-telemetry/exporter-otlp/_register.php';

// Enable OpenTelemetry SDK initialization.
putenv('OTEL_PHP_AUTOLOAD_ENABLED=true');

// Initialize OpenTelemetry after OTLP exporters have been registered.
\OpenTelemetry\SDK\SdkAutoloader::autoload();

// Bootstrap Laravel and handle the request...
/** @var Application $app */
$app = require_once __DIR__.'/../bootstrap/app.php';

$app->handleRequest(Request::capture());