// lib/features/dashboard/widgets/period_selector.dart
import 'package:flutter/material.dart';

const _periods = [
  ('day', 'Hôm nay'),
  ('week', '7 ngày'),
  ('month', '30 ngày'),
  ('quarter', 'Quý này'),
  ('year', 'Năm nay'),
];

class PeriodSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const PeriodSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: _periods
          .map(
            (p) => ButtonSegment(
              value: p.$1,
              label: Text(p.$2, style: const TextStyle(fontSize: 12)),
            ),
          )
          .toList(),
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
      style: ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        side: WidgetStateProperty.all(
          BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}