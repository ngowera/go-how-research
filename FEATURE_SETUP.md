# Research features and setup

Run the web app on this Ubuntu computer with `flutter run -d chrome`.
Windows desktop builds must be compiled on a Windows computer with Flutter's
Windows tooling installed. Android packaging is deferred.

## Gemini server configuration

In the GO-HOW RS Supabase project, open **Edge Functions > Secrets** and add:

- `GEMINI_API_KEY` = the Google AI Studio API key
- `GEMINI_MODEL` = `gemini-3.6-flash`

Alternatively, after `supabase login` and `supabase link`, set only the model
from the project directory with:

```bash
npx supabase secrets set GEMINI_MODEL=gemini-3.6-flash
```

Supabase makes a changed secret available to functions immediately; the function
does not need redeployment just for a secret change. Deploy changed function code
with `npx supabase functions deploy research-expert --use-api`. Keep the API key
on the server, never in Flutter, `.env`, GitHub Actions, or a web bundle.

The function sources are `supabase/functions/research-expert/index.ts` and
`supabase/functions/transcribe-interview/index.ts`. Interview database and private
storage definitions are in `supabase/interviews_setup.sql`.

## Data Capture storage

Run `supabase/project_assets_setup.sql` in the Supabase SQL Editor once. It
creates the private `project-assets` bucket and project-scoped access policies.
Data Capture supports images, videos capped at seven seconds, and PDF, Word and
Excel files. Each asset is saved under its selected project with a timestamp and
optional field note. Student accounts have a 10 MB free asset allowance; payment
gating is intentionally not enabled yet.

Research Assistant uses synced project summaries. It excludes participant names,
contact details, and raw free-text answers. Unsynced edits are not included.
Transcription sends the selected recording to Gemini after confirmation and
stores a draft transcript for review. Test both features with a short synthetic
interview after adding the secret before collecting real interviews.

## Research workflow

1. Create a project and questionnaire, then register participants with codes and
   optional names. The identity display preference is in Settings.
2. Collect responses or use Data Capture to record/import consented audio, take
   timestamped photos, capture a seven-second video, or upload project documents.
   Keep the app open for automatic synchronization.
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

## PayChangu plans and feature gating

1. Run `supabase/billing_setup.sql` in the Supabase SQL Editor.
2. In PayChangu, create test API credentials and a webhook secret.
3. Add these Supabase Edge Function secrets (never put them in the Flutter app):
   - `PAYCHANGU_SECRET_KEY`
   - `PAYCHANGU_WEBHOOK_SECRET`
   - `PAYCHANGU_RETURN_URL` (for example, your deployed `/settings` URL)
4. Deploy `paychangu-checkout`, `paychangu-webhook`, and the updated `questionnaire-link` functions.
5. Set the PayChangu webhook URL to:
   `https://<project-ref>.supabase.co/functions/v1/paychangu-webhook`
6. Test Plus and Pro using PayChangu test mode before enabling live credentials.

The webhook signature and transaction are verified server-side before access is granted. Free accounts receive two projects and one five-minute public questionnaire window every seven days. Plus costs MWK 10,000 per 30 days and enables unlimited projects, questionnaires, and analytics. Pro costs MWK 20,000 per 30 days and adds data exports.
