# Research features and setup

Run the web app on this Ubuntu computer with `flutter run -d chrome`.
Windows desktop builds must be compiled on a Windows computer with Flutter's
Windows tooling installed. Android packaging is deferred.

## Gemini server configuration

In the GOHOW RESEARCH Supabase project, open **Edge Functions > Secrets** and add:

- `GEMINI_API_KEY` = the Google AI Studio API key
- `GEMINI_MODEL` = `gemini-2.5-flash`

Alternatively, after `supabase login` and `supabase link`, set only the model
from the project directory with:

```bash
npx supabase secrets set GEMINI_MODEL=gemini-2.5-flash
```

Supabase makes a changed secret available to functions immediately; the function
does not need redeployment just for a secret change. Deploy changed function code
with `npx supabase functions deploy research-expert --use-api`. Keep the API key
on the server, never in Flutter, `.env`, GitHub Actions, or a web bundle.

The function sources are `supabase/functions/research-expert/index.ts` and
`supabase/functions/transcribe-interview/index.ts`. Interview database and private
storage definitions are in `supabase/interviews_setup.sql`.

Research Assistant uses synced project summaries. It excludes participant names,
contact details, and raw free-text answers. Unsynced edits are not included.
Transcription sends the selected recording to Gemini after confirmation and
stores a draft transcript for review. Test both features with a short synthetic
interview after adding the secret before collecting real interviews.

## Research workflow

1. Create a project and questionnaire, then register participants with codes and
   optional names. The identity display preference is in Settings.
2. Collect responses or use Interviews to record/import consented audio and link
   it to a participant. Keep the app open for automatic synchronization.
3. Open Analytics to select variables, charts, and statistical tests. Check the
   valid sample size, missing values, and test assumptions when interpreting results.
4. In the project dataset, choose **Prepare Excel / SPSS export**. Select variables
   and filters, inspect validation notes, and export XLSX, CSV, or SPSS SAV.
   Prepared exports include coded categories and split multiple selections;
   Excel also includes a codebook and export notes.
5. Settings supports profile name/photo, appearance, text size, chart palette,
   number formatting, significance level, and collection preferences.

## Verification

`flutter test` covers numerical results, prepared exports, WAV construction, and
local database workflows. `node --experimental-strip-types
test/edge_functions_test.mjs` checks function syntax and mocked authentication,
ownership, consent, and response behavior. These checks do not replace a live
Gemini transcription test or cross-device audio playback test.
