<?php

declare(strict_types=1);

namespace App\Controller;

use App\Service\Greeter;

final class HomeController
{
    public function __construct(private Greeter $greeter)
    {
    }

    public function index(): string
    {
        return $this->greeter->greet('Manu');
    }
}
