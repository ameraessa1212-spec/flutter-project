<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserSetting extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'language',
        'push_notifications_enabled',
        'email_notifications_enabled',
        'chat_notifications_enabled',
        'theme',
    ];

    protected function casts(): array
    {
        return [
            'push_notifications_enabled' => 'boolean',
            'email_notifications_enabled' => 'boolean',
            'chat_notifications_enabled' => 'boolean',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
