import { NextResponse } from 'next/server';
import { prologFetch } from '@/lib/prolog';

function validate(body) {
  if (!body || typeof body !== 'object') return 'Invalid request body.';
  if (!body.name || String(body.name).trim() === '') return 'Name is required.';
  const gpa = Number(body.gpa);
  if (Number.isNaN(gpa) || gpa < 0 || gpa > 4) return 'GPA must be between 0.0 and 4.0.';
  const year = Number(body.year);
  if (!Number.isInteger(year) || year < 1 || year > 4) return 'Year must be between 1 and 4.';
  if (!Array.isArray(body.completed_courses)) return 'completed_courses must be an array.';
  return null;
}

export async function POST(request) {
  let body;
  try {
    body = await request.json();
  } catch {
    return NextResponse.json({ ok: false, error: 'Invalid JSON request body.' }, { status: 400 });
  }

  const error = validate(body);
  if (error) {
    return NextResponse.json({ ok: false, error }, { status: 400 });
  }

  const result = await prologFetch('/evaluate', {
    method: 'POST',
    body: JSON.stringify(body)
  });

  if (!result.ok) {
    return NextResponse.json({ ok: false, error: result.error }, { status: result.status || 502 });
  }

  return NextResponse.json(result.data);
}
