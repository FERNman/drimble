import 'package:flutter/material.dart';

import '../../common/build_context_extensions.dart';

class SearchField extends StatelessWidget {
  final GestureTapCallback onSearch;

  const SearchField({
    required this.onSearch,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onTap: () => onSearch(),
      readOnly: true,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(),
        hintText: context.l18n.add_drink_search,
        suffixIcon: const Icon(Icons.search),
      ),
    );
  }
}
