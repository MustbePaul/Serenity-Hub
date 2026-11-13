<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\Response;

class UssdController extends Controller
{
    public function handle(Request $request): Response
    {
        $text = trim((string) $request->input('text', ''));

        $message = match ($text) {
            '' => "CON Serenity Hub\n1. I need to feel calmer\n2. Daily wellbeing tip\n3. Find support\n0. About this service",
            '1' => "CON Breathe in for 4, hold for 2, breathe out for 6. Repeat 4 times.\n1. Another exercise\n0. Main menu",
            '1*1' => 'END Name 5 things you see, 4 you feel, 3 you hear, 2 you smell, and 1 you taste.',
            '2' => 'END Today, make the next step small: drink water, stretch, or contact someone you trust.',
            '3' => "CON Choose support\n1. Talk to someone I trust\n2. Professional care information\n3. Immediate danger",
            '3*1' => 'END Consider contacting a trusted person or community health worker.',
            '3*2' => 'END This prototype will list verified local care after partner approval. It cannot currently book care.',
            '3*3' => 'END If anyone is in immediate danger, contact local emergency services or go to the nearest health facility now.',
            '0' => 'END Serenity Hub offers general wellbeing information, not diagnosis, treatment, or emergency response.',
            default => 'END Invalid option. Please dial again.',
        };

        return response($message, 200)->header('Content-Type', 'text/plain; charset=UTF-8');
    }
}
