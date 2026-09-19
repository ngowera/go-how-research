const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

const json = (data: unknown, status = 200) =>
  Response.json(data, { status, headers: cors });

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors });
  if (req.method !== 'POST') return json({ error: 'Use POST.' }, 405);

  const url = Deno.env.get('SUPABASE_URL');
  const anon = Deno.env.get('SUPABASE_ANON_KEY');
  const serviceRole = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (!url || !anon || !serviceRole) {
    return json({ error: 'Storage usage service is not configured.' }, 503);
  }

  const authorization = req.headers.get('Authorization') ?? '';
  if (!authorization.startsWith('Bearer ')) {
    return json({ error: 'Please sign in online.' }, 401);
  }

  const auth = await fetch(`${url}/auth/v1/user`, {
    headers: { apikey: anon, Authorization: authorization },
  });
  if (!auth.ok) return json({ error: 'Your session expired.' }, 401);

  const usage = await fetch(`${url}/rest/v1/rpc/get_storage_usage`, {
    method: 'POST',
    headers: {
      apikey: serviceRole,
      Authorization: `Bearer ${serviceRole}`,
      'Content-Type': 'application/json',
    },
    body: '{}',
  });
  if (!usage.ok) return json({ error: 'Unable to read Supabase usage.' }, 502);

  const rows = await usage.json();
  const row = Array.isArray(rows) ? rows[0] : rows;
  return json({
    databaseBytes: Number(row?.database_bytes ?? 0),
    storageBytes: Number(row?.storage_bytes ?? 0),
    measuredAt: new Date().toISOString(),
  });
});
