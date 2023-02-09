import 'dart:async';
import 'dart:math';

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
                ? _PointGraphPainter(
                    data: _data,
                    pointSpacing: 3,
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

class _PointGraphPainter extends CustomPainter {
  final List<Point<double>> data;
  final double pointSpacing;

  _PointGraphPainter({required this.data, required this.pointSpacing});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.5
      ..color = Colors.white;

    // Find the maximum y value in the data
    double maxY = 0;

    // Calculate the scaling factor for the y values
    double yScale = 1;

    // Iterate over the data points and add intermediate points if necessary
    if (data.isNotEmpty) {
      maxY = data.map((point) => point.y).reduce(max);
      yScale = (maxY > size.height) ? (size.height / maxY) : 1;
    }

    for (int i = 0; i < data.length - 1; i++) {
      double y1 = data[i].y * yScale;
      double x1 = data[i].x + size.width;
      double y2 = data[i + 1].y * yScale;
      double x2 = data[i + 1].x + size.width;
      double yDiff = (y2 - y1).abs();

      // If the difference in y values is small, add intermediate points
      if (yDiff >= pointSpacing) {
        int numOfIntermediatePoints = (yDiff / pointSpacing).round();
        double yInterval = (y2 - y1) / numOfIntermediatePoints;
        double xInterval = (x2 - x1) / numOfIntermediatePoints;
        for (int j = 0; j <= numOfIntermediatePoints; j++) {
          double intermediateY = y1 + yInterval * j;
          double intermediateX = x1 + xInterval * j;
          canvas.drawCircle(
            Offset(intermediateX, size.height - intermediateY),
            1,
            paint,
          );
        }
      }
      canvas.drawCircle(
        Offset(x1, size.height - y1),
        1,
        paint,
      );
    }
    canvas.drawCircle(
      Offset(data.last.x + size.width, size.height - data.last.y * yScale),
      1,
      paint,
    );
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
    // Find the maximum y value in the data
    double maxY = 0;

    // Calculate the scaling factor for the y values
    double yScale = 1;

    // Iterate over the data points and add intermediate points if necessary
    if (data.isNotEmpty) {
      maxY = data.map((point) => point.y).reduce(max);
      yScale = (maxY > size.height) ? (size.height / maxY) : 1;
      path.moveTo(
        data.first.x + size.width,
        (size.height - data.first.y * yScale),
      );
    }
    for (int i = 0; i < data.length - 1; i++) {
      double y = data[i + 1].y * yScale;
      double x = data[i + 1].x + size.width;

      path.lineTo(x, size.height - y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
