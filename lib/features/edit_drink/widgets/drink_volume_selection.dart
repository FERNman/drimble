import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/alcohol/alcohol.dart';
import '../../common/build_context_extensions.dart';

class DrinkVolumeSelection extends StatefulWidget {
  final List<Milliliter> standardServings;
  final Milliliter initialValue;
  final ValueChanged<Milliliter> onChanged;

  const DrinkVolumeSelection({
    required this.standardServings,
    required this.initialValue,
    required this.onChanged,
    super.key,
  });

  @override
  State<DrinkVolumeSelection> createState() => _DrinkVolumeSelectionState();
}

class _DrinkVolumeSelectionState extends State<DrinkVolumeSelection> {
  final _customAmountTextController = TextEditingController();

  late Milliliter _internalValue;
  bool _isCustomAmount = false;

  String? get _errorText {
    if (!_isCustomAmount) {
      return null;
    }

    final customAmount = _parseTextValue();
    if (customAmount > 0) {
      return null;
    } else {
      return context.l18n.edit_drink_invalidAmount;
    }
  }

  @override
  void initState() {
    super.initState();

    _internalValue = widget.initialValue;

    if (!widget.standardServings.contains(_internalValue)) {
      _isCustomAmount = true;
      _customAmountTextController.text = '$_internalValue';
    }
  }

  @override
  Widget build(BuildContext context) {
    final servingSelectionChoices = <Widget>[];

    for (final serving in widget.standardServings) {
      servingSelectionChoices.add(
        Expanded(
          child: InputChip(
            label: SizedBox(width: double.infinity, child: Text(context.l18n.common_amountInMilliliters(serving))),
            selected: !_isCustomAmount && _internalValue == serving,
            onSelected: (selected) => {_toggleChoiceChip(serving)},
          ),
        ),
      );

      servingSelectionChoices.add(const SizedBox(width: 8));
    }

    final customInput = SizedBox(
      width: 132,
      child: InputChip(
        avatar: const Icon(Icons.edit_outlined),
        label: TextFormField(
          controller: _customAmountTextController,
          decoration: _getInputDecoration(context).copyWith(errorStyle: const TextStyle(height: 0)),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) => !_isCustomAmount || (value != null && _parseTextValue() > 0) ? null : '',
          onChanged: (it) {
            setState(() {
              _setValue(_parseTextValue());
            });
          },
          onTap: _selectCustomAmount,
        ),
        selected: _isCustomAmount,
        onSelected: (_) => _selectCustomAmount(),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ...servingSelectionChoices,
            customInput,
          ],
        ),
        _errorText == null ? const SizedBox() : _buildError(context),
      ],
    );
  }

  Widget _buildError(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 4),
      child: Text(
        _errorText!,
        style: context.textTheme.bodySmall!.copyWith(color: context.colorScheme.error),
      ),
    );
  }

  @override
  void dispose() {
    _customAmountTextController.dispose();
    super.dispose();
  }

  InputDecoration _getInputDecoration(BuildContext context) {
    final inputDecoration = InputDecoration.collapsed(hintText: context.l18n.edit_drink_enterAmount);
    if (_customAmountTextController.text.isNotEmpty) {
      return inputDecoration.copyWith(suffixText: context.l18n.common_milliliters);
    }

    return inputDecoration;
  }

  void _toggleChoiceChip(Milliliter serving) {
    setState(() {
      _setValue(serving);
      _isCustomAmount = false;
    });

    FocusScope.of(context).unfocus();
  }

  void _selectCustomAmount() {
    setState(() {
      _setValue(_parseTextValue());
      _isCustomAmount = true;
    });

    _customAmountTextController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _customAmountTextController.value.text.length,
    );
  }

  void _setValue(Milliliter newValue) {
    _internalValue = newValue;
    widget.onChanged(newValue);
  }

  Milliliter _parseTextValue() {
    if (_customAmountTextController.text.isNotEmpty) {
      return int.parse(_customAmountTextController.text);
    } else {
      return 0;
    }
  }
}
