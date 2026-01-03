import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'dart:math' as math show sin, pi;
import 'package:flutter/animation.dart';

class DelayTween extends Tween<double> {
  DelayTween({
    double? begin,
    double? end,
    required this.delay,
  }) : super(begin: begin, end: end);

  final double delay;

  @override
  double lerp(double t) {
    return super.lerp((math.sin((t - delay) * 2 * math.pi) + 1) / 2);
  }

  @override
  double evaluate(Animation<double> animation) => lerp(animation.value);
}

class SpinKitThreeBounce extends StatefulWidget {
  const SpinKitThreeBounce({
    Key? key,
    this.color,
    this.size = 50.0,
    this.itemBuilder,
    this.duration = const Duration(milliseconds: 1400),
    this.controller,
  })  : assert(
  !(itemBuilder is IndexedWidgetBuilder && color is Color) && !(itemBuilder == null && color == null),
  'You should specify either a itemBuilder or a color',
  ),
        super(key: key);

  final Color? color;
  final double size;
  final IndexedWidgetBuilder? itemBuilder;
  final Duration duration;
  final AnimationController? controller;

  @override
  State<SpinKitThreeBounce> createState() => _SpinKitThreeBounceState();
}

class _SpinKitThreeBounceState extends State<SpinKitThreeBounce> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = (widget.controller ?? AnimationController(vsync: this, duration: widget.duration))..repeat();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.fromSize(
        size: Size(widget.size * 2, widget.size),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (i) {
            return ScaleTransition(
              scale: DelayTween(
                begin: 0.0,
                end: 1.0,
                delay: i * .2,
              ).animate(_controller),
              child: SizedBox.fromSize(
                size: Size.square(widget.size * 0.5),
                child: _itemBuilder(i),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _itemBuilder(int index) => widget.itemBuilder != null
      ? widget.itemBuilder!(context, index)
      : DecoratedBox(
    decoration: BoxDecoration(
      color: widget.color,
      shape: BoxShape.circle,
    ),
  );
}

class SpinKitSpinningLines extends StatefulWidget {
  const SpinKitSpinningLines({
    Key? key,
    required this.color,
    this.size = 70,
    this.lineWidth = 2.0,
    this.itemCount = 5,
    this.duration = const Duration(milliseconds: 3000),
    this.controller,
  }) : super(key: key);

  final Color color;
  final double size;

  final double lineWidth;
  final int itemCount;

  final Duration duration;
  final AnimationController? controller;

  @override
  State<SpinKitSpinningLines> createState() => _SpinKitSpinningLinesState();
}

class _SpinKitSpinningLinesState extends State<SpinKitSpinningLines> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = (widget.controller ?? AnimationController(vsync: this, duration: widget.duration))
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      })
      ..repeat();

    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        builder: (BuildContext context, Widget? child) {
          return CustomPaint(
            painter: SpinningLinesPainter(
              _animation.value,
              lineWidth: widget.lineWidth,
              color: widget.color,
              itemCount: widget.itemCount,
            ),
            child: SizedBox.fromSize(size: Size.square(widget.size)),
          );
        },
        animation: _animation,
      ),
    );
  }
}

class SpinningLinesPainter extends CustomPainter {
  SpinningLinesPainter(
      this.rotateValue, {
        required Color color,
        required this.lineWidth,
        required this.itemCount,
      }) : _linePaint = Paint()
    ..color = color
    ..strokeWidth = 1
    ..style = PaintingStyle.fill;

  final double rotateValue;
  final double lineWidth;
  final int itemCount;

  final Paint _linePaint;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 1; i <= itemCount; i++) {
      _drawSpin(canvas, size, _linePaint, i);
    }
  }

  void _drawSpin(Canvas canvas, Size size, Paint paint, int scale) {
    final scaledSize = size * (scale / itemCount);
    final spinnerSize = Size.square(scaledSize.longestSide);

    final startX = spinnerSize.width / 2;
    final startY = spinnerSize.topCenter(Offset.zero).dy;

    final radius = spinnerSize.width / 4;

    final endX = startX;
    final endY = spinnerSize.bottomCenter(Offset.zero).dy;

    final borderWith = lineWidth;

    final scaleFactor = -(scale - (itemCount + 1));

    final path = Path();
    path.moveTo(startX, startY);
    path.arcToPoint(
      Offset(endX, endY),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    path.arcToPoint(
      Offset(startX, startY + borderWith),
      radius: Radius.circular(radius),
    );
    path.lineTo(startX, startY);

    canvas.save();
    _translateCanvas(canvas, size, spinnerSize);
    _rotateCanvas(
      canvas,
      spinnerSize,
      _getRadian(rotateValue * 360 * scaleFactor),
    );
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  void _translateCanvas(Canvas canvas, Size size, Size spinnerSize) {
    final offset = (size - spinnerSize as Offset) / 2;
    canvas.translate(offset.dx, offset.dy);
  }

  /// I use the following resource to calculate rotation of the canvas
  /// https://stackoverflow.com/a/54336099/9689717
  void _rotateCanvas(Canvas canvas, Size size, double angle) {
    final double r = sqrt(size.width * size.width + size.height * size.height) / 2;
    final alpha = atan(size.height / size.width);
    final beta = alpha + angle;
    final shiftY = r * sin(beta);
    final shiftX = r * cos(beta);
    final translateX = size.width / 2 - shiftX;
    final translateY = size.height / 2 - shiftY;
    canvas.translate(translateX, translateY);
    canvas.rotate(angle);
  }

  double _getRadian(double angle) => math.pi / 180 * angle;

  @override
  bool shouldRepaint(SpinningLinesPainter oldDelegate) {
    return oldDelegate.rotateValue != rotateValue ||
        oldDelegate.lineWidth != lineWidth ||
        oldDelegate.itemCount != itemCount ||
        oldDelegate._linePaint != _linePaint;
  }
}