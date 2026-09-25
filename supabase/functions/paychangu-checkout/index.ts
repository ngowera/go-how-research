const cors = {'Access-Control-Allow-Origin':'*','Access-Control-Allow-Headers':'authorization, apikey, content-type, x-client-info','Access-Control-Allow-Methods':'POST, OPTIONS'};
const json = (data: unknown, status=200) => Response.json(data,{status,headers:{...cors,'Cache-Control':'no-store'}});
const plans = {plus:{amount:10000,title:'Go-How RS Plus'},pro:{amount:20000,title:'Go-How RS Pro'}} as const;

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok',{headers:cors});
  if (req.method !== 'POST') return json({error:'Use POST'},405);
  try {
    const base = Deno.env.get('SUPABASE_URL')!;
    const anon = Deno.env.get('SUPABASE_ANON_KEY')!;
    const service = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const secret = Deno.env.get('PAYCHANGU_SECRET_KEY');
    const returnUrl = Deno.env.get('PAYCHANGU_RETURN_URL');
    if (!secret || !returnUrl) return json({error:'Payments are not configured yet.'},503);
    const auth = await fetch(`${base}/auth/v1/user`,{headers:{apikey:anon,Authorization:req.headers.get('Authorization') ?? ''}});
    if (!auth.ok) return json({error:'Sign in online to upgrade.'},401);
    const user = await auth.json();
    const body = await req.json();
    const tier = body.tier as keyof typeof plans;
    const plan = plans[tier];
    if (!plan) return json({error:'Unknown subscription plan.'},400);
    const txRef = `ghrs_${tier}_${crypto.randomUUID()}`;
    const names = String(user.user_metadata?.name ?? user.email?.split('@')[0] ?? 'Researcher').trim().split(/\s+/);
    const payment = await fetch('https://api.paychangu.com/payment',{
      method:'POST',headers:{Accept:'application/json','Content-Type':'application/json',Authorization:`Bearer ${secret}`},
      body:JSON.stringify({amount:String(plan.amount),currency:'MWK',tx_ref:txRef,email:user.email,first_name:names[0],last_name:names.slice(1).join(' '),callback_url:returnUrl,return_url:returnUrl,customization:{title:plan.title,description:'30 days of Go-How RS access'}})
    });
    const result = await payment.json();
    const checkoutUrl = result?.data?.checkout_url;
    if (!payment.ok || !checkoutUrl) return json({error:'PayChangu could not start checkout.'},502);
    const saved = await fetch(`${base}/rest/v1/payment_transactions`,{method:'POST',headers:{apikey:service,Authorization:`Bearer ${service}`,'Content-Type':'application/json'},body:JSON.stringify({tx_ref:txRef,user_id:user.id,tier,amount:plan.amount,currency:'MWK'})});
    if (!saved.ok) return json({error:'Could not record the payment attempt.'},500);
    return json({checkoutUrl,txRef});
  } catch (_) { return json({error:'Unable to start payment. Try again.'},500); }
});
