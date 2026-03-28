<?php

namespace App\Filament\Resources\Internships\Schemas;

use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class InternshipInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('معلومات التدريب')
                    ->schema([
                        TextEntry::make('title')->label('المسمى الوظيفي للتدريب'),
                        TextEntry::make('student.name')->label('الطالب'),
                        TextEntry::make('company.name')->label('الشركة'),
                        TextEntry::make('opportunity.title')->label('فرصة التدريب')->placeholder('-'),
                        TextEntry::make('supervisor.name')->label('المشرف الميداني/الأكاديمي')->placeholder('-'),
                        TextEntry::make('status')
                            ->label('حالة التدريب')
                            ->badge()
                            ->color(fn ($state) => $state === 'active' ? 'success' : ($state === 'completed' ? 'info' : 'warning')),
                        TextEntry::make('start_date')->label('تاريخ البداية')->date()->placeholder('-'),
                        TextEntry::make('end_date')->label('تاريخ النهاية')->date()->placeholder('-'),
                        TextEntry::make('report_due_date')->label('موعد تسليم التقرير')->date()->placeholder('-'),
                        TextEntry::make('notes')->label('ملاحظات إضافية')->placeholder('-')->columnSpanFull(),
                    ])
                    ->columns(2),

                Section::make('التقييم من قبل الشركة')
                    ->relationship('companyEvaluation')
                    ->visible(fn ($record) => $record->companyEvaluation()->exists())
                    ->schema([
                        TextEntry::make('evaluator.name')->label('المُقيِّم (من الشركة)')->placeholder('-'),
                        TextEntry::make('total_score')
                            ->label('المجموع النهائي')
                            ->badge()
                            ->color(fn ($state) => $state >= 90 ? 'success' : ($state >= 75 ? 'warning' : 'danger'))
                            ->formatStateUsing(fn ($state) => $state . ' من 100'),
                        TextEntry::make('detailed_scores')
                            ->label('تفاصيل درجات التقييم')
                            ->formatStateUsing(function ($state): string {
                                if (! is_array($state) || $state === []) {
                                    return 'لا توجد تفاصيل درجات';
                                }

                                $keys = array_keys($state);
                                $isAssoc = $keys !== range(0, count($state) - 1);

                                if ($isAssoc) {
                                    return collect($state)
                                        ->map(fn ($value, $key) => e((string) $key) . ': ' . e((string) $value) . ' / 100')
                                        ->implode('<br>');
                                }

                                return collect($state)
                                    ->map(fn ($value, $index) => 'بند ' . ($index + 1) . ': ' . e((string) $value) . ' / 100')
                                    ->implode('<br>');
                            })
                            ->html()
                            ->columnSpanFull(),
                        TextEntry::make('comments')->label('التعليقات والملاحظات')->placeholder('لم يترك المُقيّم تعليقاً.')->columnSpanFull(),
                    ])
                    ->columns(2),
            ]);
    }
}
