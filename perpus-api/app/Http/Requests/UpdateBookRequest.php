<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use OpenApi\Attributes as OA;

#[OA\Schema(
    schema: 'UpdateBookRequest',
    description: 'Semua field opsional (PATCH semantics). Kirim hanya field yang ingin diubah.',
    properties: [
        new OA\Property(property: 'title', type: 'string', maxLength: 255, nullable: true, example: 'Bumi Manusia'),
        new OA\Property(property: 'author', type: 'string', maxLength: 255, nullable: true, example: 'Pramoedya Ananta Toer'),
        new OA\Property(property: 'publisher', type: 'string', nullable: true, example: 'Hasta Mitra'),
        new OA\Property(property: 'isbn', type: 'string', maxLength: 20, nullable: true, example: '9789799731234'),
        new OA\Property(property: 'published_year', type: 'integer', minimum: 1000, nullable: true, example: 1980),
        new OA\Property(property: 'stock', type: 'integer', minimum: 0, nullable: true, example: 5),
        new OA\Property(property: 'description', type: 'string', nullable: true, example: 'Tetralogi Buru bagian pertama.'),
    ]
)]
class UpdateBookRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'title' => ['sometimes', 'required', 'string', 'max:255'],
            'author' => ['sometimes', 'required', 'string', 'max:255'],
            'publisher' => ['sometimes', 'nullable', 'string', 'max:255'],
            'isbn' => [
                'sometimes', 'required', 'string', 'max:20',
                Rule::unique('books', 'isbn')->ignore($this->route('book')),
            ],
            'published_year' => ['sometimes', 'required', 'integer', 'min:1000', 'max:'.date('Y')],
            'stock' => ['sometimes', 'required', 'integer', 'min:0'],
            'description' => ['sometimes', 'nullable', 'string'],
        ];
    }
}
