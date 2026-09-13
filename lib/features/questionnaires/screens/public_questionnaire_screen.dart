import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/app_models.dart';

Future<Map<String, dynamic>> questionnaireLinkRequest(Map<String, dynamic> body) async {
  try {
    final result = await Supabase.instance.client.functions.invoke('questionnaire-link', body: body);
    final data = Map<String, dynamic>.from(result.data as Map);
    if (data['error'] != null) throw Exception(data['error']);
    return data;
  } on FunctionException catch (e) {
    throw Exception(e.details is Map ? e.details['error'] ?? 'Request failed' : 'Unable to reach the questionnaire. Try again.');
  }
}

class PublicQuestionnaireScreen extends StatefulWidget {
  const PublicQuestionnaireScreen({super.key, required this.slug});
  final String slug;
  @override
  State<PublicQuestionnaireScreen> createState() => _PublicQuestionnaireScreenState();
}

class _PublicQuestionnaireScreenState extends State<PublicQuestionnaireScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final Map<String, dynamic> _answers = {};
  String _submissionId = const Uuid().v4();
  Map<String, dynamic>? _data;
  List<Question> _questions = [];
  String? _error;
  String? _receipt;
  bool _consented = false;
  bool _busy = false;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _name.dispose(); _phone.dispose(); _email.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await questionnaireLinkRequest({'action':'load','slug':widget.slug});
      if (!mounted) return;
      setState(() {
        _data = data;
        _questions = (data['questions'] as List).map((q) => Question.fromJson(Map<String,dynamic>.from(q))).toList();
      });
    } catch(e) { if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', '')); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  List<Question> get _visible {
    final values = <String,dynamic>{};
    final visible = <Question>[];
    for (final q in _questions) {
      final r = q.skipLogic;
      if (r?['questionId'] != null) {
        final actual = values[r!['questionId']];
        final expected = r['value']?.toString();
        final show = r['operator'] == 'notEquals' ? actual?.toString() != expected
          : r['operator'] == 'contains' ? (actual is List ? actual.map((e)=>e.toString()).contains(expected) : (actual?.toString().contains(expected ?? '') ?? false))
          : actual?.toString() == expected;
        if (!show) continue;
      }
      visible.add(q); values[q.id] = _answers[q.id];
    }
    return visible;
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (!_consented) { setState(() => _error = 'Please confirm your consent before submitting.'); return; }
    setState(() { _busy = true; _error = null; });
    try {
      final result = await questionnaireLinkRequest({
        'action':'submit','slug':widget.slug,'submissionId':_submissionId,
        'fingerprint':_data!['fingerprint'],'consented':true,
        'name':_name.text.trim(),'phone':_phone.text.trim(),'email':_email.text.trim(),
        'answers':{for(final q in _visible) if(_answers.containsKey(q.id)) q.id:_answers[q.id]},
      });
      if (mounted) setState(() { _receipt = result['receipt'] as String; _answers.clear(); _name.clear(); _phone.clear(); _email.clear(); });
    } catch(e) { if(mounted) setState(()=>_error=e.toString().replaceFirst('Exception: ','')); }
    finally { if(mounted) setState(()=>_busy=false); }
  }

  void _nextParticipant() {
    setState(() { _receipt=null; _consented=false; _submissionId=const Uuid().v4(); });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    return Scaffold(
      appBar: AppBar(title: const Text('GoHow Research'), automaticallyImplyLeading:false),
      body: Center(child: ConstrainedBox(constraints:const BoxConstraints(maxWidth:760),
        child: _loading ? const Center(child:CircularProgressIndicator())
        : _receipt != null ? Padding(padding:const EdgeInsets.all(24),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
          const Icon(Icons.check_circle,color:Colors.green,size:64),const SizedBox(height:16),
          Text('Thank you. Your response has been submitted.',style:Theme.of(context).textTheme.headlineSmall,textAlign:TextAlign.center),
          const SizedBox(height:12),const Text('The researcher can now access your answers. You may close this page.'),
          const SizedBox(height:12),SelectableText('Receipt: $_receipt'),const SizedBox(height:24),
          OutlinedButton(onPressed:_nextParticipant,child:const Text('Start for another participant on this device')),
        ]))
        : ListView(padding:const EdgeInsets.all(20),children:[
          if(_error != null) Card(color:Theme.of(context).colorScheme.errorContainer,child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(_error!),TextButton(onPressed:_busy?null:_load,child:const Text('Reload questionnaire'))]))),
          if(_data != null) Form(key:_form,child:AbsorbPointer(absorbing:_busy,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text(_data!['questionnaire']['title'],style:Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height:12),Text(_data!['questionnaire']['description'] ?? ''),
            const SizedBox(height:16),const Text('No account is needed. Fields marked * are required. Your answers go to the researcher who shared this link.'),
            const SizedBox(height:20),Text('About you',style:Theme.of(context).textTheme.titleLarge),
            const SizedBox(height:12),
            if(_data!['collectName'] == true) TextFormField(controller:_name,maxLength:200,decoration:const InputDecoration(labelText:'Your name *'),validator:(v)=>(v??'').trim().isEmpty?'Enter your name':null),
            if(_data!['collectContact'] == true) ...[
              TextFormField(controller:_phone,maxLength:50,keyboardType:TextInputType.phone,decoration:const InputDecoration(labelText:'Phone (optional)')),
              TextFormField(controller:_email,maxLength:254,keyboardType:TextInputType.emailAddress,decoration:const InputDecoration(labelText:'Email (optional)'),validator:(v)=>v != null && v.isNotEmpty && !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v)?'Enter a valid email':null),
            ],
            const Text('An identification code will be assigned automatically.'),
            const SizedBox(height:20),Text(_data!['consentText']),
            CheckboxListTile(contentPadding:EdgeInsets.zero,controlAffinity:ListTileControlAffinity.leading,title:const Text('I agree to participate *'),value:_consented,onChanged:(v)=>setState(()=>_consented=v??false)),
            const Divider(height:32),
            for(var i=0;i<visible.length;i++) _question(visible[i],i+1),
            if(_error != null) Padding(padding:const EdgeInsets.only(bottom:12),child:Text(_error!,style:TextStyle(color:Theme.of(context).colorScheme.error))),
            SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:_busy?null:_submit,icon:_busy?const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2)):const Icon(Icons.send),label:Text(_busy?'Submitting…':'Submit answers'))),
            const SizedBox(height:16),const Text('Keep this page open until you see your submission confirmation. Answers are kept on this page if sending fails.'),
            const SizedBox(height:32),
          ]))),
        ]),
      )),
    );
  }

  Widget _question(Question q,int index) {
    return Card(key:ValueKey(q.id),margin:const EdgeInsets.only(bottom:20),child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text('$index. ${q.text}${q.isRequired?' *':''}',style:Theme.of(context).textTheme.titleMedium),
      if(q.helpText?.isNotEmpty == true) Padding(padding:const EdgeInsets.only(top:6),child:Text(q.helpText!)),
      const SizedBox(height:12),_input(q),
    ])));
  }

  Widget _input(Question q) {
    void change(dynamic v) => setState(()=>_answers[q.id]=v);
    if(q.type == QuestionType.text || q.type == QuestionType.number || q.type == QuestionType.date) {
      return TextFormField(initialValue:_answers[q.id]?.toString(),
        keyboardType:q.type==QuestionType.number?const TextInputType.numberWithOptions(decimal:true,signed:true):TextInputType.text,
        maxLines:q.type==QuestionType.text?3:1,
        decoration:InputDecoration(labelText:q.type==QuestionType.date?'Date (YYYY-MM-DD)':'Your answer'),
        onChanged:change,validator:(v){
          if((v??'').trim().isEmpty) return q.isRequired?'This answer is required':null;
          if(q.type==QuestionType.number) {final n=double.tryParse(v!);if(n==null||!n.isFinite)return 'Enter a valid number';if(q.minValue!=null&&n<q.minValue!)return 'Minimum: ${q.minValue}';if(q.maxValue!=null&&n>q.maxValue!)return 'Maximum: ${q.maxValue}';}
          if(q.type==QuestionType.date && (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(v!) || DateTime.tryParse(v)==null || DateTime.parse(v).toIso8601String().substring(0,10)!=v)) return 'Use a valid date: YYYY-MM-DD';
          return null;
        });
    }
    return FormField<dynamic>(validator:(_){
      final v=_answers[q.id];
      if(q.isRequired && (v==null || (v is List && v.isEmpty) || (q.type==QuestionType.matrix && q.rows.any((row)=>v[row]==null)))) return 'Please answer this question';
      return null;
    },builder:(field)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      if(q.type==QuestionType.multipleChoice) ...q.options.map((o)=>CheckboxListTile(contentPadding:EdgeInsets.zero,title:Text(o),value:(_answers[q.id] as List? ?? []).contains(o),onChanged:(checked){final list=List<String>.from(_answers[q.id] ?? []);checked==true?list.add(o):list.remove(o);change(list);})),
      if([QuestionType.singleChoice,QuestionType.yesNo,QuestionType.likertScale,QuestionType.rating].contains(q.type)) Wrap(spacing:8,runSpacing:8,children:(q.type==QuestionType.yesNo?['YES','NO']:q.type==QuestionType.singleChoice?q.options:[1,2,3,4,5]).map((o)=>ChoiceChip(label:Text(o.toString()),selected:_answers[q.id]==o,onSelected:(_)=>change(o))).toList()),
      if(q.type==QuestionType.matrix) ...q.rows.map((row)=>Padding(padding:const EdgeInsets.only(bottom:12),child:DropdownButtonFormField<String>(isExpanded:true,initialValue:(_answers[q.id] as Map?)?[row],decoration:InputDecoration(labelText:row),items:q.columns.map((c)=>DropdownMenuItem(value:c,child:Text(c))).toList(),onChanged:(v)=>change({...?_answers[q.id] as Map<String,dynamic>?,row:v})))),
      if(field.hasError) Text(field.errorText!,style:TextStyle(color:Theme.of(context).colorScheme.error)),
    ]));
  }
}
