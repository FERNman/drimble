import 'package:flutter/material.dart';

import '../../common/build_context_extensions.dart';

class HangoverSeveritySlider extends StatefulWidget {
  final int value;
  final ValueChanged<int> onChanged;

  final int min;
  final int max;

  final List<Text> labels;

  final double height;

  const HangoverSeveritySlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 6,
    this.labels = const [],
    this.height = 300,
  });

  @override
  HangoverSeveritySliderState createState() => HangoverSeveritySliderState();
}

class HangoverSeveritySliderState extends State<HangoverSeveritySlider> {
  static const double _width = 42;

  int _currentValue = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(HangoverSeveritySlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    _currentValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: _buildSlider(context),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: widget.labels,
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(BuildContext context) {
    return SizedBox(
      width: _width,
      height: widget.height,
      child: GestureDetector(
        onVerticalDragDown: (details) {
          setState(() {
            _isDragging = true;
          });
        },
        onVerticalDragUpdate: (details) {
          setState(() {
            _currentValue = (details.localPosition.dy / widget.height * widget.max).round();
            if (_currentValue < widget.min) {
              _currentValue = widget.min;
            } else if (_currentValue > widget.max) {
              _currentValue = widget.max;
            }
          });

          widget.onChanged(_currentValue);
        },
        onVerticalDragEnd: (details) {
          setState(() {
            _isDragging = false;
          });
        },
        child: CustomPaint(
          painter: _SliderPainter(
            value: _currentValue.toDouble() / widget.max,
            isDragging: _isDragging,
            color: context.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _SliderPainter extends CustomPainter {
  static const double _thumbRadius = 10.0;
  static const double _trackWidth = 6.0;

  final double value;
  final bool isDragging;

  final Color color;

  _SliderPainter({
    required this.value,
    required this.isDragging,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double height = size.height;
    final double width = size.width;

    final Paint backgroundPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final Paint selectedPain = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double thumbPosition = value * height;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(width / 2.0 - _trackWidth / 2.0, 0, _trackWidth, height),
        const Radius.circular(5),
      ),
      backgroundPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(width / 2.0 - _trackWidth / 2.0, 0, _trackWidth, thumbPosition),
        const Radius.circular(5),
      ),
      selectedPain,
    );

    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(isDragging ? 0.4 : 0.2)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, isDragging ? 7 : 5);

    canvas.drawCircle(
      Offset(width / 2, thumbPosition),
      _thumbRadius,
      shadowPaint,
    );

    canvas.drawCircle(
      Offset(width / 2, thumbPosition),
      _thumbRadius,
      selectedPain,
    );
  }

  @override
  bool shouldRepaint(_SliderPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.isDragging != isDragging;
  }
}
