part of '../cash_view.dart';

class CashHistoryTab extends StatelessWidget {
  const CashHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CashController>(
      builder: (context, controller, _) {
        if (controller.isLoadingHistory) {
          return const Center(child: CircularProgressIndicator());
        }

        final groupBy = controller.historyGroupBy;
        return RefreshIndicator(
          onRefresh: controller.loadHistory,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              FilterDropdown<int>(
                label: 'Local',
                value: controller.selectedStoreId,
                items: controller.stores
                    .map(
                      (s) => DropdownMenuItem<int>(
                        value: (s['id'] as num).toInt(),
                        child: Text(s['name'] as String),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.selectStore(value);
                    controller.loadHistory();
                  }
                },
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  for (final opt in [
                    ('year', 'Año'),
                    ('month', 'Mes'),
                    ('week', 'Semana'),
                  ])
                    ChoiceChip(
                      label: Text(opt.$2),
                      selected: groupBy == opt.$1,
                      onSelected: (_) => controller.setHistoryGroupBy(opt.$1),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (groupBy != 'year' &&
                  controller.historyAvailableYears.isNotEmpty) ...[
                FilterDropdown<String>(
                  label: 'Año',
                  value: controller.historyYear,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todos')),
                    ...controller.historyAvailableYears.map(
                      (y) => DropdownMenuItem(value: y, child: Text(y)),
                    ),
                  ],
                  onChanged: controller.setHistoryYear,
                ),
                const SizedBox(height: 12),
              ],
              if (groupBy == 'month') ...[
                _MonthPicker(
                  year: controller.historyYear,
                  selected: controller.historyMonth,
                  onChanged: controller.setHistoryMonth,
                ),
                const SizedBox(height: 12),
              ],
              if (groupBy == 'week') ...[
                _WeekPicker(
                  year: controller.historyYear,
                  selected: controller.historyWeek,
                  sessions: controller.historySessions,
                  isoWeekFn: _isoWeek,
                  onChanged: controller.setHistoryWeek,
                ),
                const SizedBox(height: 12),
              ],
              if (controller.historySessions.isEmpty)
                const Card(
                  elevation: 4,
                  color: AppColors.whiteOverlay,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No hay cajas en este período'),
                  ),
                )
              else
                ...controller.historySessions.map(
                  (s) =>
                      _HistorySessionCard(session: s, formatDate: _formatDate),
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(String? iso) {
    if (iso == null) return '-';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/${dt.year}  '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  String _isoWeek(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final dayOfYear = dt.difference(DateTime(dt.year, 1, 1)).inDays + 1;
      final week = ((dayOfYear - dt.weekday + 10) ~/ 7).toString().padLeft(
        2,
        '0',
      );
      return '${dt.year}-$week';
    } catch (_) {
      return '';
    }
  }
}
