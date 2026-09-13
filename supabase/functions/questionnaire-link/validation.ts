export function cleanAnswers(questions: any[], answers: Record<string, any>) {
  if (!answers || Array.isArray(answers) || typeof answers !== 'object') throw new Error('Invalid answers');
  const clean: Record<string, any> = {};
  for (const q of questions) {
    const rule = q.skip_logic_json;
    if (rule?.questionId) {
      const actual = clean[rule.questionId];
      const expected = String(rule.value);
      const visible = rule.operator === 'notEquals' ? String(actual) !== expected
        : rule.operator === 'contains' ? (Array.isArray(actual) ? actual.map(String).includes(expected) : String(actual ?? '').includes(expected))
        : String(actual) === expected;
      if (!visible) continue;
    }
    let v = answers[q.id];
    const missing = v == null || v === '' || (typeof v === 'string' && !v.trim()) || (Array.isArray(v) && !v.length);
    if (missing) { if (q.is_required) throw new Error(`Answer required: ${q.question_text}`); continue; }
    const invalid = () => { throw new Error(`Check your answer: ${q.question_text}`); };
    switch (q.question_type) {
      case 'number':
        if (!['number','string'].includes(typeof v)) invalid();
        v = Number(v);
        if (!Number.isFinite(v) || (q.min_value != null && v < q.min_value) || (q.max_value != null && v > q.max_value)) invalid();
        break;
      case 'likertScale': case 'rating':
        if (!Number.isInteger(v) || v < 1 || v > 5) invalid(); break;
      case 'singleChoice': if (!q.options_json.includes(v)) invalid(); break;
      case 'multipleChoice':
        if (!Array.isArray(v) || v.some(x => !q.options_json.includes(x))) invalid();
        v = [...new Set(v)]; break;
      case 'yesNo': if (!['YES','NO'].includes(v)) invalid(); break;
      case 'date':
        if (typeof v !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(v) || Number.isNaN(Date.parse(v)) || new Date(v).toISOString().slice(0,10) !== v) invalid(); break;
      case 'matrix':
        if (typeof v !== 'object' || Array.isArray(v)) invalid();
        v = Object.fromEntries(q.rows_json.filter((row: string) => v[row] != null).map((row: string) => [row,v[row]]));
        if (Object.values(v).some(x => !q.columns_json.includes(x)) || (q.is_required && q.rows_json.some((row: string) => !v[row]))) invalid(); break;
      case 'text': if (typeof v !== 'string' || v.length > 10000) invalid(); v = v.trim(); break;
      default: invalid();
    }
    clean[q.id] = v;
  }
  return clean;
}
