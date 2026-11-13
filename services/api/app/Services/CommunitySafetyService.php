<?php

namespace App\Services;

class CommunitySafetyService
{
    public function classify(string $body): array
    {
        $text = mb_strtolower($body);
        $flags = [];

        if ($this->containsAny($text, ['kill myself', 'end my life', 'suicide', 'self harm', 'hurt myself'])) {
            $flags[] = 'possible_self_harm_or_crisis';
        }

        if ($this->containsAny($text, ['i will kill', 'i am going to kill', 'bomb', 'shoot them', 'stab them'])) {
            $flags[] = 'threat_or_violence';
        }

        if ($this->containsAny($text, ['idiot', 'worthless', 'shut up', 'hate you'])) {
            $flags[] = 'harassment';
        }

        if ($this->containsPersonalInfo($body, $text)) {
            $flags[] = 'personally_identifying_information';
        }

        if ($this->containsAny($text, ['buy now', 'free money', 'crypto giveaway', 'click this link'])) {
            $flags[] = 'spam';
        }

        return [
            'flags' => array_values(array_unique($flags)),
            'requires_review' => count($flags) > 0,
            'supportive_notice' => in_array('possible_self_harm_or_crisis', $flags, true)
                ? 'If you might be in immediate danger, please contact local emergency services or a verified crisis support contact now.'
                : null,
        ];
    }

    private function containsAny(string $text, array $needles): bool
    {
        foreach ($needles as $needle) {
            if (str_contains($text, $needle)) {
                return true;
            }
        }

        return false;
    }

    private function containsPersonalInfo(string $body, string $text): bool
    {
        if (preg_match('/[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,}/i', $body)) {
            return true;
        }

        if (preg_match('/\b(?:whats?app|telegram|signal|snapchat|instagram|dm me|text me|call me|my number|phone number|email me)\b/i', $body)
            && preg_match('/(?:\+?\d[\s().-]?){7,}\d/', $body)) {
            return true;
        }

        if (preg_match('/\b(?:https?:\/\/|www\.)\S+/i', $body)
            && $this->containsAny($text, ['contact me', 'message me', 'dm me', 'outside the app'])) {
            return true;
        }

        if (preg_match('/\b(?:my address is|i live at|come to my house|home address)\b/i', $body)) {
            return true;
        }

        return false;
    }
}
