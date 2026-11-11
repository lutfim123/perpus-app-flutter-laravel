<?php

namespace Tests\Unit;

use App\Models\Book;
use PHPUnit\Framework\TestCase;

class BookModelTest extends TestCase
{
    public function test_book_fillable_fields(): void
    {
        $this->assertSame(
            ['title', 'author', 'publisher', 'isbn', 'published_year', 'stock', 'description'],
            (new Book)->getFillable()
        );
    }
}
