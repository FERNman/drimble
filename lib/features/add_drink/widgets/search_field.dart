import 'package:flutter/material.dart';

class SearchField extends StatefulWidget {
  final ValueChanged<String> onChange;

  const SearchField({required this.onChange, super.key});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: 'Search...',
        suffixIcon: _trailingIcon(),
      ),
      onChanged: (value) {
        widget.onChange(value);
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _trailingIcon() {
    if (_controller.text.isEmpty) {
      return const Icon(Icons.search);
    }

    return IconButton(
      onPressed: () {
        FocusScope.of(context).unfocus();
        _controller.clear();
        setState(() {});
      },
      icon: const Icon(Icons.clear),
    );
  }
}
