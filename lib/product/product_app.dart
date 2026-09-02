import 'package:flutter/material.dart';

import '../app/brand.dart';
import '../app/theme.dart';
import 'screens.dart';
import 'trial_store.dart';

class ProductApp extends StatefulWidget {
  const ProductApp({super.key});

  @override
  State<ProductApp> createState() => _ProductAppState();
}

class _ProductAppState extends State<ProductApp> {
  final TrialStore _store = TrialStore();
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _store.load();
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TrialScope(
      store: _store,
      child: AnimatedBuilder(
        animation: _store,
        builder: (context, _) {
          if (!_store.ready) {
            return const Scaffold(
              backgroundColor: cBg,
              body: Center(
                child: CircularProgressIndicator(color: cAccent, strokeWidth: 2),
              ),
            );
          }

          return Scaffold(
            backgroundColor: cBg,
            body: SafeArea(
              bottom: false,
              child: IndexedStack(
                index: _tab,
                children: [
                  ExperimentsScreen(onOpenResults: () => setState(() => _tab = 2)),
                  const DailyLogScreen(),
                  const ResultsScreen(),
                  const SettingsScreen(),
                ],
              ),
            ),
            bottomNavigationBar: _BottomBar(
              index: _tab,
              onTap: (i) => setState(() => _tab = i),
            ),
          );
        },
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final items = [
      (icon: Icons.science_rounded, label: 'Тесты'),
      (icon: Icons.edit_calendar_rounded, label: 'Оценка'),
      (icon: Icons.bar_chart_rounded, label: 'Анализ'),
      (icon: Icons.tune_rounded, label: 'Опции'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: cSurface,
        border: Border(top: BorderSide(color: cEdge)),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 22),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      items[i].icon,
                      size: 22,
                      color: i == index ? cAccent : AppTheme.textMuted,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      items[i].label,
                      style: AppTheme.text(
                        11,
                        color: i == index ? cAccent : AppTheme.textMuted,
                        weight: i == index ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
