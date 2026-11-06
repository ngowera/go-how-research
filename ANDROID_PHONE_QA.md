# Android phone review — 1 October 2026

## Changes

- Shared sign-in/sign-up design with a scientist conducting an experiment beside a PC, above the forms; compressed WebP asset (~76 KB), bounded decode size, scrollable form, safe areas, autofill and keyboard actions.
- Responsive headings, actions, project cards and dashboard statistics; questionnaire builder uses a question-type dropdown on phones, preserving the full editor width.
- Short phone workspaces scroll so toolbars remain accessible in landscape and when a keyboard reduces height. Android system navigation and drawer content respect safe areas.
- Desktop window initialization is restricted to desktop platforms.
- Fixed Supervisor role badge crash caused by dynamically accessing the enum name extension.
- Removed the missing `kuphanda.png` asset declaration and use the existing app logo for the assistant; the user's existing deletion is preserved.

## Verification

`flutter test`: **67 tests passed**, including 50 mobile layout/interaction tests. Phone coverage includes 320 × 640, 390 × 844 and 740 × 360, long project titles, registration/login at 1.3× text scaling with keyboard insets, and existing project deletion and assistant interactions.

Screens exercised: sign-in, registration, dashboard, projects, project details, questionnaire workspace, questionnaire builder, data collection, dataset, analytics, participants, reports, settings, supervisor, data capture and research assistant. Project detail and reports use a populated local project; other workflows include empty/missing questionnaire states. The public route has its existing routing test; live public questionnaire submission is not validated by these widget tests.

`flutter analyze --no-pub`: no errors; 159 lint/warning findings remain, largely existing deprecated APIs and unused/non-null assertions.

Android release compilation succeeded for the final changes with `flutter build apk --release --split-per-abi`. Output APK sizes reported by Flutter: armeabi-v7a 28.7 MB, arm64-v8a 32.5 MB, x86_64 35.2 MB. Release signing still uses the repository's existing debug signing configuration; these APKs are suitable for local testing, not a production Play Store release.

No phone or emulator was connected (`adb devices` returned an empty list). Actual frame timing, memory/battery use, camera/QR capture, microphone permissions and playback, Android file selection/export, cloud authentication/sync, and live questionnaire submission need device/end-to-end testing. Compilation and widget checks cannot establish that all devices and all data states have no issues.

## Laboratory asset

Saved at `assets/images/laboratory_auth.webp`. Generated with the built-in image generation tool, then resized and compressed for mobile use.

Prompt: “Use case: photorealistic-natural. Asset type: authentication hero for a university research mobile app. A laboratory scientist wearing a white lab coat, safety glasses and gloves carefully pipetting samples at a modern laboratory bench, with a desktop PC and monitor clearly visible beside the experiment. Natural realistic editorial photography, bright clean laboratory, soft daylight, subtle blue and teal details. Wide landscape composition with the scientist and computer both visible, suitable for a mobile banner crop. No text, logos or watermarks.”
