import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {stripTypeScriptTypes} from 'node:module';
import vm from 'node:vm';
import {cleanAnswers} from '../supabase/functions/questionnaire-link/validation.ts';

const q=(id,type,extra={})=>({id,question_type:type,question_text:id,is_required:true,options_json:['A','B'],rows_json:['R'],columns_json:['C'],...extra});
const questions=[q('yes','yesNo'),q('num','number',{min_value:0,max_value:10}),q('multi','multipleChoice'),q('matrix','matrix'),q('date','date'),q('hidden','text',{skip_logic_json:{questionId:'yes',operator:'equals',value:'NO'}})];
const values={yes:'YES',num:'2.5',multi:['A','A'],matrix:{R:'C'},date:'2026-09-13',hidden:'omit this',unknown:'omit this too'};
assert.deepEqual(cleanAnswers(questions,values),{yes:'YES',num:2.5,multi:['A'],matrix:{R:'C'},date:'2026-09-13'});
for(const override of [{num:'NaN'},{num:11},{multi:['unknown']},{matrix:{}},{date:'2026-02-30'},{yes:null}]) assert.throws(()=>cleanAnswers(questions,{...values,...override}));
assert.throws(()=>cleanAnswers([q('score','rating')],{score:6}));
assert.throws(()=>cleanAnswers([q('one','singleChoice')],{one:'C'}));

let handler;
let calls=[];
const source=readFileSync(new URL('../supabase/functions/questionnaire-link/index.ts',import.meta.url),'utf8').replace("import { cleanAnswers } from './validation.ts';",'');
vm.runInNewContext(stripTypeScriptTypes(source),{
  Deno:{serve:f=>handler=f,env:{get:()=> 'test'}},cleanAnswers,Response,Request,
  fetch:async(url)=>{calls.push(url);if(url.endsWith('/auth/v1/user'))return Response.json({id:'owner-a'});if(url.includes('/questionnaires?'))return Response.json([{id:'q',project_id:'project-b'}]);if(url.includes('/projects?')){assert.match(url,/owner_id=eq.owner-a/);return Response.json([]);}throw Error('unexpected request');}
});
const request=body=>new Request('https://test',{method:'POST',body:JSON.stringify(body)});
assert.equal((await handler(request({action:'publish',questionnaireId:'other-user-questionnaire'}))).status,403);
assert.ok(!calls.some(c=>c.includes('questionnaire_links')));
assert.equal((await handler(request({action:'load',slug:'../projects'}))).status,404);
console.log('Public questionnaire tests passed: answer types, ranges, missing/conditional answers, ownership, and invalid links.');
