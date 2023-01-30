<?php

namespace App\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldBeUnique;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Acamposm\Ping\Ping;
use Acamposm\Ping\PingCommandBuilder;
use App\Models\Computer;
use App\Support\Concerns\InteractsWithBanner;
use ErrorException;

class PingComputer implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels, InteractsWithBanner;

    /**
     * The computer instance.
     *
     * @var \App\Models\Computer
     */
    public $computer;

    /**
     * Create a new job instance.
     *
     * @return void
     */
    public function __construct(Computer $computer)
    {
        $this->computer = $computer;
    }

    /**
     * Execute the job.
     *
     * @return void
     */
    public function handle()
    {              
        $ipAddress = $this->computer->ip_address;

        $ping = new \JJG\Ping($ipAddress);
        $ping->setTimeout(5);

        $latency = $ping->ping();

        if ($latency !== false) {
            $this->computer->status = 'on';
        } else {
            $this->computer->status = 'off';
        }

        $this->computer->touch('status_updated_at');

        $this->computer->save();
    }
}
