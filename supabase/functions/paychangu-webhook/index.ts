const json = (data: unknown, status=200) => Response.json(data,{status,headers:{'Cache-Control':'no-store'}});
const hex = (buffer: ArrayBuffer) => [...new Uint8Array(buffer)].map(b=>b.toString(16).padStart(2,'0')).join('');
const same = (a:string,b:string) => { if(a.length!==b.length)return false; let x=0; for(let i=0;i<a.length;i++)x|=a.charCodeAt(i)^b.charCodeAt(i); return x===0; };

Deno.serve(async (req: Request) => {
  if (req.method !== 'POST') return json({error:'Use POST'},405);
  try {
    const raw = await req.text();
    const webhookSecret = Deno.env.get('PAYCHANGU_WEBHOOK_SECRET');
    const apiSecret = Deno.env.get('PAYCHANGU_SECRET_KEY');
    if (!webhookSecret || !apiSecret) return json({error:'Webhook is not configured.'},503);
    const key = await crypto.subtle.importKey('raw',new TextEncoder().encode(webhookSecret),{name:'HMAC',hash:'SHA-256'},false,['sign']);
    const expected = hex(await crypto.subtle.sign('HMAC',key,new TextEncoder().encode(raw)));
    const supplied = req.headers.get('Signature') ?? req.headers.get('signature') ?? '';
    if (!same(expected.toLowerCase(),supplied.toLowerCase())) return json({error:'Invalid signature.'},401);
    const event = JSON.parse(raw);
    const txRef = String(event.tx_ref ?? event.data?.tx_ref ?? '');
    if (!txRef) return json({received:true});
    const base = Deno.env.get('SUPABASE_URL')!;
    const service = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const headers = {apikey:service,Authorization:`Bearer ${service}`,'Content-Type':'application/json'};
    const pendingRes = await fetch(`${base}/rest/v1/payment_transactions?tx_ref=eq.${encodeURIComponent(txRef)}&select=*`,{headers});
    const pending = (await pendingRes.json())?.[0];
    if (!pending || pending.status === 'successful') return json({received:true});
    const verify = await fetch(`https://api.paychangu.com/verify-payment/${encodeURIComponent(txRef)}`,{headers:{Accept:'application/json',Authorization:`Bearer ${apiSecret}`}});
    const verified = await verify.json();
    const payment = verified?.data;
    const valid = verify.ok && payment?.tx_ref === txRef && payment?.status === 'success' && payment?.currency === pending.currency && Number(payment?.amount) >= Number(pending.amount);
    if (!valid) return json({received:true,verified:false});
    const entRes = await fetch(`${base}/rest/v1/user_entitlements?user_id=eq.${pending.user_id}&select=tier,valid_until`,{headers});
    const current = (await entRes.json())?.[0];
    const grantedTier = current?.tier === 'pro' && current?.valid_until && Date.parse(current.valid_until) > Date.now() ? 'pro' : pending.tier;
    const now = Date.now();
    const baseTime = Math.max(now, current?.valid_until ? Date.parse(current.valid_until) : 0);
    const validUntil = new Date(baseTime + 30*24*60*60*1000).toISOString();
    await fetch(`${base}/rest/v1/user_entitlements?on_conflict=user_id`,{method:'POST',headers:{...headers,Prefer:'resolution=merge-duplicates'},body:JSON.stringify({user_id:pending.user_id,tier:grantedTier,valid_until:validUntil,updated_at:new Date().toISOString()})});
    await fetch(`${base}/rest/v1/payment_transactions?tx_ref=eq.${encodeURIComponent(txRef)}`,{method:'PATCH',headers,body:JSON.stringify({status:'successful',provider_reference:String(payment.reference ?? ''),verified_at:new Date().toISOString(),updated_at:new Date().toISOString()})});
    return json({received:true,verified:true});
  } catch (_) { return json({error:'Webhook processing failed.'},500); }
});
