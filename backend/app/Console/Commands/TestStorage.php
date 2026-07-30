<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Storage;

class TestStorage extends Command
{
    protected $signature = 'storage:test';
    protected $description = 'Test storage configuration untuk bukti transfer';

    public function handle()
    {
        $this->info('===========================================');
        $this->info('TEST STORAGE CONFIGURATION');
        $this->info('===========================================');
        $this->newLine();

        // 1. Check symbolic link
        $this->info('[1] Checking symbolic link...');
        $publicStoragePath = public_path('storage');
        if (is_link($publicStoragePath) || is_dir($publicStoragePath)) {
            $this->line('✓ public/storage exists');
            $target = is_link($publicStoragePath) ? readlink($publicStoragePath) : 'directory';
            $this->line("  Target: $target");
        } else {
            $this->error('✗ public/storage NOT FOUND');
            $this->warn('  Run: php artisan storage:link');
        }
        $this->newLine();

        // 2. Check payment_proofs folder
        $this->info('[2] Checking payment_proofs folder...');
        $paymentProofsPath = storage_path('app/public/payment_proofs');
        if (is_dir($paymentProofsPath)) {
            $this->line('✓ storage/app/public/payment_proofs exists');
            $files = glob($paymentProofsPath . '/*');
            $this->line('  Files: ' . count($files));
        } else {
            $this->error('✗ payment_proofs folder NOT FOUND');
            $this->warn('  Run: mkdir -p storage/app/public/payment_proofs');
        }
        $this->newLine();

        // 3. Test Storage::disk()
        $this->info('[3] Testing Storage::disk(\'public\')...');
        try {
            $disk = Storage::disk('public');
            $this->line('✓ Public disk accessible');
            
            // Test put/get/delete
            $testFile = 'test-' . time() . '.txt';
            $testPath = 'payment_proofs/' . $testFile;
            
            $disk->put($testPath, 'Test file from storage:test command');
            $this->line("✓ Created test file: $testPath");
            
            $url = $disk->url($testPath);
            $this->line("✓ URL: $url");
            
            if ($disk->exists($testPath)) {
                $disk->delete($testPath);
                $this->line('✓ Deleted test file');
            }
        } catch (\Exception $e) {
            $this->error('✗ Error: ' . $e->getMessage());
        }
        $this->newLine();

        // 4. Check actual payment proofs
        $this->info('[4] Checking existing payment proofs...');
        $proofs = Storage::disk('public')->files('payment_proofs');
        if (count($proofs) > 0) {
            $this->line('✓ Found ' . count($proofs) . ' files:');
            foreach (array_slice($proofs, 0, 5) as $proof) {
                $url = Storage::disk('public')->url($proof);
                $this->line("  - $proof");
                $this->line("    URL: $url");
            }
            if (count($proofs) > 5) {
                $this->line('  ... and ' . (count($proofs) - 5) . ' more');
            }
        } else {
            $this->warn('  No payment proof files found');
        }
        $this->newLine();

        // 5. Recommendations
        $this->info('[5] Recommendations:');
        
        if (!is_link($publicStoragePath) && !is_dir($publicStoragePath)) {
            $this->warn('• Run: php artisan storage:link');
        }
        
        if (!is_dir($paymentProofsPath)) {
            $this->warn('• Create folder: mkdir storage/app/public/payment_proofs');
        }
        
        $this->newLine();
        $this->info('===========================================');
        $this->info('TEST COMPLETE');
        $this->info('===========================================');
        
        return 0;
    }
}

