<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

class RolesAndPermissionsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Reset cached roles and permissions
        app()[\Spatie\Permission\PermissionRegistrar::class]->forgetCachedPermissions();

        // Create Roles
        $superAdmin = Role::firstOrCreate(['name' => 'super_admin']);
        $universitySupervisor = Role::firstOrCreate(['name' => 'university_supervisor']);

        // Create Permissions
        $permissions = [
            'view_any_internship',
            'view_internship',
            'view_any_report',
            'view_report',
            'manage_users',
        ];

        foreach ($permissions as $permission) {
            Permission::firstOrCreate(['name' => $permission]);
        }

        // Assign basic viewing permissions to supervisor
        $universitySupervisor->givePermissionTo([
            'view_any_internship',
            'view_internship',
            'view_any_report',
            'view_report',
        ]);
        
        $superAdmin->givePermissionTo(Permission::all());
    }
}
