import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrialLog {
  final int dayIndex;
  final String variant; // 'A' or 'B'
  final int score; // 1 to 5
  final String note;

  TrialLog({
    required this.dayIndex,
    required this.variant,
    required this.score,
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
        'dayIndex': dayIndex,
        'variant': variant,
        'score': score,
        'note': note,
      };

  static TrialLog fromJson(Map<String, dynamic> j) => TrialLog(
        dayIndex: (j['dayIndex'] as num?)?.toInt() ?? 1,
        variant: (j['variant'] ?? 'A').toString(),
        score: (j['score'] as num?)?.toInt() ?? 3,
        note: (j['note'] ?? '').toString(),
      );
}

class Trial {
  final String id;
  String title;
  String hypothesis;
  String variantA;
  String variantB;
  int days;
  final List<TrialLog> logs;

  Trial({
    required this.id,
    required this.title,
    required this.hypothesis,
    required this.variantA,
    required this.variantB,
    this.days = 7,
    List<TrialLog>? logs,
  }) : logs = logs ?? [];

  List<TrialLog> get logsA => logs.where((l) => l.variant == 'A').toList();
  List<TrialLog> get logsB => logs.where((l) => l.variant == 'B').toList();

  double get avgScoreA => logsA.isEmpty ? 0.0 : logsA.fold(0, (sum, l) => sum + l.score) / logsA.length;
  double get avgScoreB => logsB.isEmpty ? 0.0 : logsB.fold(0, (sum, l) => sum + l.score) / logsB.length;

  String get winner {
    if (logs.length < 2) return 'Недостаточно данных';
    if ((avgScoreA - avgScoreB).abs() < 0.2) return 'Ничья (эффект равный)';
    return avgScoreA > avgScoreB ? 'Вариант А: $variantA' : 'Вариант Б: $variantB';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'hypothesis': hypothesis,
        'variantA': variantA,
        'variantB': variantB,
        'days': days,
        'logs': logs.map((l) => l.toJson()).toList(),
      };

  static Trial fromJson(Map<String, dynamic> j) => Trial(
        id: (j['id'] ?? '').toString(),
        title: (j['title'] ?? 'Эксперимент').toString(),
        hypothesis: (j['hypothesis'] ?? '').toString(),
        variantA: (j['variantA'] ?? 'Вариант А').toString(),
        variantB: (j['variantB'] ?? 'Вариант Б').toString(),
        days: (j['days'] as num?)?.toInt() ?? 7,
        logs: (j['logs'] as List? ?? [])
            .map((e) => TrialLog.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class TrialStore extends ChangeNotifier {
  static const _trialsKey = 'tinytrial_trials_v1';

  final List<Trial> _trials = [];
  bool _ready = false;
  Trial? _activeTrial;

  bool get ready => _ready;
  List<Trial> get trials => List.unmodifiable(_trials);
  Trial get activeTrial => _activeTrial ?? _trials.first;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_trialsKey);
      if (raw != null) {
        final list = jsonDecode(raw) as List;
        _trials.clear();
        for (final item in list) {
          _trials.add(Trial.fromJson(item as Map<String, dynamic>));
        }
      }
    } catch (_) {}

    if (_trials.isEmpty) {
      _seedDemoTrials();
    }

    _activeTrial = _trials.first;
    _ready = true;
    notifyListeners();
  }

  void _seedDemoTrials() {
    _trials.clear();
    _trials.addAll([
      Trial(
        id: 't1',
        title: 'Утренний кофе vs Зелёный чай',
        hypothesis: 'Зелёный чай даёт более ровную энергию без спадов во второй половине дня',
        variantA: 'Эспрессо утром',
        variantB: 'Матча / Зелёный чай',
        days: 7,
        logs: [
          TrialLog(dayIndex: 1, variant: 'A', score: 4, note: 'Быстрый прилив сил, к обеду спад'),
          TrialLog(dayIndex: 2, variant: 'B', score: 5, note: 'Мягкий фокус без тревожности'),
          TrialLog(dayIndex: 3, variant: 'A', score: 3, note: 'Тянуло на вторую чашку'),
          TrialLog(dayIndex: 4, variant: 'B', score: 5, note: 'Отличная концентрация на весь день'),
        ],
      ),
      Trial(
        id: 't2',
        title: 'Книга перед сном vs Прогулка',
        hypothesis: 'Прогулка на свежем воздухе улучшает глубину сна',
        variantA: '30 мин книги',
        variantB: '20 мин вечерней прогулки',
        days: 7,
        logs: [
          TrialLog(dayIndex: 1, variant: 'A', score: 4),
          TrialLog(dayIndex: 2, variant: 'B', score: 5),
        ],
      ),
    ]);
  }

  void selectTrial(Trial trial) {
    _activeTrial = trial;
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_trialsKey, jsonEncode(_trials.map((t) => t.toJson()).toList()));
    } catch (_) {}
  }

  Future<void> createTrial(String title, String hypothesis, String variantA, String variantB) async {
    final trial = Trial(
      id: 't_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      hypothesis: hypothesis.trim(),
      variantA: variantA.trim(),
      variantB: variantB.trim(),
      days: 7,
    );
    _trials.add(trial);
    _activeTrial = trial;
    notifyListeners();
    await _persist();
  }

  Future<void> logDailyScore(int dayIndex, String variant, int score, String note) async {
    if (_activeTrial == null) return;
    _activeTrial!.logs.removeWhere((l) => l.dayIndex == dayIndex && l.variant == variant);
    _activeTrial!.logs.add(TrialLog(
      dayIndex: dayIndex,
      variant: variant,
      score: score,
      note: note.trim(),
    ));
    notifyListeners();
    await _persist();
  }

  Future<void> deleteTrial(Trial trial) async {
    _trials.removeWhere((t) => t.id == trial.id);
    if (_activeTrial?.id == trial.id) {
      _activeTrial = _trials.isNotEmpty ? _trials.first : null;
    }
    notifyListeners();
    await _persist();
  }

  Future<void> resetAll() async {
    _trials.clear();
    _seedDemoTrials();
    _activeTrial = _trials.first;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_trialsKey);
    } catch (_) {}
  }
}

class TrialScope extends InheritedNotifier<TrialStore> {
  const TrialScope({super.key, required TrialStore store, required super.child})
      : super(notifier: store);

  static TrialStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<TrialScope>();
    assert(scope != null, 'TrialScope not found');
    return scope!.notifier!;
  }
}
