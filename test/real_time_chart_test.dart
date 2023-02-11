/*
 * Copyright (C) 2023 tajaouart.com
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Contact: developer@tajaouart.com
 */


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_time_chart/real_time_chart.dart';

void main() {
  testWidgets('Check Stream behaviour & initial values', (tester) async {
    final streamController = StreamController<double>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RealTimeGraph(
            key: const Key('RealTimeGraph'),
            stream: streamController.stream,
            supportNegativeValuesDisplay: true,
          ),
        ),
      ),
    );

    final state = tester.state<RealTimeGraphState>(find.byType(RealTimeGraph));

    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Verify that the `streamSubscription` is created and active
    expect(find.byType(RealTimeGraph), findsOneWidget);

    expect(state.streamSubscription, isNotNull);
    expect(state.streamSubscription!.isPaused, isFalse);

    // Verify that the timer is created and active
    expect(state.timer, isNotNull);
    expect(state.timer!.isActive, isTrue);

    // Verify that the data starts with an empty list
    expect(state.data, isEmpty);

    // Add data to the stream and verify that the graph updates
    streamController.add(10.0);
    await tester.pump();
    expect(state.data, isNotEmpty);
    expect(state.data[0].y, 10.0);

    // Verify that the `minValue` and `maxValue` functions return the correct values
    streamController.add(-5.0);
    await tester.pumpAndSettle();

    // min & max values are always symetrics
    expect(state.minValue, -10.0);
    expect(state.maxValue, 10.0);

    streamController.close();
  });

  testWidgets('displayYAxisValues > true', (WidgetTester tester) async {
    // Create a StreamController to simulate the stream data
    final streamController = StreamController<double>();

    // Build the widget tree
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RealTimeGraph(
            displayYAxisValues: true,
            axisTextBuilder: (double value) {
              return Text(
                '$value',
                style: const TextStyle(color: Colors.purple),
              );
            },
            stream: streamController.stream,
          ),
        ),
      ),
    );

    // Add data to the stream
    streamController.add(1.0);
    streamController.add(2.0);

    // Trigger a rebuild of the widget tree to reflect the changes
    await tester.pumpAndSettle();

    // Verify the y axis values after the stream update
    expect(find.text('0.0'), findsOneWidget);
    // median value.
    expect(find.text('1.0'), findsOneWidget);
    // max value
    expect(find.text('2.0'), findsOneWidget);

    // Verify that the text builder is used
    final text = tester.widget<Text>(find.text('0.0'));
    expect(text.style?.color, Colors.purple);
  });

  testWidgets('displayYAxisValues > false', (WidgetTester tester) async {
    // Create a StreamController to simulate the stream data
    final StreamController<double> streamController =
    StreamController<double>();

    // Build the widget tree
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RealTimeGraph(
            displayYAxisValues: false,
            axisTextBuilder: (double value) => Text('$value'),
            stream: streamController.stream,
          ),
        ),
      ),
    );

    // Add data to the stream
    streamController.add(1.0);
    streamController.add(2.0);

    // Trigger a rebuild of the widget tree to reflect the changes
    await tester.pumpAndSettle();

    // Verify the y axis values after the stream update
    expect(find.text('0.0'), findsNothing);
    // median value.
    expect(find.text('1.0'), findsNothing);
    // max value
    expect(find.text('2.0'), findsNothing);
  });

  testWidgets('Axis stroke and color', (WidgetTester tester) async {
    // Create a StreamController to simulate the stream data
    final streamController = StreamController<double>();

    // Build the widget tree
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RealTimeGraph(
            displayYAxisValues: true,
            xAxisColor: Colors.red,
            yAxisColor: Colors.green,
            axisStroke: 2.0,
            stream: streamController.stream,
          ),
        ),
      ),
    );

    // Test if the axis's colors
    expect(
      tester.widget<Container>(find.byKey(const Key('X-Axis')).first).color,
      Colors.red,
    );

    expect(
      tester.widget<Container>(find.byKey(const Key('Y-Axis')).first).color,
      Colors.green,
    );

    // Test if the axis stroke is 2.0
    final size1 = tester.getSize(find.byKey(const Key('X-Axis')));
    final size2 = tester.getSize(find.byKey(const Key('Y-Axis')));
    expect(size1.height, equals(2.0));
    expect(size2.width, equals(2.0));
  });

  testWidgets('Verify behaviour of displayMode property ', (tester) async {
    // Create a StreamController to simulate the stream data
    final streamController = StreamController<double>();

    // Build the widget tree
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RealTimeGraph(
            displayMode: ChartDisplay.line,
            stream: streamController.stream,
          ),
        ),
      ),
    );

    expect(find.byKey(Key(ChartDisplay.line.toString())), findsOneWidget);

    // Build the widget tree
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RealTimeGraph(
            displayMode: ChartDisplay.points,
            stream: streamController.stream,
          ),
        ),
      ),
    );

    expect(find.byKey(Key(ChartDisplay.points.toString())), findsOneWidget);
  });
}
