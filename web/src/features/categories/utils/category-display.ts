import { Construction, GraduationCap, Music, Trophy } from 'lucide-react';
import type { ElementType } from 'react';

export const categoryIconMap: Record<string, ElementType> = {
  music: Music,
  'graduation-cap': GraduationCap,
  trophy: Trophy,
  construction: Construction,
};
