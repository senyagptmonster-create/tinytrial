import 'package:flutter/material.dart';

import '../app/brand.dart';
import '../app/theme.dart';
import 'trial_store.dart';

/// Экран 1. Каталог A/B экспериментов
class ExperimentsScreen extends StatelessWidget {
  const ExperimentsScreen({super.key, required this.onOpenResults});

  final VoidCallback onOpenResults;

  @override
  Widget build(BuildContext context) {
    final store = TrialScope.of(context);
    final trials = store.trials;

    return Scaffold(
      backgroundColor: cBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TinyTrial', style: AppTheme.display(28)),
                      const SizedBox(height: 4),
                      Text('A/B микро-эксперименты для привычек и жизни', style: AppTheme.text(13.5, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_rounded, color: cAccent, size: 36),
                  onPressed: () => _showNewTrialDialog(context, store),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ...trials.map((t) {
              final isSel = store.activeTrial.id == t.id;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: cSurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSel ? cAccent : cEdge,
                    width: isSel ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cAccent.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: cAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('${t.logs.length} отчётов', style: AppTheme.text(12, color: cAccent, weight: FontWeight.w700)),
                          ),
                          if (trials.length > 1)
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                              onPressed: () => store.deleteTrial(t),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(t.title, style: AppTheme.display(19)),
                      const SizedBox(height: 4),
                      Text(t.hypothesis, style: AppTheme.text(13, color: AppTheme.textMuted)),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: cBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: cEdge)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('A: ${t.variantA}', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTheme.text(12, color: cAccent, weight: FontWeight.w700)),
                                  Text('${t.avgScoreA.toStringAsFixed(1)} / 5.0', style: AppTheme.display(14)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: cBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: cEdge)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('B: ${t.variantB}', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTheme.text(12, color: cAccent2, weight: FontWeight.w700)),
                                  Text('${t.avgScoreB.toStringAsFixed(1)} / 5.0', style: AppTheme.display(14)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: cAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () {
                            store.selectTrial(t);
                            onOpenResults();
                          },
                          icon: const Icon(Icons.bar_chart_rounded, size: 20),
                          label: Text('Сравнить результаты', style: AppTheme.text(14, color: Colors.white, weight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showNewTrialDialog(BuildContext context, TrialStore store) {
    final titleCtrl = TextEditingController(text: 'Медитация vs Растяжка');
    final hypoCtrl = TextEditingController(text: 'Что быстрее снимает дневной стресс');
    final varACtrl = TextEditingController(text: '15 мин дыхания');
    final varBCtrl = TextEditingController(text: '15 мин стретчинга');

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cSurface,
        title: Text('Новый A/B эксперимент', style: AppTheme.display(20)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: 'Название теста',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: hypoCtrl,
                decoration: InputDecoration(
                  labelText: 'Гипотеза',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: varACtrl,
                decoration: InputDecoration(
                  labelText: 'Вариант А',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: varBCtrl,
                decoration: InputDecoration(
                  labelText: 'Вариант Б',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Отмена')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: cAccent),
            onPressed: () async {
              final t = titleCtrl.text.trim();
              if (t.isNotEmpty) {
                await store.createTrial(t, hypoCtrl.text.trim(), varACtrl.text.trim(), varBCtrl.text.trim());
                if (ctx.mounted) Navigator.of(ctx).pop();
              }
            },
            child: const Text('Запустить тест'),
          ),
        ],
      ),
    );
  }
}

/// Экран 2. Оценка дня
class DailyLogScreen extends StatefulWidget {
  const DailyLogScreen({super.key});

  @override
  State<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends State<DailyLogScreen> {
  String _variant = 'A';
  int _score = 4;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = TrialScope.of(context);
    final trial = store.activeTrial;

    return Scaffold(
      backgroundColor: cBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          children: [
            Text('Оценка дня', style: AppTheme.display(28)),
            const SizedBox(height: 4),
            Text('Зафиксируй эффект от выбранного варианта', style: AppTheme.text(13.5, color: AppTheme.textMuted)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cEdge),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Тест: ${trial.title}', style: AppTheme.display(16)),
                  const SizedBox(height: 4),
                  Text('Гипотеза: ${trial.hypothesis}', style: AppTheme.text(12.5, color: AppTheme.textMuted)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Какой вариант тестировался сегодня?', style: AppTheme.display(16)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _variant = 'A'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _variant == 'A' ? cAccent.withValues(alpha: 0.15) : cSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _variant == 'A' ? cAccent : cEdge, width: 2),
                      ),
                      child: Column(
                        children: [
                          Text('Вариант А', style: TextStyle(color: cAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(trial.variantA, textAlign: TextAlign.center, style: AppTheme.text(14, color: cInk, weight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _variant = 'B'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _variant == 'B' ? cAccent2.withValues(alpha: 0.15) : cSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _variant == 'B' ? cAccent2 : cEdge, width: 2),
                      ),
                      child: Column(
                        children: [
                          Text('Вариант Б', style: TextStyle(color: cAccent2, fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(trial.variantB, textAlign: TextAlign.center, style: AppTheme.text(14, color: cInk, weight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Оценка эффекта: $_score / 5', style: AppTheme.display(16)),
            Slider(
              value: _score.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              activeColor: _variant == 'A' ? cAccent : cAccent2,
              onChanged: (v) => setState(() => _score = v.toInt()),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _noteController,
              maxLines: 2,
              style: AppTheme.text(15, color: cInk),
              decoration: InputDecoration(
                labelText: 'Заметка по самочувствию / фокусу',
                filled: true,
                fillColor: cSurface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: cEdge)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _variant == 'A' ? cAccent : cAccent2,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () async {
                  await store.logDailyScore(trial.logs.length + 1, _variant, _score, _noteController.text.trim());
                  _noteController.clear();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Отчёт за день успешно записан!')),
                    );
                  }
                },
                child: Text('Сохранить отчёт', style: AppTheme.text(15.5, color: Colors.white, weight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Экран 3. Результаты и сравнительный график
class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = TrialScope.of(context);
    final trial = store.activeTrial;

    return Scaffold(
      backgroundColor: cBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          children: [
            Text('Анализ данных', style: AppTheme.display(28)),
            const SizedBox(height: 4),
            Text('Статистика сравнения вариантов', style: AppTheme.text(13.5, color: AppTheme.textMuted)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cSurface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: cEdge),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.emoji_events_rounded, color: cAccent, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Лидер эксперимента', style: AppTheme.text(12, color: AppTheme.textMuted)),
                            Text(trial.winner, style: AppTheme.display(16, color: cAccent)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Сравнение средних баллов', style: AppTheme.display(18)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cSurface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: cEdge),
              ),
              child: SizedBox(
                height: 140,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _BarColumn(title: 'A: ${trial.variantA}', score: trial.avgScoreA, color: cAccent),
                    _BarColumn(title: 'B: ${trial.variantB}', score: trial.avgScoreB, color: cAccent2),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('История всех дней (${trial.logs.length})', style: AppTheme.display(18)),
            const SizedBox(height: 10),
            ...trial.logs.map((l) {
              final isA = l.variant == 'A';
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cEdge),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isA ? cAccent : cAccent2).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Вариант ${l.variant}', style: TextStyle(color: isA ? cAccent : cAccent2, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${l.score} / 5 баллов', style: AppTheme.text(14, color: cInk, weight: FontWeight.w700)),
                          if (l.note.isNotEmpty) Text(l.note, style: AppTheme.text(12, color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _BarColumn extends StatelessWidget {
  const _BarColumn({required this.title, required this.score, required this.color});

  final String title;
  final double score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final heightRatio = (score / 5.0).clamp(0.1, 1.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(score.toStringAsFixed(1), style: AppTheme.display(15, color: color)),
        const SizedBox(height: 6),
        Container(
          width: 48,
          height: 70 * heightRatio,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 120,
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.text(11.5, color: AppTheme.textMuted),
          ),
        ),
      ],
    );
  }
}

/// Экран 4. Настройки
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = TrialScope.of(context);

    return Scaffold(
      backgroundColor: cBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          children: [
            Text('Настройки', style: AppTheme.display(28)),
            const SizedBox(height: 4),
            Text('TinyTrial v1.0.0', style: AppTheme.text(13.5, color: AppTheme.textMuted)),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: cSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cEdge),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.science_outlined, color: cAccent),
                    title: Text('Экспериментов в базе', style: AppTheme.text(15, color: cInk)),
                    trailing: Text('${store.trials.length}', style: AppTheme.text(15, color: cAccent, weight: FontWeight.w700)),
                  ),
                  const Divider(height: 1, color: cEdge),
                  ListTile(
                    leading: const Icon(Icons.restart_alt_rounded, color: Colors.redAccent),
                    title: const Text('Сбросить все эксперименты', style: TextStyle(color: Colors.redAccent)),
                    onTap: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: cSurface,
                          title: Text('Сбросить тесты?', style: AppTheme.display(18)),
                          content: Text('Все оценки и данные будут удалены.', style: AppTheme.text(14, color: cInk)),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Отмена')),
                            FilledButton(
                              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Сбросить'),
                            ),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await store.resetAll();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
