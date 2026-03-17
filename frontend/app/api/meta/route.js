import { NextResponse } from 'next/server';
import { prologFetch } from '@/lib/prolog';

export async function GET() {
  const [students, courses, careers] = await Promise.all([
    prologFetch('/students'),
    prologFetch('/courses'),
    prologFetch('/careers')
  ]);

  if (!students.ok || !courses.ok || !careers.ok) {
    const error = students.error || courses.error || careers.error || 'Failed to load metadata.';
    return NextResponse.json({ ok: false, error }, { status: 502 });
  }

  return NextResponse.json({
    ok: true,
    students: students.data.students || [],
    courses: courses.data.courses || [],
    careers: careers.data.careers || []
  });
}
