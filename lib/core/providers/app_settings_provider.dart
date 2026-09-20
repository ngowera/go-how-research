import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FormDisplayMode { paged, singlePage }

enum StatisticalSignificanceLevel { p05, p01, p001 }

enum CitationStyle { apa7, harvard, ieee, chicago }

enum ParticipantIdentityMode { codeOnly, nameAndCode }

class AppSettings {
  final String department;
  final String orcidId;
  final String degreeProgram;
  final FormDisplayMode formDisplayMode;
  final int autoSaveSeconds;
  final bool gpsTaggingEnabled;
  final String participantPrefix;
  final double confidenceLevel;
  final int decimalPrecision;
  final String chartPalette;
  final CitationStyle citationStyle;
  final bool autoSyncOnReconnect;
  final ParticipantIdentityMode participantIdentityMode;
  final int accentColor;
  final bool compactLayout;
  final int sidebarColor;

  const AppSettings({
    this.department = 'Faculty of Health Sciences & Technology',
    this.orcidId = '',
    this.degreeProgram = 'Postgraduate Research (MSc / PhD)',
    this.formDisplayMode = FormDisplayMode.singlePage,
    this.autoSaveSeconds = 30,
    this.gpsTaggingEnabled = false,
    this.participantPrefix = 'P-',
    this.confidenceLevel = 0.05,
    this.decimalPrecision = 2,
    this.chartPalette = 'Academic Blue & Teal',
    this.citationStyle = CitationStyle.apa7,
    this.autoSyncOnReconnect = true,
    this.participantIdentityMode = ParticipantIdentityMode.codeOnly,
    this.accentColor = 0xFF1565C0,
    this.compactLayout = false,
    this.sidebarColor = 0xFFFFFFFF,
  });

