<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;

#[Fillable(['text', 'author', 'theme', 'type', 'active', 'display_date', 'created_by'])]
class QuoteAffirmation extends Model
{
    protected $table = 'quotes_affirmations';

    protected function casts(): array
    {
        return [
            'active' => 'boolean',
            'display_date' => 'date',
        ];
    }
}
