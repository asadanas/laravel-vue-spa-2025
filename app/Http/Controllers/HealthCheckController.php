<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Redis;

class HealthCheckController extends Controller
{
    public function check()
    {
        $errors = [];

        // Check database
        try {
            DB::connection()->getPdo();
        } catch (\Exception $e) {
            $errors[] = 'Database connection failed: ' . $e->getMessage();
        }

        // Check Redis (if configured)
        if (config('database.default') === 'redis' || config('cache.default') === 'redis') {
            try {
                Redis::ping();
            } catch (\Exception $e) {
                $errors[] = 'Redis connection failed: ' . $e->getMessage();
            }
        }

        // Check cache
        try {
            Cache::put('health-check', 'ok', 1);
            if (Cache::get('health-check') !== 'ok') {
                $errors[] = 'Cache write/read failed';
            }
        } catch (\Exception $e) {
            $errors[] = 'Cache failed: ' . $e->getMessage();
        }

        if (!empty($errors)) {
            return response()->json([
                'status' => 'unhealthy',
                'errors' => $errors
            ], 503);
        }

        return response()->json(['status' => 'healthy']);
    }
}
