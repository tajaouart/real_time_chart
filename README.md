# Real-time Chart

A Flutter package for displaying real-time charts with flexible customization options.


<img src="https://raw.githubusercontent.com/tajaouart/real_time_chart/main/real_time_chart_demo.gif" height="600"/>



## Features
- Display real-time data on a graph
- Supports negative values
- Adapts height automatically based on the maximum value
- Customizable colors, axis labels, and grid lines

## Getting started

To use this package, add `real_time_chart` as a dependency in your pubspec.yaml file.

```yaml
dependencies:
  real_time_chart: ^0.0.1
```

## Usage

To display a real-time chart, you can use the `RealTimeChart` widget. Here's an example of how to use it in your code:

```dart
import 'package:real_time_chart/real_time_chart.dart';

class RealTimeChartExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RealTimeChart(
      stream: positiveDataStream(),
      graphColor = Colors.red,
    );
  }
}

Stream<double> positiveDataStream() {
  return Stream.periodic(const Duration(milliseconds: 500), (_) {
    return Random().nextInt(300).toDouble();
  }).asBroadcastStream();
}

```


## Additional information

This package provides a simple solution for displaying real-time data in a graph format. It offers support for both positive and negative values and automatically adapts the height of the graph to fit the maximum value.

If you encounter any issues or bugs while using the package, feel free to file an issue in the [issue tracker](https://github.com/tajaouart/real_time_chart/issues). We are committed to providing quick and helpful responses to any questions or concerns that you may have.

If you would like to contribute to the development of this package, we welcome pull requests and any other forms of contribution. Your help and support are greatly appreciated!



