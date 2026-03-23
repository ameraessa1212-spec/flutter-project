<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DashboardContent extends Model
{
    use HasFactory;

    protected $fillable = [
        'type',
        'title',
        'subtitle',
        'image_asset',
        'image_path',
        'icon_key',
        'badge',
        'sort_order',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'is_active' => 'bool',
        ];
    }
}