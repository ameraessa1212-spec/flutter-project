<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;

class RolePermissionSeeder extends Seeder
{
    public function run(): void
    {
        $roles = [
            'super_admin',
            'operations',
            'supervisor',
            'content_manager',
            'support',
        ];

        $permissions = [
            'dashboard.view',
            'users.view',
            'users.manage',
            'companies.view',
            'companies.manage',
            'opportunities.view',
            'opportunities.manage',
            'applications.view',
            'applications.review',
            'internships.view',
            'internships.manage',
            'reports.view',
            'reports.review',
            'schedules.view',
            'schedules.manage',
            'notifications.view',
            'notifications.manage',
            'content.manage',
            'chat.view',
            'settings.manage',
        ];

        foreach ($permissions as $permission) {
            Permission::findOrCreate($permission, 'web');
        }

        foreach ($roles as $roleName) {
            Role::findOrCreate($roleName, 'web');
        }

        Role::findByName('super_admin')->syncPermissions(Permission::all());

        Role::findByName('operations')->syncPermissions([
            'dashboard.view',
            'users.view',
            'companies.view',
            'companies.manage',
            'opportunities.view',
            'opportunities.manage',
            'applications.view',
            'applications.review',
            'internships.view',
            'internships.manage',
            'reports.view',
            'reports.review',
            'notifications.view',
            'notifications.manage',
            'chat.view',
        ]);

        Role::findByName('supervisor')->syncPermissions([
            'dashboard.view',
            'applications.view',
            'internships.view',
            'reports.view',
            'reports.review',
            'schedules.view',
            'schedules.manage',
            'chat.view',
            'notifications.view',
        ]);

        Role::findByName('content_manager')->syncPermissions([
            'dashboard.view',
            'content.manage',
            'notifications.view',
            'notifications.manage',
        ]);

        Role::findByName('support')->syncPermissions([
            'dashboard.view',
            'users.view',
            'users.manage',
            'applications.view',
            'internships.view',
            'notifications.view',
            'notifications.manage',
        ]);

        $admin = User::query()->firstOrCreate(
            ['email' => 'admin@waslaa.local'],
            [
                'first_name' => 'System',
                'last_name' => 'Admin',
                'name' => 'System Admin',
                'username' => 'admin',
                'phone' => '0900000000',
                'password' => Hash::make('Admin@12345'),
                'role' => 'super_admin',
                'status' => 'active',
                'email_verified_at' => now(),
                'phone_verified_at' => now(),
            ]
        );

        $admin->assignRole('super_admin');
    }
}
