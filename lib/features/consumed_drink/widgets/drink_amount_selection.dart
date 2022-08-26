import 'package:flutter/material.dart';

import '../../../domain/drink/milliliter.dart';

class AmountSelection extends StatefulWidget {
  final List<Milliliter> standardServings;
  final Milliliter initialValue;
  final ValueChanged<Milliliter> onChanged;

  const AmountSelection({
    required this.standardServings,
    required this.initialValue,
    required this.onChanged,
    super.key,
  });

  @override
  State<AmountSelection> createState() => _AmountSelectionState();
}

class _AmountSelectionState extends State<AmountSelection> {
  final _customAmountTextController = TextEditingController();

  late Milliliter _internalValue;
  bool _isCustomAmount = false;

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
      servingSelectionChoices.add(Expanded(
        child: ChoiceChip(
          avatar: const Icon(Icons.abc_outlined),
          label: SizedBox(width: double.infinity, child: Text('${serving}ml')),
          selected: !_isCustomAmount && _internalValue == serving,
          onSelected: (selected) => {_toggleChoiceChip(serving)},
        ),
      ));

      servingSelectionChoices.add(const SizedBox(width: 8));
    }

    final customInput = Expanded(
      child: ChoiceChip(
        avatar: const Icon(Icons.edit_outlined),
        label: TextField(
          decoration: _getInputDecoration(),
          keyboardType: TextInputType.number,
          controller: _customAmountTextController,
          onChanged: (it) {
            setState(() {
              _setValue(_parseTextValue());
            });
          },
          onTap: _selectCustomAmount,
        ),
        selected: _isCustomAmount,
        onSelected: (selected) => {_selectCustomAmount()},
      ),
    );

    return Row(children: [
      ...servingSelectionChoices,
      customInput,
    ]);
  }

  @override
  void dispose() {
    _customAmountTextController.dispose();
    super.dispose();
  }

  InputDecoration _getInputDecoration() {
    const inputDecoration = InputDecoration.collapsed(hintText: 'enter');
    if (_customAmountTextController.text.isNotEmpty) {
      return inputDecoration.copyWith(suffix: const Text('ml'));
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
