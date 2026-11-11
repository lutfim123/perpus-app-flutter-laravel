<?php

namespace Tests\Feature;

use App\Models\Book;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class BookApiTest extends TestCase
{
    use RefreshDatabase;

    private function login(): void
    {
        Sanctum::actingAs(User::factory()->create());
    }

    public function test_guest_cannot_access_books(): void
    {
        $this->getJson('/api/books')->assertUnauthorized();
    }

    public function test_can_list_and_search_books(): void
    {
        $this->login();
        Book::factory()->create(['title' => 'Laskar Pelangi']);
        Book::factory(3)->create();

        $this->getJson('/api/books')->assertOk()->assertJsonCount(4, 'data');

        $this->getJson('/api/books?search=Laskar')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.title', 'Laskar Pelangi');
    }

    public function test_can_create_book(): void
    {
        $this->login();

        $payload = [
            'title' => 'Bumi Manusia',
            'author' => 'Pramoedya Ananta Toer',
            'publisher' => 'Hasta Mitra',
            'isbn' => '9789799731234',
            'published_year' => 1980,
            'stock' => 5,
        ];

        $this->postJson('/api/books', $payload)
            ->assertCreated()
            ->assertJsonPath('data.title', 'Bumi Manusia');

        $this->assertDatabaseHas('books', ['isbn' => '9789799731234']);
    }

    public function test_create_book_validation(): void
    {
        $this->login();

        $this->postJson('/api/books', [])
            ->assertStatus(422)
            ->assertJsonValidationErrors(['title', 'author', 'isbn', 'published_year', 'stock']);
    }

    public function test_can_show_update_and_delete_book(): void
    {
        $this->login();

        $book = Book::factory()->create();

        $this->getJson("/api/books/{$book->id}")
            ->assertOk()
            ->assertJsonPath('data.id', $book->id);

        $this->patchJson("/api/books/{$book->id}", ['stock' => 99])
            ->assertOk()
            ->assertJsonPath('data.stock', 99);

        $this->deleteJson("/api/books/{$book->id}")->assertOk();

        $this->assertDatabaseMissing('books', ['id' => $book->id]);
        $this->getJson("/api/books/{$book->id}")->assertNotFound();
    }
}
