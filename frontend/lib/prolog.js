const BASE = process.env.PROLOG_API_BASE || 'http://localhost:8080/api';

function withTimeout(ms = 9000) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), ms);
  return { signal: controller.signal, clear: () => clearTimeout(timeout) };
}

export async function prologFetch(path, options = {}) {
  const timeout = withTimeout();
  try {
    const response = await fetch(`${BASE}${path}`, {
      ...options,
      signal: timeout.signal,
      headers: {
        'Content-Type': 'application/json',
        ...(options.headers || {})
      },
      cache: 'no-store'
    });

    const text = await response.text();
    let data;
    try {
      data = text ? JSON.parse(text) : {};
    } catch {
      data = { ok: false, error: 'Invalid response from Prolog backend.' };
    }

    if (!response.ok) {
      return {
        ok: false,
        status: response.status,
        error: data.error || `Backend request failed (${response.status}).`
      };
    }

    return { ok: true, status: response.status, data };
  } catch (error) {
    if (error?.name === 'AbortError') {
      return { ok: false, status: 504, error: 'Request timed out. Check if Prolog server is running.' };
    }
    return { ok: false, status: 502, error: 'Cannot reach Prolog backend. Start `saa_web.pl` server first.' };
  } finally {
    timeout.clear();
  }
}
