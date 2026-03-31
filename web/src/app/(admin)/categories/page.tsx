// File: src/app/(admin)/categories/page.tsx
'use client';

import { useState } from 'react';
import { Plus, Edit, Trash2, Music, GraduationCap, Trophy, Construction, ChevronLeft, ChevronRight } from 'lucide-react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { Button, Card } from '@/core/components';
import { mockCategories, categoryStats } from '@/features/categories/mock/mock-categories';
import { cn } from '@/core/lib/utils';
import type { Category } from '@/features/categories/types';

const iconMap: Record<string, React.ElementType> = {
  music: Music,
  'graduation-cap': GraduationCap,
  trophy: Trophy,
  construction: Construction,
};

const filterCategories = ['ALL', 'ENTERTAINMENT', 'EDUCATION', 'NETWORKING', 'CHARITY'];

export default function CategoriesPage() {
  const [selectedFilter, setSelectedFilter] = useState('ALL');
  const router = useRouter();

  return (
    <div className="space-y-8">
      {/* Header Section */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold text-slate-900 tracking-tight">
            Category Management
          </h2>
          <p className="text-slate-500 text-sm font-medium mt-1">
            Organize and control event classification across the platform.
          </p>
        </div>
        <Button
          variant="primary"
          onClick={() => router.push('/categories/create')}
          className="rounded-xl shadow-lg shadow-amber-500/30"
          leftIcon={<Plus className="w-5 h-5" />}
        >
          Create New Category
        </Button>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card className="glass-card border-none rounded-2xl p-6">
          <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1">
            Total Categories
          </p>
          <p className="text-3xl font-extrabold text-slate-900">24</p>
        </Card>
        <Card className="glass-card border-none rounded-2xl p-6">
          <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1">
            Active Now
          </p>
          <div className="flex items-center gap-2">
            <p className="text-3xl font-extrabold text-slate-900">18</p>
            <span className="text-xs font-bold text-emerald-500 bg-emerald-50 px-2 py-0.5 rounded-full">
              +2 new
            </span>
          </div>
        </Card>
        <Card className="glass-card border-none rounded-2xl p-6">
          <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1">
            Total Event Volume
          </p>
          <p className="text-3xl font-extrabold text-slate-900">1,204</p>
        </Card>
        <Card className="glass-card border-none rounded-2xl p-6 bg-amber-50/50 border-amber-200/50">
          <p className="text-[10px] font-bold text-amber-600/70 uppercase tracking-widest mb-1">
            Trending
          </p>
          <p className="text-xl font-bold text-amber-900">Music &amp; Arts</p>
        </Card>
      </div>

      {/* Category Table */}
      <div className="bg-white/80 backdrop-blur-xl rounded-3xl border border-white/60 shadow-lg overflow-hidden">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="bg-slate-50/50">
              <th className="px-8 py-5 text-[10px] font-extrabold text-slate-400 uppercase tracking-widest">
                Category Name
              </th>
              <th className="px-8 py-5 text-[10px] font-extrabold text-slate-400 uppercase tracking-widest">
                Event Count
              </th>
              <th className="px-8 py-5 text-[10px] font-extrabold text-slate-400 uppercase tracking-widest">
                Status
              </th>
              <th className="px-8 py-5 text-[10px] font-extrabold text-slate-400 uppercase tracking-widest">
                Last Updated
              </th>
              <th className="px-8 py-5 text-[10px] font-extrabold text-slate-400 uppercase tracking-widest text-right">
                Actions
              </th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {mockCategories.slice(0, 4).map((category) => (
              <CategoryRow key={category.id} category={category} />
            ))}
          </tbody>
        </table>

        {/* Pagination */}
        <div className="px-8 py-4 bg-slate-50/30 flex items-center justify-between">
          <p className="text-xs font-medium text-slate-500">
            Showing 1-4 of 24 categories
          </p>
          <div className="flex gap-2">
            <button
              type="button"
              disabled
              className="p-2 bg-white border border-slate-200 rounded-lg text-slate-400 transition-colors disabled:opacity-50"
            >
              <ChevronLeft className="w-4 h-4" />
            </button>
            <button
              type="button"
              className="p-2 bg-white border border-slate-200 rounded-lg text-slate-400 hover:text-amber-600 transition-colors"
            >
              <ChevronRight className="w-4 h-4" />
            </button>
          </div>
        </div>
      </div>

      {/* Quick Filter Categories */}
      <div className="mt-12">
        <h3 className="text-[10px] font-extrabold text-slate-400 uppercase tracking-[0.2em] mb-4">
          Quick Filter Categories
        </h3>
        <div className="flex flex-wrap gap-2">
          {filterCategories.map((filter) => (
            <button
              key={filter}
              type="button"
              onClick={() => setSelectedFilter(filter)}
              className={cn(
                'px-4 py-2 rounded-full text-xs font-bold transition-all',
                selectedFilter === filter
                  ? 'bg-amber-500 text-white shadow-sm hover:scale-105'
                  : 'bg-white/70 backdrop-blur border border-slate-200 text-slate-600 hover:border-amber-500'
              )}
            >
              {filter}
            </button>
          ))}
        </div>
      </div>

      {/* Floating Action Button */}
      <Link href="/categories/create" className="fixed bottom-8 right-8 w-14 h-14 bg-on-surface text-white rounded-full shadow-2xl shadow-black/30 flex items-center justify-center hover:scale-110 active:scale-95 transition-all z-50">
        <Plus className="w-6 h-6" />
      </Link>
    </div>
  );
}

function CategoryRow({ category }: { category: Category }) {
  const Icon = iconMap[category.icon] || Music;

  return (
    <tr className="hover:bg-amber-50/30 transition-colors group">
      <td className="px-8 py-5">
        <div className="flex items-center gap-4">
          <div
            className="w-10 h-10 rounded-xl flex items-center justify-center"
            style={{ backgroundColor: `${category.color}20` }}
          >
            <Icon className="w-5 h-5" style={{ color: category.color }} />
          </div>
          <span className="font-bold text-slate-900">{category.name}</span>
        </div>
      </td>
      <td className="px-8 py-5">
        <span className="text-sm font-semibold text-slate-600 bg-slate-100 px-3 py-1 rounded-full">
          {category.eventCount} Events
        </span>
      </td>
      <td className="px-8 py-5">
        <div
          className={cn(
            'flex items-center gap-1.5',
            category.isActive ? 'text-emerald-600' : 'text-slate-400'
          )}
        >
          <span
            className={cn(
              'w-2 h-2 rounded-full',
              category.isActive ? 'bg-emerald-500 animate-pulse' : 'bg-slate-300'
            )}
          />
          <span className="text-xs font-bold uppercase tracking-wider">
            {category.isActive ? 'Active' : 'Inactive'}
          </span>
        </div>
      </td>
      <td className="px-8 py-5">
        <span className="text-sm text-slate-500 font-medium">
          {new Date(category.updatedAt).toLocaleDateString('en-US', {
            month: 'short',
            day: 'numeric',
            year: 'numeric',
          })}
        </span>
      </td>
      <td className="px-8 py-5 text-right">
        <div className="flex items-center justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
          <button
            type="button"
            onClick={() => alert(`Editing category: ${category.name}`)}
            className="p-2 text-slate-400 hover:text-amber-600 hover:bg-amber-50 rounded-lg transition-all"
          >
            <Edit className="w-4 h-4" />
          </button>
          <button
            type="button"
            onClick={() => alert(`Deleting category: ${category.name}`)}
            className="p-2 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition-all"
          >
            <Trash2 className="w-4 h-4" />
          </button>
        </div>
      </td>
    </tr>
  );
}
