import 'package:flutter/material.dart';

import '../../common/build_context_extensions.dart';

class SearchDrinkAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ValueChanged<String> onSearchChanged;

  const SearchDrinkAppBar({
    required this.onSearchChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: TextField(
          autofocus: true,
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            prefixIcon: const BackButton(),
            hintText: context.l10n.search_drink_whatAreYouLookingFor,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64 + 2 * 16); // TODO: Remove hard-coded value
}
