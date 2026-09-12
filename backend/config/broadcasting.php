<?php

return [
    'default' => env('BROADCAST_CONNECTION', 'null'),

    'connections' => [
        'reverb' => [
            'driver' => 'reverb',
            'key' => env('REVERB_APP_KEY', 'local-serenity-key'),
            'secret' => env('REVERB_APP_SECRET', 'local-serenity-secret'),
            'app_id' => env('REVERB_APP_ID', 'local-serenity-app'),
            'options' => [
                'host' => env('REVERB_HOST', '127.0.0.1'),
                'port' => env('REVERB_PORT', 8080),
                'scheme' => env('REVERB_SCHEME', 'http'),
                'useTLS' => env('REVERB_SCHEME', 'http') === 'https',
            ],
        ],

        'null' => [
            'driver' => 'null',
        ],
    ],
];
