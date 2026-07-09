import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/material_data.dart';
import '../theme/app_theme.dart';

class DimensionInputs extends StatefulWidget {
  final ProfileType profile;
  final ValueChanged<List<double>> onChanged;

  const DimensionInputs({
    super.key,
    required this.profile,
    required this.onChanged,
  });

  @override
  State<DimensionInputs> createState() => _DimensionInputsState();
}

class _DimensionInputsState extends State<DimensionInputs> {
  final _c1 = TextEditingController();
  final _c2 = TextEditingController();
  final _c3 = TextEditingController();

  @override
  void didUpdateWidget(DimensionInputs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
      _c1.clear();
      _c2.clear();
      _c3.clear();
    }
  }

  void _notify() {
    final a = double.tryParse(_c1.text.replaceAll(',', '.')) ?? 0;
    final b = double.tryParse(_c2.text.replaceAll(',', '.')) ?? 0;
    final c = double.tryParse(_c3.text.replaceAll(',', '.')) ?? 0;
    widget.onChanged([a, b, c]);
  }

  @override
  void dispose() {
    _c1.dispose();
    _c2.dispose();
    _c3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = widget.profile.fieldLabels;
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildField(labels[0]!, _c1)),
            const SizedBox(width: 10),
            Expanded(child: _buildField(labels[1]!, _c2)),
            if (labels[2] != null) ...[
              const SizedBox(width: 10),
              Expanded(child: _buildField(labels[2]!, _c3)),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: (_) => _notify(),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
            _MaxLengthFormatter(10),
          ],
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: const InputDecoration(
            suffixText: 'мм',
            suffixStyle: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
            hintText: '0',
          ),
        ),
      ],
    );
  }
}

class _MaxLengthFormatter extends TextInputFormatter {
  final int max;
  _MaxLengthFormatter(this.max);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue newVal) {
    if (newVal.text.length > max) return old;
    return newVal;
  }
}
