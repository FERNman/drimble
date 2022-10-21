import 'package:flutter/material.dart';

import '../build_context_extensions.dart';

class VerticalLineChartLabels extends StatelessWidget {
  final double height;
  final double range;

  final List<double> _values;

  VerticalLineChartLabels({required this.height, required this.range, int labelCount = 3, super.key})
      : _values = List.generate(labelCount - 1, (index) => range / (labelCount - 1) * (labelCount - 1 - index))
          ..add(0.0);

  @override
  Widget build(BuildContext context) {
    if (range == 0.0) {
      return const SizedBox();
    }

    return Container(
      height: height,
      padding: const EdgeInsets.only(left: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _rows(context),
      ),
    );
  }

  List<Widget> _rows(BuildContext context) {
    return _values
        .map(
          (e) => Row(
            children: [
              // TODO: This style should probably not be fixed
              Text(e.toStringAsFixed(2), style: context.textTheme.labelSmall?.copyWith(color: Colors.black38)),
              const SizedBox(width: 8),
              Expanded(child: CustomPaint(size: const Size(double.infinity, 2), painter: _DashedLinePainter())),
            ],
          ),
        )
        .toList();
  }
}

class _DashedLinePainter extends CustomPainter {
  static const _dashWidth = 6.0;
  static const _dashSpace = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black12
      ..strokeWidth = 1;

    var startX = 0.0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + _dashWidth, 0), paint);
      startX += _dashWidth + _dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
