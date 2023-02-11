// Copyright (c) 2023 Tajaouart Mounir
//
// This demo showcases the usage of the `RealTimeGraph` widget
// and provides an example of how to use it in a Flutter app.
// Website: https://tajaouart.com

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:real_time_chart/real_time_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Real-Time Chart Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Real-Time Chart Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final stream = positiveDataStream();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display a real-time graph of positive data
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width * 0.8,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: RealTimeGraph(
                    stream: stream,
                  ),
                ),
              ),

              // Display a real-time graph of positive data as points
              const SizedBox(height: 32),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width * 0.8,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: RealTimeGraph(
                    stream: stream,
                    displayMode: ChartDisplay.points,
                  ),
                ),
              ),

              // Display a real-time graph of positive and negative data
              const SizedBox(height: 32),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Supports negative values :',
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width * 0.8,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: RealTimeGraph(
                    stream: stream.map((value) => value - 150),
                    supportNegativeValuesDisplay: true,
                    xAxisColor: Colors.black12,
                  ),
                ),
              ),

              // Display a real-time graph of positive and negative data as points

              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width * 0.8,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: RealTimeGraph(
                    stream: stream.map((value) => value - 150),
                    supportNegativeValuesDisplay: true,
                    displayMode: ChartDisplay.points,
                    xAxisColor: Colors.black12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Stream<double> positiveDataStream() {
    return Stream.periodic(const Duration(milliseconds: 500), (_) {
      return Random().nextInt(300).toDouble();
    }).asBroadcastStream();
  }
}
