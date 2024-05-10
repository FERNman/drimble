import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/user/body_composition.dart';
import '../../../infra/l10n/body_composition_translations.dart';
import '../../common/build_context_extensions.dart';
import '../profile_form_value.dart';

class ProfileForm extends StatelessWidget {
  final ProfileFormValue value;
  final ValueChanged<ProfileFormValue> onValueChanged;

  const ProfileForm({required this.value, required this.onValueChanged, super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _BirthYearFormField(
                  value: value.birthyear,
                  onValueChanged: (birthyear) => onValueChanged(value.copyWith(birthyear: birthyear)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HeightFormField(
                  value: value.height,
                  onValueChanged: (height) => onValueChanged(value.copyWith(height: height)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _WeightFormField(
                  value: value.weight,
                  onValueChanged: (weight) => onValueChanged(value.copyWith(weight: weight)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField(
                  value: value.bodyComposition,
                  decoration: InputDecoration(
                    label: Text(context.l10n.profile_bodyComposition),
                  ),
                  items: BodyComposition.values
                      .map((e) => DropdownMenuItem(value: e, child: Text(e.translate(context))))
                      .toList(),
                  onChanged: (changedValue) {
                    if (changedValue is BodyComposition) {
                      onValueChanged(value.copyWith(bodyComposition: changedValue));
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BirthYearFormField extends StatelessWidget {
  static final _validationExpression = RegExp(r'^\d{4}$');

  final int value;
  final ValueChanged<int> onValueChanged;

  const _BirthYearFormField({
    required this.value,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: '$value',
      decoration: InputDecoration(label: Text(context.l10n.profile_birthyear), helperText: ' '),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: _onChanged,
    );
  }

  void _onChanged(String rawValue) {
    if (_validationExpression.hasMatch(rawValue)) {
      final parsedValue = int.parse(rawValue);
      onValueChanged(parsedValue);
    }
  }
}

class _HeightFormField extends StatelessWidget {
  final int value;
  final ValueChanged<int> onValueChanged;

  const _HeightFormField({
    required this.value,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: '$value',
      decoration: InputDecoration(label: Text(context.l10n.profile_height), suffixText: 'cm', helperText: ' '),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: _onChanged,
    );
  }

  void _onChanged(String rawValue) {
    final parsedValue = int.tryParse(rawValue);
    if (parsedValue != null) {
      onValueChanged(parsedValue);
    }
  }
}

class _WeightFormField extends StatelessWidget {
  final int value;
  final ValueChanged<int> onValueChanged;

  const _WeightFormField({
    required this.value,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: '$value',
      decoration: InputDecoration(label: Text(context.l10n.profile_weight), suffixText: 'kg'),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: _onChanged,
    );
  }

  void _onChanged(String rawValue) {
    final parsedValue = int.tryParse(rawValue);
    if (parsedValue != null) {
      onValueChanged(parsedValue);
    }
  }
}
