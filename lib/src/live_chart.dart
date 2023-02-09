import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'chart_display.dart';
import 'point.dart';

class RealTimeGraph extends StatefulWidget {
  const RealTimeGraph({
    Key? key,
    this.updateDelay = const Duration(milliseconds: 100),
    this.speed = 1,
    required this.stream,
    this.pointsSpacing = 3.0,
    this.displayMode = ChartDisplay.line,
  }) : super(key: key);

  final Stream<double> stream;
  final Duration updateDelay;
  final int speed;
  final double pointsSpacing;
  final ChartDisplay displayMode;

  @override
  RealTimeGraphState createState() => RealTimeGraphState();
}

class RealTimeGraphState extends State<RealTimeGraph>
    with TickerProviderStateMixin {
  StreamSubscription<double>? streamSubscription;

  List<Point<double>> _data = [];
  Timer? timer;

  @override
  void initState() {
    super.initState();

    // Subscribe to the stream provided in the constructor
    streamSubscription = widget.stream.listen(_streamListener);

    // Start a periodic timer to update the data for visualization
    timer = Timer.periodic(widget.updateDelay, (_) {
      //_data.removeWhere((element) => element.y > 100);

      // Clone the data to avoid modifying the original list while iterating
      List<Point<double>> data = _data.map((e) => e).toList();

      // Increment the x value of each data point
      for (var element in data) {
        element.x = element.x - widget.speed;
      }

      // Trigger a rebuild with the updated data
      setState(() {
        _data = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.maxWidth.isFinite || !constraints.maxHeight.isFinite) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          key: Key('${constraints.maxWidth}${constraints.maxHeight}'),
          height: constraints.maxWidth,
          width: constraints.maxHeight,
          child: CustomPaint(
            painter: widget.displayMode == ChartDisplay.points
                ? _PointsGraphPainter(
                    data: _data,
                    pointsSpacing: widget.pointsSpacing,
                  )
                : _LineGraphPainter(
                    data: _data,
                  ),
          ),
        );
      },
    );
  }

  void _streamListener(double data) {
    // Insert the new data point in the beginning of the list
    _data.insert(0, Point(0, data));
  }

  @override
  void dispose() {
    // Clean up resources when the widget is removed from the tree
    streamSubscription?.cancel();
    timer?.cancel();
    super.dispose();
  }
}

class _PointsGraphPainter extends CustomPainter {
  final List<Point<double>> data;

  _PointsGraphPainter({
    required this.data,
    required this.pointsSpacing,
  });

  final double pointsSpacing;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white;

    // Iterate over the data points and add intermediate points if necessary
    for (int i = 0; i < data.length - 1; i++) {
      final y1 = size.height - data[i].y;
      final x1 = data[i].x + size.width;
      final y2 = size.height - data[i + 1].y;
      final x2 = data[i + 1].x + size.width;
      final yDiff = (y2 - y1).abs();

      // If the difference in y values is small, add intermediate points
      if (yDiff >= pointsSpacing) {
        int numOfIntermediatePoints = (yDiff / pointsSpacing).round();
        final yInterval = (y2 - y1) / numOfIntermediatePoints;
        final xInterval = (x2 - x1) / numOfIntermediatePoints;
        for (int j = 0; j <= numOfIntermediatePoints; j++) {
          final intermediateY = y1 + yInterval * j;
          final intermediateX = x1 + xInterval * j;
          canvas.drawPoints(
            PointMode.points,
            [Offset(intermediateX, intermediateY)],
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class _LineGraphPainter extends CustomPainter {
  final List<Point<double>> data;

  _LineGraphPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white;
    Path path = Path();

    // Iterate over the data points and add intermediate points if necessary
    if (data.isNotEmpty) {
      path.moveTo(data.first.x + size.width, size.height - data.first.y);
    }
    for (int i = 0; i < data.length - 1; i++) {
      double y = size.height - data[i].y;
      double x = data[i].x + size.width;
      path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
