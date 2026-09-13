import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { stripTypeScriptTypes } from 'node:module';
import vm from 'node:vm';

async function handler(name,fetchMock){
  let serve;
  const env={SUPABASE_URL:'https://test.supabase.co',SUPABASE_ANON_KEY:'test-publishable-key',GEMINI_API_KEY:'test-only-key'};
  const source=readFileSync(new URL(`../supabase/functions/${name}/index.ts`,import.meta.url),'utf8');
  vm.runInNewContext(stripTypeScriptTypes(source),{Deno:{env:{get:k=>env[k]},serve:f=>serve=f},fetch:fetchMock,Response,Request,AbortSignal,Uint8Array,console,setTimeout});
  return serve;
}
const request=(body,authorized=true)=>new Request('https://test/functions',{method:'POST',headers:{'Content-Type':'application/json',...(authorized?{Authorization:'Bearer test-user-token'}:{})},body:JSON.stringify(body)});
let calls=[];
const expert=await handler('research-expert',async(url,options)=>{
  calls.push(url);
  if(url.endsWith('/auth/v1/user'))return Response.json({id:'owner-one'});
  if(url.includes('/rest/v1/projects')){
    assert.match(url,/owner_id=eq.owner-one/);
    assert.equal(options.headers.Authorization,'Bearer test-user-token');
    return Response.json([{id:'own-project',title:'Owned study'}]);
  }
  if(url.includes('/rest/v1/questionnaires'))return Response.json([]);
  if(url.includes('generateContent'))return Response.json({candidates:[{content:{parts:[{text:'No collected cases yet.'}]}}]});
  throw new Error(`Unexpected fetch ${url}`);
});
assert.equal((await expert(request({message:'Hello'},false))).status,401);
assert.equal(calls.length,0);
assert.equal((await expert(request({message:'Hello',projectId:'someone-elses-project'}))).status,403);
assert.ok(!calls.some(url=>url.includes('generateContent')));
const result=await expert(request({message:'Explain my study',projectId:'own-project'}));
assert.equal(result.status,200);assert.equal((await result.json()).projects,1);
assert.equal((await expert(request({message:''}))).status,400);

let generated=false;
const transcribe=await handler('transcribe-interview',async(url,options)=>{
  if(url.endsWith('/auth/v1/user'))return Response.json({id:'owner-one'});
  if(url.includes('/rest/v1/interviews')){
    assert.match(url,/owner_id=eq.owner-one/);
    assert.equal(options.headers.Authorization,'Bearer test-user-token');
    return Response.json([{id:'interview',status:'transcribed',transcript:'Already saved transcript.'}]);
  }
  generated=true;throw new Error('Should not call Gemini for a saved transcript');
});
assert.equal((await transcribe(request({interviewId:'interview',consent:false}))).status,400);
const cached=await transcribe(request({interviewId:'interview',consent:true}));
assert.equal((await cached.json()).transcript,'Already saved transcript.');assert.equal(generated,false);
const rejected=await handler('transcribe-interview',async()=>new Response('',{status:401}));
assert.equal((await rejected(request({interviewId:'interview',consent:true}))).status,401);
console.log('Edge Function checks passed: syntax, authentication, project ownership, consent, response shape and cached transcription.');
