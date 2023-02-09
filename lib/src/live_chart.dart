import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'point.dart';

class RealTimeGraph extends StatefulWidget {
  final Stream<double> stream;

  const RealTimeGraph({Key? key, required this.stream}) : super(key: key);

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
    streamSubscription = widget.stream.listen(_listener);

    // Start a periodic timer to update the data for visualization
    timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      //_data.removeWhere((element) => element.y > 100);

      // Clone the data to avoid modifying the original list while iterating
      List<Point<double>> data = _data.map((e) => e).toList();

      // Increment the x value of each data point
      for (var element in data) {
        element.x = element.x - 1;
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
            painter: _GraphPainter(data: _data),
          ),
        );
      },
    );
  }

  void _listener(double data) {
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

class _GraphPainter extends CustomPainter {
  final List<Point<double>> data;

  _GraphPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white;
    List<Offset> points = [];

    // Iterate over the data points and add intermediate points if necessary
    for (int i = 0; i < data.length - 1; i++) {
      double y1 = size.height - data[i].y;
      double x1 = data[i].x + size.width;
      double y2 = size.height - data[i + 1].y;
      double x2 = data[i + 1].x + size.width;
      double yDiff = y1 - y2;
      double xDiff = x1 - x2;

      // If the difference in y values is small, add intermediate points
      if (xDiff.abs() <= 10) {
        int numOfIntermediatePoints = (xDiff / 2).round();
        double yInterval = yDiff / numOfIntermediatePoints;
        double xInterval = xDiff / numOfIntermediatePoints;
        for (int j = 1; j <= numOfIntermediatePoints; j++) {
          double intermediateY = y1 + yInterval * j;
          double intermediateX = x1 + xInterval * j;
          points.add(Offset(intermediateX, intermediateY));
        }
      }
    }

    canvas.drawPoints(PointMode.points, points, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
