import { cleanAnswers } from './validation.ts';

const cors = {'Access-Control-Allow-Origin':'*','Access-Control-Allow-Headers':'authorization, apikey, content-type, x-client-info','Access-Control-Allow-Methods':'POST, OPTIONS'};
const json = (data: unknown, status=200) => new Response(JSON.stringify(data), {status,headers:{...cors,'Content-Type':'application/json','Cache-Control':'no-store'}});
const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok',{headers:cors});
  if (req.method !== 'POST') return json({error:'Use POST'},405);
  try {
    const raw = await req.text();
    if (raw.length > 120000) return json({error:'Submission too large'},413);
    const body = JSON.parse(raw);
    const base = Deno.env.get('SUPABASE_URL')!;
    const key = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const db = async (path: string, method='GET', data?: unknown) => {
      const res = await fetch(`${base}/rest/v1/${path}`,{method,headers:{apikey:key,Authorization:`Bearer ${key}`,'Content-Type':'application/json',Prefer:'return=representation'},body:data === undefined ? undefined : JSON.stringify(data)});
      if (!res.ok) throw new Error('Database request failed. Check whether the link is still open and try again.');
      return await res.json();
    };
    if (['status','publish','close'].includes(body.action)) {
      const auth = await fetch(`${base}/auth/v1/user`,{headers:{apikey:Deno.env.get('SUPABASE_ANON_KEY')!,Authorization:req.headers.get('Authorization') ?? ''}});
      if (!auth.ok) return json({error:'Sign in to manage questionnaire links'},401);
      const user = await auth.json();
      let entitlements = await db(`user_entitlements?user_id=eq.${encodeURIComponent(user.id)}&select=tier,valid_until,free_publish_used_at`);
      const entitlement = entitlements[0];
      const paidActive = entitlement?.valid_until && Date.parse(entitlement.valid_until) > Date.now();
      const tier = paidActive && ['plus','pro'].includes(entitlement?.tier) ? entitlement.tier : 'free';
      const qs = await db(`questionnaires?id=eq.${encodeURIComponent(body.questionnaireId ?? '')}&select=id,project_id`);
      if (!qs.length) return json({error:'Questionnaire unavailable. Sync first.'},404);
      const projects = await db(`projects?id=eq.${encodeURIComponent(qs[0].project_id)}&owner_id=eq.${encodeURIComponent(user.id)}&select=id`);
      if (!projects.length) return json({error:'Only the project owner can manage this link'},403);
      let links = await db(`questionnaire_links?questionnaire_id=eq.${encodeURIComponent(qs[0].id)}`);
      if (body.action === 'publish') {
        if (tier === 'free' && entitlement?.free_publish_used_at) {
          const nextAt = Date.parse(entitlement.free_publish_used_at) + 7*24*60*60*1000;
          if (nextAt > Date.now()) return json({error:`Free accounts can publish again on ${new Date(nextAt).toISOString()}. Upgrade for unlimited publishing.`},403);
        }
        const questions = await db(`questions?questionnaire_id=eq.${encodeURIComponent(qs[0].id)}&order=order_index,id&limit=501`);
        if (!questions.length || questions.length>500) return json({error:'Publish between 1 and 500 questions'},400);
        if (questions.some((q: any) => q.skip_logic_json?.questionId && !questions.slice(0,questions.indexOf(q)).some((p:any)=>p.id===q.skip_logic_json.questionId))) return json({error:'Skip rules must refer to earlier questions. Update the questionnaire first.'},400);
        const consent = String(body.consentText ?? '').trim();
        const slug = String(body.slug ?? '').trim().toLowerCase();
        if (!/^[a-z0-9][a-z0-9-]{5,59}$/.test(slug) || ['dashboard','projects','questionnaires','participants','supervisor','reports','settings','interviews','register','analytics'].includes(slug)) return json({error:'Choose a link name of 6–60 lowercase letters, numbers or hyphens'},400);
        const used = await db(`questionnaire_links?slug=eq.${slug}&select=questionnaire_id`);
        if (links.length && links[0].slug !== slug) return json({error:'A published link name cannot be changed. Create a separate questionnaire for another link.'},400);
        if (used.length && used[0].questionnaire_id !== qs[0].id) return json({error:'This link name is already in use. Choose another.'},409);
        if (!consent || consent.length>5000) return json({error:'Add study information and consent text (up to 5,000 characters)'},400);
        const days = Number(body.days ?? 30);
        if (tier !== 'free' && (!Number.isInteger(days) || days < 1 || days > 365)) return json({error:'Choose 1–365 days'},400);
        const expiresAt = tier === 'free' ? new Date(Date.now()+5*60*1000) : new Date(Date.now()+days*86400000);
        const data = {slug,active:true,collect_name:body.collectName === true,collect_contact:body.collectContact === true,consent_text:consent,expires_at:expiresAt.toISOString()};
        links = links.length ? await db(`questionnaire_links?id=eq.${links[0].id}`,'PATCH',data)
          : await db('questionnaire_links','POST',{...data,questionnaire_id:qs[0].id});
        if (tier === 'free') {
          const usage = {free_publish_used_at:new Date().toISOString(),updated_at:new Date().toISOString()};
          entitlements = entitlements.length
            ? await db(`user_entitlements?user_id=eq.${encodeURIComponent(user.id)}`,'PATCH',usage)
            : await db('user_entitlements','POST',{user_id:user.id,tier:'free',...usage});
        }
      }
      if (body.action === 'close' && links.length) links = await db(`questionnaire_links?id=eq.${links[0].id}`,'PATCH',{active:false});
      return json({link:links[0] ?? null,tier});
    }
    if (!/^[a-z0-9][a-z0-9-]{5,59}$/.test(body.slug ?? '')) return json({error:'Invalid questionnaire link'},404);
    const links = await db(`questionnaire_links?slug=eq.${body.slug}&select=*`);
    const link = links[0];
    if (!link) return json({error:'This questionnaire link is unavailable'},404);
    if (body.action === 'submit' && uuid.test(body.submissionId ?? '')) {
      const receipts = await db(`questionnaire_link_receipts?link_id=eq.${link.id}&submission_id=eq.${body.submissionId}&select=response_id`);
      if (receipts.length) return json({submitted:true,receipt:receipts[0].response_id});
    }
    if (!link.active || Date.parse(link.expires_at) <= Date.now()) return json({error:'This questionnaire is closed or expired. Contact the researcher.'},410);
    const qs = await db(`questionnaires?id=eq.${encodeURIComponent(link.questionnaire_id)}&select=id,title,description`);
    const questions = await db(`questions?questionnaire_id=eq.${encodeURIComponent(link.questionnaire_id)}&order=order_index,id&limit=501`);
    const fingerprint = await db('rpc/questionnaire_link_fingerprint','POST',{p_questionnaire_id:link.questionnaire_id});
    if (body.action === 'load') return json({questionnaire:qs[0],questions,fingerprint,collectName:link.collect_name,collectContact:link.collect_contact,consentText:link.consent_text});
    if (body.action !== 'submit') return json({error:'Unknown action'},400);
    if (!uuid.test(body.submissionId ?? '') || body.consented !== true) return json({error:'Please confirm your consent before submitting'},400);
    if (body.fingerprint !== fingerprint) return json({error:'The researcher updated this questionnaire. Reload the page and review your answers.'},409);
    const name = String(body.name ?? '').trim();
    const phone = String(body.phone ?? '').trim();
    const email = String(body.email ?? '').trim();
    if ((link.collect_name && !name) || name.length>200 || phone.length>50 || email.length>254 || (link.collect_contact && email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email))) return json({error:'Check your participant details'},400);
    let answers;
    try { answers = cleanAnswers(questions,body.answers); } catch(e) {return json({error:(e as Error).message},400);}
    const result = await db('rpc/submit_questionnaire_link','POST',{p_token:link.token,p_submission_id:body.submissionId,p_name:name,p_phone:phone,p_email:email,p_answers:answers,p_fingerprint:fingerprint});
    return json(result);
  } catch (_) { return json({error:'Unable to complete this request. Check your connection and try again; your answers have not been cleared.'},500); }
});
