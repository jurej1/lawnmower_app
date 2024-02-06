import 'package:based_battery_indicator/based_battery_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lawnmower_app/bluetooth/view/bluetooth_view.dart';
import 'package:lawnmower_app/home/blocs/blocs.dart';
import 'package:lawnmower_app/home/widgets/widgets.dart';
import 'package:weather_repository/weather_repository.dart';

import '../../map/blocs/blocs.dart';
import '../../map/view/view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static Widget provider() {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => WeatherCubit(
            weatherRepository: RepositoryProvider.of<WeatherRepository>(context),
          )..getWeatherInfo(),
        ),
        BlocProvider(
          lazy: false,
          create: (context) => UserLocationCubit()..getCurrentLocation(),
        ),
      ],
      child: const HomeView(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        children: [
          const SizedBox(height: 60),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(BluetoothView.route());
                },
                child: const Text('BLE'),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 280,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
              color: Colors.green[200],
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                const BoxShadow(
                  blurRadius: 0.3,
                  offset: Offset(1, 1),
                  color: Colors.black26,
                ),
              ],
            ),
            child: const Column(
              children: [
                _HeaderRow(),
                SizedBox(height: 20),
                _ButtonRow(),
                SizedBox(height: 20),
                _ActionRow(),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SizedBox(
            height: 150,
            child: _Chart(),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(MapView.route(context));
            },
            child: const Text("Open Google Maps"),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BatteryDisplayer.provider(),
        const Spacer(),
        SizedBox(
          height: 30,
          child: TextButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Container(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Speed"),
                            _radioButton(
                              value: false,
                              onChanged: (val) {},
                              text: "Balance",
                            ),
                            _radioButton(
                              value: true,
                              onChanged: (val) {},
                              text: "Turbo",
                            ),
                            _radioButton(
                              value: false,
                              onChanged: (val) {},
                              text: "Silent",
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Edging"),
                            _radioButton(
                              value: false,
                              onChanged: (val) {},
                              text: "Balance",
                            ),
                            _radioButton(
                              value: true,
                              onChanged: (val) {},
                              text: "Turbo",
                            ),
                            _radioButton(
                              value: false,
                              onChanged: (val) {},
                              text: "Silent",
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            style: TextButton.styleFrom(
              shape: const RoundedRectangleBorder(),
            ),
            child: const Text(
              "Settings",
              style: TextStyle(
                color: Colors.black,
                fontSize: 10,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _radioButton({
    required bool value,
    required Function(bool?) onChanged,
    required String text,
  }) {
    return Row(
      children: [
        Radio(
          key: ValueKey(text),
          value: value,
          groupValue: true,
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Text(
          text,
        )
      ],
    );
  }
}

class _ButtonRow extends StatelessWidget {
  const _ButtonRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 130,
          width: 130,
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/rasen_roboter_catia.jpg')),
            shape: BoxShape.circle,
          ),
        ),
        const Spacer(),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(height: 30),
            ElevatedButton(
              onPressed: () {
                //TODO
              },
              style: ElevatedButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Text(
                "Start mowing",
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(
              height: 30,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: const RoundedRectangleBorder(),
                ),
                child: const Text(
                  "Set in auto mode",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today, ${DateFormat("d MMMM").format(DateTime.now())}",
            ),
            Text(
              DateFormat("HH:MM").format(DateTime.now()),
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
        BlocBuilder<WeatherCubit, WeatherState>(
          builder: (context, state) {
            if (state is WeatherSuccess) {
              return Column(
                children: [
                  Row(
                    children: [
                      Image.asset(
                        state.weatherLocation.iconPath,
                        package: "weather_repository",
                        height: 50,
                      ),
                      Text(state.weatherLocation.conditionText),
                      const SizedBox(width: 10),
                    ],
                  ),
                  Text(
                    "Perfect condition,\nto mow your lawn!",
                    style: TextStyle(
                      color: Colors.black,
                      height: 0.9,
                      fontSize: 10,
                    ),
                  ),
                ],
              );
            }
            return Container();
          },
        )
      ],
    );
  }
}

class _Chart extends StatefulWidget {
  const _Chart({super.key});

  @override
  State<_Chart> createState() => _ChartState();
}

class _ChartState extends State<_Chart> {
  final double width = 7;

  late List<BarChartGroupData> rawBarGroups;
  late List<BarChartGroupData> showingBarGroups;

  int touchedGroupIndex = -1;

  @override
  void initState() {
    super.initState();
    final barGroup1 = makeGroupData(0, 5, 12);
    final barGroup2 = makeGroupData(1, 16, 12);
    final barGroup3 = makeGroupData(2, 18, 5);
    final barGroup4 = makeGroupData(3, 20, 16);
    final barGroup5 = makeGroupData(4, 17, 6);
    final barGroup6 = makeGroupData(5, 19, 1.5);
    final barGroup7 = makeGroupData(6, 10, 1.5);

    final items = [
      barGroup1,
      barGroup2,
      barGroup3,
      barGroup4,
      barGroup5,
      barGroup6,
      barGroup7,
    ];

    rawBarGroups = items;

    showingBarGroups = rawBarGroups;
  }

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        maxY: 20,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.grey,
            getTooltipItem: (a, b, c, d) => null,
          ),
          touchCallback: (FlTouchEvent event, response) {
            if (response == null || response.spot == null) {
              setState(() {
                touchedGroupIndex = -1;
                showingBarGroups = List.of(rawBarGroups);
              });
              return;
            }

            touchedGroupIndex = response.spot!.touchedBarGroupIndex;

            setState(() {
              if (!event.isInterestedForInteractions) {
                touchedGroupIndex = -1;
                showingBarGroups = List.of(rawBarGroups);
                return;
              }
              showingBarGroups = List.of(rawBarGroups);
              if (touchedGroupIndex != -1) {
                var sum = 0.0;
                for (final rod in showingBarGroups[touchedGroupIndex].barRods) {
                  sum += rod.toY;
                }
                final avg = sum / showingBarGroups[touchedGroupIndex].barRods.length;

                showingBarGroups[touchedGroupIndex] = showingBarGroups[touchedGroupIndex].copyWith(
                  barRods: showingBarGroups[touchedGroupIndex].barRods.map((rod) {
                    return rod.copyWith(toY: avg, color: Colors.amber);
                  }).toList(),
                );
              }
            });
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: bottomTitles,
              reservedSize: 42,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 1,
              getTitlesWidget: leftTitles,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: showingBarGroups,
        gridData: const FlGridData(show: false),
      ),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff7589a2),
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    String text;
    if (value == 0) {
      text = '0min';
    } else if (value == 10) {
      text = '15min';
    } else if (value == 19) {
      text = '30min';
    } else {
      return Container();
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0,
      child: Text(text, style: style),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    final titles = <String>['Mn', 'Te', 'Wd', 'Tu', 'Fr', 'St', 'Su'];

    final Widget text = Text(
      titles[value.toInt()],
      style: const TextStyle(
        color: Color(0xff7589a2),
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16, //margin top
      child: text,
    );
  }

  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: Colors.red,
          width: width,
        ),
        BarChartRodData(
          toY: y2,
          color: Colors.green,
          width: width,
        ),
      ],
    );
  }

  Widget makeTransactionsIcon() {
    const width = 4.5;
    const space = 3.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: width,
          height: 10,
          color: Colors.white.withOpacity(0.4),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 42,
          color: Colors.white.withOpacity(1),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 10,
          color: Colors.white.withOpacity(0.4),
        ),
      ],
    );
  }
}