  AppSettings copyWith({
    String? department,
    String? orcidId,
    String? degreeProgram,
    FormDisplayMode? formDisplayMode,
    int? autoSaveSeconds,
    bool? gpsTaggingEnabled,
    String? participantPrefix,
    double? confidenceLevel,
    int? decimalPrecision,
    String? chartPalette,
    CitationStyle? citationStyle,
    bool? autoSyncOnReconnect,
    ParticipantIdentityMode? participantIdentityMode,
    int? accentColor,
    bool? compactLayout,
    int? sidebarColor,
  }) {
    return AppSettings(
      accentColor: accentColor ?? this.accentColor,
      compactLayout: compactLayout ?? this.compactLayout,
      sidebarColor: sidebarColor ?? this.sidebarColor,
      department: department ?? this.department,
      orcidId: orcidId ?? this.orcidId,
      degreeProgram: degreeProgram ?? this.degreeProgram,
      formDisplayMode: formDisplayMode ?? this.formDisplayMode,
      autoSaveSeconds: autoSaveSeconds ?? this.autoSaveSeconds,
      gpsTaggingEnabled: gpsTaggingEnabled ?? this.gpsTaggingEnabled,
      participantPrefix: participantPrefix ?? this.participantPrefix,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
      decimalPrecision: decimalPrecision ?? this.decimalPrecision,
      chartPalette: chartPalette ?? this.chartPalette,
      citationStyle: citationStyle ?? this.citationStyle,
      autoSyncOnReconnect: autoSyncOnReconnect ?? this.autoSyncOnReconnect,
      participantIdentityMode:
          participantIdentityMode ?? this.participantIdentityMode,
    );
  }
}

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(const AppSettings()) {
    _loadFromPrefs();
  }

  static const _kPrefix = 'gohow_setting_';

  Future<void> _loadFromPrefs() async {
    try {
      final p = await SharedPreferences.getInstance();
      state = AppSettings(
        accentColor: p.getInt('${_kPrefix}accent') ?? state.accentColor,
        compactLayout: p.getBool('${_kPrefix}compact') ?? false,
        sidebarColor: p.getInt('${_kPrefix}sidebar') ?? state.sidebarColor,
        department: p.getString('${_kPrefix}dept') ?? state.department,
        orcidId: p.getString('${_kPrefix}orcid') ?? state.orcidId,
        degreeProgram: p.getString('${_kPrefix}degree') ?? state.degreeProgram,
        formDisplayMode: (p.getString('${_kPrefix}display_mode') == 'paged')
            ? FormDisplayMode.paged
            : FormDisplayMode.singlePage,
        autoSaveSeconds:
            p.getInt('${_kPrefix}autosave') ?? state.autoSaveSeconds,
        gpsTaggingEnabled:
            p.getBool('${_kPrefix}gps') ?? state.gpsTaggingEnabled,
        participantPrefix:
            p.getString('${_kPrefix}part_prefix') ?? state.participantPrefix,
        confidenceLevel:
            p.getDouble('${_kPrefix}conf_level') ?? state.confidenceLevel,
        decimalPrecision:
            p.getInt('${_kPrefix}decimals') ?? state.decimalPrecision,
        chartPalette: p.getString('${_kPrefix}palette') ?? state.chartPalette,
        citationStyle: _parseCitation(p.getString('${_kPrefix}citation')),
        autoSyncOnReconnect:
            p.getBool('${_kPrefix}autosync') ?? state.autoSyncOnReconnect,
        participantIdentityMode:
            p.getString('${_kPrefix}identity_mode') == 'nameAndCode'
                ? ParticipantIdentityMode.nameAndCode
                : ParticipantIdentityMode.codeOnly,
      );
    } catch (_) {}
  }

  CitationStyle _parseCitation(String? str) {
    if (str == 'harvard') return CitationStyle.harvard;
    if (str == 'ieee') return CitationStyle.ieee;
    if (str == 'chicago') return CitationStyle.chicago;
    return CitationStyle.apa7;
  }

  Future<void> updateDepartment(String v) async {
    state = state.copyWith(department: v);
    final p = await SharedPreferences.getInstance();
    await p.setString('${_kPrefix}dept', v);
  }

  Future<void> updateAppearance({int? accentColor, bool? compact}) async {
    state = state.copyWith(accentColor: accentColor, compactLayout: compact);
    final p = await SharedPreferences.getInstance();
    await p.setInt('${_kPrefix}accent', state.accentColor);
    await p.setBool('${_kPrefix}compact', state.compactLayout);
  }

  Future<void> updateSidebarColor(int color) async {
    state = state.copyWith(sidebarColor: color);
    final p = await SharedPreferences.getInstance();
    await p.setInt('${_kPrefix}sidebar', color);
  }

  Future<void> updateOrcid(String v) async {
    state = state.copyWith(orcidId: v);
    final p = await SharedPreferences.getInstance();
    await p.setString('${_kPrefix}orcid', v);
  }

  Future<void> updateDegreeProgram(String v) async {
    state = state.copyWith(degreeProgram: v);
    final p = await SharedPreferences.getInstance();
    await p.setString('${_kPrefix}degree', v);
  }

  Future<void> updateDisplayMode(FormDisplayMode v) async {
    state = state.copyWith(formDisplayMode: v);
    final p = await SharedPreferences.getInstance();
    await p.setString('${_kPrefix}display_mode', v.name);
  }

  Future<void> updateAutoSave(int seconds) async {
    state = state.copyWith(autoSaveSeconds: seconds);
    final p = await SharedPreferences.getInstance();
    await p.setInt('${_kPrefix}autosave', seconds);
  }

  Future<void> updateGpsTagging(bool enabled) async {
    state = state.copyWith(gpsTaggingEnabled: enabled);
    final p = await SharedPreferences.getInstance();
    await p.setBool('${_kPrefix}gps', enabled);
  }

  Future<void> updateParticipantPrefix(String prefix) async {
    state = state.copyWith(participantPrefix: prefix);
    final p = await SharedPreferences.getInstance();
    await p.setString('${_kPrefix}part_prefix', prefix);
  }

  Future<void> updateConfidenceLevel(double alpha) async {
    state = state.copyWith(confidenceLevel: alpha);
    final p = await SharedPreferences.getInstance();
    await p.setDouble('${_kPrefix}conf_level', alpha);
  }

  Future<void> updateDecimalPrecision(int decimals) async {
    state = state.copyWith(decimalPrecision: decimals);
    final p = await SharedPreferences.getInstance();
    await p.setInt('${_kPrefix}decimals', decimals);
  }

  Future<void> updateChartPalette(String palette) async {
    state = state.copyWith(chartPalette: palette);
    final p = await SharedPreferences.getInstance();
    await p.setString('${_kPrefix}palette', palette);
  }

  Future<void> updateCitationStyle(CitationStyle style) async {
    state = state.copyWith(citationStyle: style);
    final p = await SharedPreferences.getInstance();
    await p.setString('${_kPrefix}citation', style.name);
  }

  Future<void> updateAutoSync(bool v) async {
    state = state.copyWith(autoSyncOnReconnect: v);
    final p = await SharedPreferences.getInstance();
    await p.setBool('${_kPrefix}autosync', v);
  }

  Future<void> updateParticipantIdentityMode(
      ParticipantIdentityMode mode) async {
    state = state.copyWith(participantIdentityMode: mode);
    final p = await SharedPreferences.getInstance();
    await p.setString('${_kPrefix}identity_mode', mode.name);
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  return AppSettingsNotifier();
});
