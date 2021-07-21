import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  return runApp(_ChartApp());
}

class _Data {
  final String id;
  final String rawData;
  final double temperature;
  final double humid;
  final DateTime timestamp;
  final double barometer;
  final double visible_light;
  final double ir_light;
  final String node;
  final int flag;

  _Data(
      {@required this.id,
      @required this.rawData,
      @required this.temperature,
      @required this.humid,
      @required this.timestamp,
      @required this.barometer,
      @required this.visible_light,
      @required this.ir_light,
      @required this.node,
      @required this.flag});

  factory _Data.fromJson(Map<String, dynamic> json) {
    return _Data(
        id: json['_id'].toString(),
        rawData: json['rawData'].toString(),
        temperature: double.parse(json['temperature'].toStringAsFixed(2)),
        humid: double.parse(json['humid'].toStringAsFixed(2)),
        timestamp: new DateFormat("yyyy-MM-dd HH:mm:ss")
            .parse(json['timestamp'].toString()),
        barometer: double.parse(json['barometer'].toStringAsFixed(2)),
        visible_light: double.parse(json['visible_light'].toStringAsFixed(2)),
        ir_light: double.parse(json['ir_light'].toStringAsFixed(2)),
        node: json['node'].toString(),
        flag: int.parse(json['flag'].toString()));
  }
}

class _ChartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: _MyHomePage(),
    );
  }
}

