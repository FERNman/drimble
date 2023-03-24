import 'package:flutter/material.dart';

import '../bac_format/bac_format.dart';
import '../build_context_extensions.dart';
import 'draw_dashed_line.dart';

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
    final bacFormatter = BacFormat();

    return _values.map(
      (e) {
        return Row(
          children: [
            Text(
              bacFormatter.format(e, withSymbol: false),
              style: context.textTheme.labelSmall?.copyWith(color: Colors.black38),
            ),
            const SizedBox(width: 8),
            Expanded(child: CustomPaint(size: const Size(double.infinity, 2), painter: _DashedLinePainter())),
          ],
        );
      },
    ).toList();
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black12
      ..strokeWidth = 1;

    canvas.drawDashedLine(const Offset(0, 0), Offset(size.width, 0), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
