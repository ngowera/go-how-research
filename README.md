# GoHow Research — All-in-One University Research Software

> **Smarter Research. Better Evidence.**  
> Designed according to the *GoHow Research-Sync* business and engineering specifications.

---

## 🚀 Key Features Built into GoHow Research

### 1. 📋 Research Project Lifecycle Management
- Manage full research proposals, abstracts, and methodologies (Quantitative, Qualitative, Mixed-Methods).
- Track study population, sample size targets ($N$), and study sites/locations.
- Status management: Draft, Active, Completed, and Archived with status-coded UI stripes.

### 2. 🧩 Drag-and-Drop Questionnaire Builder
- **Question Types**:
  - Text Responses (Short & Long paragraph)
  - Numeric values with range constraints
  - Single Choice (Radio) & Multiple Choice (Checkboxes)
  - 5-point Likert Scales (Strongly Disagree $\to$ Strongly Agree)
  - 5-Star Ratings
  - Binary Yes / No toggles
  - Date pickers
- Question reordering with up/down controls.
- Dynamic options editor (add, remove, edit choices).
- Required field validation and respondent help text.

### 3. 📡 Offline-First Field Data Collection & Supabase Sync
- **Zero Internet Requirement**: All field data is saved instantly to local SQLite database via Drift.
- **Auto-Sync to Supabase**: When internet connection is re-established, pending records are pushed to Supabase PostgreSQL cloud tables.
- Continuous collection mode: "Submit & Collect Next Response" for field enumerators.

### 4. 📊 Advanced Statistical Analysis & Automated Analytics
- **Descriptive Statistics**:
  - Sample Mean ($\mu$)
  - Median ($M$)
  - Mode
  - Sample Standard Deviation ($\sigma$) & Variance ($s^2$)
  - Minimum, Maximum, Range, and Percentiles
- **Categorical & Frequency Distributions**:
  - Frequencies ($f$) and percentage breakdowns ($\%$) for categorical responses.
- **Visual Distribution Charts**:
  - Dynamic **Bar Charts** and **Pie Charts** with percentage tooltips using `fl_chart`.
- **Inferential Cross-Tabulation & Chi-Square**:
  - Interactive Contingency Tables ($R \times C$) comparing any two variables.
  - Automatic calculation of **Chi-Square ($\chi^2$) statistic**, **Degrees of Freedom ($df$)**, and **$p$-value significance interpretation** ($p < 0.05$).
- **Data Quality Indicators**:
  - Form completion rate ($\%$) and data quality score.

### 5. 👥 Participant Registry & Ethics Tracking
- Unique anonymous participant identification codes (e.g. `P-001`, `P-002`).
- Institutional Review Board (IRB) informed consent tracking.

### 6. 🎓 Multi-User & Supervisor Collaboration
- Role-based permissions: Student, Supervisor, Admin, Enumerator.
- Supervisor review portal: review questions, approve instruments, or request revisions.

### 7. 📄 Data Table & Export
- Spreadsheet-style table view of raw survey records.
- Export clean datasets to **CSV** and **Excel (`.xlsx`)**.
- Publication-ready research summary report preview.

### 8. 🎨 White Themed & Colourful UI
- Clean white background (`#FFFFFF`, `#F8FAFC`).
- Colour accents: Deep Blue (`#1565C0`), Teal (`#00897B`), Orange (`#F57C00`), Purple (`#7B1FA2`), Green (`#2E7D32`).
- Poppins modern typography.

---

## 💻 How to Build and Run on Windows (Your Windows Laptop)

Because your Windows laptop has **Visual Studio** (with the C++ Desktop workload), compiling to a native 64-bit Windows application is straightforward:

### Method A: One-Click Build
1. Copy the `gohow_research` folder to your Windows laptop.
2. Double-click `build_windows.bat`.
3. The executable will be produced in:
   ```
   build\windows\x64\runner\Release\gohow_research.exe
   ```

### Method B: Command Line (PowerShell or CMD)
```powershell
# 1. Navigate into the project directory
cd gohow_research

# 2. Enable Windows desktop support in Flutter
flutter config --enable-windows-desktop

# 3. Download dependencies
flutter pub get

# 4. Generate Drift SQLite database code
dart run build_runner build --delete-conflicting-outputs

# 5. Run in debug mode to test
flutter run -d windows

# 6. Or compile a standalone release .exe
```

---

## 🐧 How to Build and Run on Linux (This Linux PC)

All required Linux compilation tools (`clang`, `cmake`, `ninja`, `pkg-config`, and `libgtk-3-dev`) are already present on your system.

### Method A: One-Command Build Script
```bash
cd gohow_research
./build_linux.sh
```

### Method B: Step-by-Step Command Line
```bash
cd gohow_research

# 1. Enable Linux desktop support
flutter config --enable-linux-desktop

# 2. Add Linux platform runner files
flutter create --platforms=linux .

# 3. Download packages and generate Drift SQLite code
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# 4. Test run the Linux desktop app
flutter run -d linux

# 5. Build standalone release Linux executable
flutter build linux --release
```

The release executable is generated in:
```
build/linux/x64/release/bundle/gohow_research
```
To run it:
```bash
./build/linux/x64/release/bundle/gohow_research
```

---

## 🌐 Running in the Web Browser (Chrome)

You can also run GoHow Research in your browser without any native desktop compilation:
```bash
flutter run -d chrome
```
Or build a production web bundle:
```bash
flutter build web
```

The web build includes its own SQLite WebAssembly runtime (`web/sqlite3.wasm`),
so the core offline database works without a separate database server. Browser
records persist in IndexedDB, and Supabase can later synchronize them between
devices.

---

## 📱 Android, iOS, macOS, Windows, Linux, and Web

Platform runner projects are included for every standard Flutter target:

```text
android/  ios/  linux/  macos/  web/  windows/
```

Use `flutter devices` to find a connected device, then run:

```bash
flutter run -d <device-id>
```

Examples include `flutter run -d windows`, `flutter run -d linux`,
`flutter run -d chrome`, or `flutter run -d <android-device-id>`.

---

## ☁️ Supabase Cloud Backend Setup

1. Create a free project at [supabase.com](https://supabase.com).
2. Go to the **SQL Editor** in your Supabase dashboard.
3. Open `supabase_schema.sql` from this project and click **Run**.
4. Copy your **Project URL** and **anon public key** from Supabase Settings $\to$ API.
5. Open `.env` in the `gohow_research/` root folder and paste your credentials:
   ```env
   SUPABASE_URL=https://your-project-id.supabase.co
   SUPABASE_ANON_KEY=your-supabase-anon-key-here
   ```
6. The app automatically loads credentials from `.env` upon startup—no API keys or credentials are exposed in the user interface.
