<?php

declare(strict_types=1);

namespace App\Tests;

use App\Service\Greeter;
use PHPUnit\Framework\TestCase;

final class GreeterTest extends TestCase
{
    public function testGreet(): void
    {
        self::assertSame('Bonjour Manu', (new Greeter())->greet('Manu'));
    }
}
