import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/material_data.dart';

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
  final _c4 = TextEditingController();
  final _c5 = TextEditingController();

  @override
  void didUpdateWidget(DimensionInputs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
      _c1.clear();
      _c2.clear();
      _c3.clear();
      _c4.clear();
      _c5.clear();
    }
  }

  void _notify() {
    final a = double.tryParse(_c1.text.replaceAll(',', '.')) ?? 0;
    final b = double.tryParse(_c2.text.replaceAll(',', '.')) ?? 0;
    final c = double.tryParse(_c3.text.replaceAll(',', '.')) ?? 0;
    final d = double.tryParse(_c4.text.replaceAll(',', '.')) ?? 0;
    final e = double.tryParse(_c5.text.replaceAll(',', '.')) ?? 0;
    widget.onChanged([a, b, c, d, e]);
  }

  @override
  void dispose() {
    _c1.dispose();
    _c2.dispose();
    _c3.dispose();
    _c4.dispose();
    _c5.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = widget.profile.fieldLabels; // List<String?> длиной 5
    final active = labels.where((l) => l != null).length;

    Widget content;

    // 5 полей: два ряда (3 + 2)
    if (active == 5) {
      content = Column(
        children: [
          Row(children: [
            Expanded(child: _buildField(labels[0]!, _c1)),
            const SizedBox(width: 10),
            Expanded(child: _buildField(labels[1]!, _c2)),
            const SizedBox(width: 10),
            Expanded(child: _buildField(labels[2]!, _c3)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _buildField(labels[3]!, _c4)),
            const SizedBox(width: 10),
            Expanded(child: _buildField(labels[4]!, _c5)),
          ]),
        ],
      );
    }
    // 4 поля: два ряда (2 + 2)
    else if (active == 4) {
      content = Column(
        children: [
          Row(children: [
            Expanded(child: _buildField(labels[0]!, _c1)),
            const SizedBox(width: 10),
            Expanded(child: _buildField(labels[1]!, _c2)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _buildField(labels[2]!, _c3)),
            const SizedBox(width: 10),
            Expanded(child: _buildField(labels[3]!, _c4)),
          ]),
        ],
      );
    }
    // 1–3 поля: один ряд
    else {
      content = Row(
        children: [
          Expanded(child: _buildField(labels[0]!, _c1)),
          if (labels[1] != null) ...[
            const SizedBox(width: 10),
            Expanded(child: _buildField(labels[1]!, _c2)),
          ],
          if (labels[2] != null) ...[
            const SizedBox(width: 10),
            Expanded(child: _buildField(labels[2]!, _c3)),
          ],
        ],
      );
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        child: KeyedSubtree(
          key: ValueKey(widget.profile),
          child: content,
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
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
            _DecimalTextInputFormatter(),
            _MaxLengthFormatter(10),
          ],
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            suffixText: 'мм',
            suffixStyle: TextStyle(
              color: colorScheme.onSurfaceVariant,
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

class _DecimalTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    // Разрешаем цифры и максимум одну точку или запятую
    final regExp = RegExp(r'^\d*[\.,]?\d*$');
    if (regExp.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}
