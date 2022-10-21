import 'package:flutter/material.dart';

class ChartLabelData {
  final double offset;
  final Widget child;

  const ChartLabelData({required this.offset, required this.child});
}

class HorizontalLineChartLabels extends StatelessWidget {
  final List<ChartLabelData> items;

  const HorizontalLineChartLabels({required this.items, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Flow(
        delegate: _HorizontalLabelFlowDelegate(offsets: items.map((e) => e.offset).toList()),
        children: items.map((e) => e.child).toList(),
      ),
    );
  }
}

class _HorizontalLabelFlowDelegate extends FlowDelegate {
  final List<double> offsets;

  _HorizontalLabelFlowDelegate({required this.offsets});

  @override
  bool shouldRepaint(_HorizontalLabelFlowDelegate oldDelegate) => true;

  @override
  void paintChildren(FlowPaintingContext context) {
    final width = context.size.width;

    for (int i = context.childCount - 1; i >= 0; i--) {
      context.paintChild(i, transform: Matrix4.translationValues(offsets[i] * width, 0, 0));
    }
  }

  @override
  // TODO: Calculate height
  Size getSize(BoxConstraints constraints) => Size(constraints.maxWidth, 20);
}