class _MyHomePage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  _MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<_MyHomePage> {
  bool isFirstTime = true;
  List<_Data> lastestData;
  var last;
  Timer timer;
  ChartSeriesController _chartSeriesController1;
  ChartSeriesController _chartSeriesController2;
  ChartSeriesController _chartSeriesController3;
  ChartSeriesController _chartSeriesController4;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
        Duration(milliseconds: 500), (Timer timer) => _updateData());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<dynamic> _getData() async {
    final response = await http.get(Uri.parse(
        'http://engineer.narit.or.th/ajax/weather_module/api_test.php'));
    var map = json.decode(response.body);
    return map;
  }

  _updateData() async {
    if (last != null) {
      try {
        final response = await http.get(Uri.parse(
            'http://engineer.narit.or.th/ajax/weather_module/api_test.php?id=' +
                last));
        var map = json.decode(response.body);

        List<_Data> temp =
            (map as List).map((item) => _Data.fromJson(item)).toList();

        last = temp.last.id;

        int beforeCount = lastestData.length - 1;

        temp.forEach((element) {
          if (element.timestamp != null) {
            lastestData.add(element);
          }
        });

        int afterCount = lastestData.length - 1;

        int countRemove = afterCount - beforeCount - 1;

        lastestData.removeRange(0, countRemove);

        _chartSeriesController1?.updateDataSource(
            addedDataIndexes: <int>[beforeCount],
            removedDataIndexes: <int>[countRemove]);
        _chartSeriesController2?.updateDataSource(
            addedDataIndexes: <int>[beforeCount],
            removedDataIndexes: <int>[countRemove]);
        _chartSeriesController3?.updateDataSource(
            addedDataIndexes: <int>[beforeCount],
            removedDataIndexes: <int>[countRemove]);
        _chartSeriesController4?.updateDataSource(
            addedDataIndexes: <int>[beforeCount],
            removedDataIndexes: <int>[countRemove]);
      } catch (e) {}
    }
  }

  List<_Data> _get(data) {
    List<_Data> listData =
        (data as List).map((item) => _Data.fromJson(item)).toList();
    return listData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Syncfusion Flutter chart'),
        ),
        body: SingleChildScrollView(
            child: Column(children: [
          FutureBuilder(
              future: _getData(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (isFirstTime) {
                    lastestData = _get(snapshot.data);
                    last = lastestData.last.id;
                    isFirstTime = false;
                  }
                  return Column(
                    children: [
                      Text("Temperature"),
                      SfCartesianChart(
                          primaryXAxis: DateTimeAxis(
                              labelRotation: 90,
                              intervalType: DateTimeIntervalType.seconds,
                              edgeLabelPlacement: EdgeLabelPlacement.shift,
                              dateFormat: DateFormat.Hms()),
                          // Chart title
                          // Enable legend
                          primaryYAxis: NumericAxis(
                            isVisible: true,
                            numberFormat: NumberFormat("##.##", "en_US"),
                            maximumLabelWidth: 25,
                            decimalPlaces: 0,
                            minimum: 0,
                            maximum: 100,
                            interval: 10,
                          ),
                          legend: Legend(isVisible: false),
                          // Enable tooltip
                          tooltipBehavior: TooltipBehavior(enable: false),
                          series: <ChartSeries<_Data, DateTime>>[
                            LineSeries<_Data, DateTime>(
                                onRendererCreated:
                                    (ChartSeriesController controller) {
                                  // Assigning the controller to the _chartSeriesController.
                                  _chartSeriesController1 = controller;
                                },
                                dataSource: lastestData,
                                xValueMapper: (_Data test, _) => test.timestamp,
                                yValueMapper: (_Data test, _) =>
                                    test.temperature,
                                name: 'Temperature',
                                // Enable data label
                                dataLabelSettings:
                                    DataLabelSettings(isVisible: true)),
                          ]),
                      Text("Humidity"),
                      SfCartesianChart(
                          primaryXAxis: DateTimeAxis(
                            labelRotation: 90,
                            intervalType: DateTimeIntervalType.seconds,
                            dateFormat: DateFormat.Hms(),
                          ),
                          // Chart title
                          // Enable legend
                          primaryYAxis: NumericAxis(
                            isVisible: true,
                            numberFormat: NumberFormat("###.##", "en_US"),
                            maximumLabelWidth: 25,
                            decimalPlaces: 0,
                            minimum: 0,
                            maximum: 100,
                            interval: 10,
                          ),
                          legend: Legend(isVisible: false),
                          // Enable tooltip
                          tooltipBehavior: TooltipBehavior(enable: true),
                          series: <ChartSeries<_Data, DateTime>>[
                            LineSeries<_Data, DateTime>(
                                onRendererCreated:
                                    (ChartSeriesController controller) {
                                  // Assigning the controller to the _chartSeriesController.
                                  _chartSeriesController2 = controller;
                                },
                                dataSource: lastestData,
                                xValueMapper: (_Data test, _) => test.timestamp,
                                yValueMapper: (_Data test, _) => test.humid,
                                name: 'Humidity',
                                // Enable data label
                                dataLabelSettings:
                                    DataLabelSettings(isVisible: true)),
                          ]),
                      Text("Barometer"),
                      SfCartesianChart(
                          primaryXAxis: DateTimeAxis(
                              labelRotation: 90,
                              intervalType: DateTimeIntervalType.seconds,
                              dateFormat: DateFormat.Hms()),
                          // Chart title
                          // Enable legend
                          primaryYAxis: NumericAxis(
                            isVisible: true,
                            numberFormat: NumberFormat("##.###", "en_US"),
                            maximumLabelWidth: 25,
                            //minimum: 0,
                            //maximum: 100,
                            //interval: 10,
                          ),
                          legend: Legend(isVisible: false),
                          // Enable tooltip
                          tooltipBehavior: TooltipBehavior(enable: true),
                          series: <ChartSeries<_Data, DateTime>>[
                            LineSeries<_Data, DateTime>(
                                onRendererCreated:
                                    (ChartSeriesController controller) {
                                  // Assigning the controller to the _chartSeriesController.
                                  _chartSeriesController3 = controller;
                                },
                                dataSource: lastestData,
                                xValueMapper: (_Data test, _) => test.timestamp,
                                yValueMapper: (_Data test, _) => test.barometer,
                                name: 'Barometer',
                                // Enable data label
                                dataLabelSettings:
                                    DataLabelSettings(isVisible: true)),
                          ]),
                      Text("Visible Light"),
                      SfCartesianChart(
                          primaryXAxis: DateTimeAxis(
                              labelRotation: 90,
                              intervalType: DateTimeIntervalType.seconds,
                              dateFormat: DateFormat.Hms()),
                          // Chart title
                          // Enable legend
                          primaryYAxis: NumericAxis(
                              isVisible: true,
                              numberFormat: NumberFormat("###.##", "en_US"),
                              maximumLabelWidth: 25),
                          legend: Legend(isVisible: false),
                          // Enable tooltip
                          tooltipBehavior: TooltipBehavior(enable: true),
                          series: <ChartSeries<_Data, DateTime>>[
                            LineSeries<_Data, DateTime>(
                                onRendererCreated:
                                    (ChartSeriesController controller) {
                                  // Assigning the controller to the _chartSeriesController.
                                  _chartSeriesController4 = controller;
                                },
                                dataSource: lastestData,
                                xValueMapper: (_Data test, _) => test.timestamp,
                                yValueMapper: (_Data test, _) =>
                                    test.visible_light,
                                name: 'Visible Light',
                                // Enable data label
                                dataLabelSettings:
                                    DataLabelSettings(isVisible: false)),
                          ]),
                    ],
                  );
                }
                return CircularProgressIndicator();
              }),
        ])));
  }
}
