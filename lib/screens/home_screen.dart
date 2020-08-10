import 'package:data_visualization_app/models/activity_goal.dart';
import 'package:data_visualization_app/models/recorded_activity.dart';
import 'package:data_visualization_app/screens/activity_list_screen.dart';
import 'package:data_visualization_app/screens/add_data_screen.dart';
import 'package:data_visualization_app/screens/goals_screen.dart';
import 'package:data_visualization_app/services/database_manager.dart';
import 'package:data_visualization_app/services/sorting_data.dart';
import 'package:data_visualization_app/theme.dart';
import 'package:data_visualization_app/widgets/border_container.dart';
import 'package:data_visualization_app/widgets/goal.dart';
import 'package:data_visualization_app/widgets/overview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class HomeScreen extends StatefulWidget {
  static const routeName = '/';
  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: ThemeColors.darkBlue,
        child: Center(
          child: FutureBuilder<List<RecordedActivity>>(
              future: getActivityData(),
              builder:
                  (context, AsyncSnapshot<List<RecordedActivity>> snapshot) {
                if (snapshot.hasData) {
                  return ListView(
                    children: [
                      BorderContainerWidget(
                          _weeklyOverviewWidget(snapshot.data),
                          "Weekly Activity Overview"),
                      BorderContainerWidget(
                        _monthlyOverviewWidget(snapshot.data),
                        "Monthly Activity Overview: " + _getCurrentMonthName(),
                      ),
                      BorderContainerWidget(
                        _build12WeeksActivityTimeChart(snapshot.data),
                        "Activity Time last 12 weeks",
                      ),
                      BorderContainerWidget(
                        _build12WeeksCyclingDistanceChart(snapshot.data),
                        "Cycling Distance last 12 weeks",
                      ),
                      BorderContainerWidget(
                          _buildAverageSpeedProgression(snapshot.data, 1),
                          "Average Speed Progression in Cycling"),
                      BorderContainerWidget(
                        _build12WeeksRunningDistanceChart(snapshot.data),
                        "Running Distance last 12 weeks",
                      ),
                      BorderContainerWidget(
                          _buildAverageSpeedProgression(snapshot.data, 0),
                          "Average Speed Progression in Running"),
                      BorderContainerWidget(
                        _yearlyOverviewWidget(snapshot.data),
                        "Yearly Activity Overview",
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 64),
                      ),
                    ],
                  );
                } else {
                  return Center(
                    child: Text(
                      "You have not yet entered any data to be displayed. \nStart by using the button down here in the right corner.",
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
              }),
        ),
      ),
      floatingActionButton: _getFAB(),
    );
  }

  Widget _getFAB() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22, color: Colors.white),
      backgroundColor: ThemeColors.orange,
      visible: true,
      curve: Curves.bounceIn,
      children: [
        // FAB 1
        SpeedDialChild(
          child: Icon(
            Icons.list,
            color: Colors.white,
          ),
          backgroundColor: ThemeColors.orange,
          onTap: () {
            Navigator.pushNamed(context, ActivityListScreen.routeName).then((value) {
              setState(() {

              });
            });
          },
        ),
        // FAB 2
        SpeedDialChild(
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          backgroundColor: ThemeColors.orange,
          onTap: () {
            Navigator.pushNamed(context, AddDataScreen.routeName).then((value) {
              setState(() {

              });
            });
          },
        ),
        // FAB 3
        SpeedDialChild(
          child: Icon(
            Icons.flag,
            color: Colors.white,
          ),
          backgroundColor: ThemeColors.orange,
          onTap: () {
            Navigator.pushNamed(context, GoalsScreen.routeName).then((value) {
              setState(() {

              });
            });
          },
        ),
      ],
    );
  }

  /// Method to get the data from the database
  Future<List<RecordedActivity>> getActivityData() async {
    DatabaseManager dbManager = new DatabaseManager();
    List<RecordedActivity> activities = await dbManager.getActivities();

    return activities;
  }

  /// Method to fill the rows of the table
  List<DataRow> getTableRows(List<RecordedActivity> activities) {
    List<DataRow> tableRows = new List<DataRow>();

    for (RecordedActivity recAct in activities) {
      tableRows.add(DataRow(
        cells: [
          DataCell(Text(
            recAct.activityType,
            style: GoogleFonts.montserrat(color: Colors.white),
          )),
          DataCell(Text(
            recAct.duration,
            style: GoogleFonts.montserrat(color: Colors.white),
          )),
          DataCell(Text(
            recAct.distance.toString(),
            style: GoogleFonts.montserrat(color: Colors.white),
          )),
        ],
      ));
    }

    return tableRows;
  }

  /// Method to build the BarChart containing the data for the distance of the given [activities]
  Widget _buildYearlyDistanceChart(List<RecordedActivity> activities) {
    return SizedBox(
      height: 100.0,
      child: new charts.BarChart(
        SortingDataService().getYearlyActivitiesDistance(activities),
        animate: false,
        vertical: false,
        domainAxis: charts.AxisSpec<String>(
          renderSpec: charts.GridlineRendererSpec(
            labelStyle: new charts.TextStyleSpec(
              fontSize: 10,
              color: charts.MaterialPalette.white,
            ),
          ),
        ),
        primaryMeasureAxis: charts.NumericAxisSpec(
          renderSpec: charts.GridlineRendererSpec(
            labelStyle: charts.TextStyleSpec(
                fontSize: 10, color: charts.MaterialPalette.white),
            lineStyle: charts.LineStyleSpec(
                thickness: 1, color: charts.MaterialPalette.white),
          ),
        ),
      ),
    );
  }

  /// Method to build the BarChart containing the data for the duration of the given [activities]
  Widget _buildYearlyDurationChart(List<RecordedActivity> activities) {
    return Column(
      children: [
        SizedBox(
          height: 200.0,
          child: new charts.PieChart(
            SortingDataService().getYearlyActivitiesTime(activities),
            animate: false,
            defaultRenderer: new charts.ArcRendererConfig(
                arcWidth: 45,
                arcRendererDecorators: [
                  new charts.ArcLabelDecorator(
                    labelPosition: charts.ArcLabelPosition.outside,
                    outsideLabelStyleSpec: charts.TextStyleSpec(
                        color: charts.Color.white, fontSize: 12),
                  )
                ]),
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(0, 8, 0, 0),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
              Icons.directions_run,
              color: ThemeColors.lightBlue,
            ),
            Icon(
              Icons.directions_bike,
              color: ThemeColors.orange,
            ),
            Icon(
              Icons.filter_hdr,
              color: ThemeColors.yellowGreenish,
            ),
          ],
        ),
      ],
    );
  }

  TableRow _buildTableRow(String listOfNames) {
    return TableRow(
      children: listOfNames.split(',').map((name) {
        return Container(
          alignment: Alignment.center,
          child: Text(name, style: GoogleFonts.montserrat(color: Colors.white)),
          padding: EdgeInsets.all(8.0),
        );
      }).toList(),
    );
  }

  /// Method to assemble the weekly overview
  Widget _weeklyOverviewWidget(List<RecordedActivity> activities) {
    return Column(children: <Widget>[
      OverviewWidget(activities, 0),
      Container(padding: EdgeInsets.fromLTRB(0, 8, 0, 0), child: Divider()),
      Container(
        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
        child: Text(
          "Activity Time in h",
          style: GoogleFonts.montserrat(color: Colors.white),
        ),
      ),
      Container(
        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
        child: _buildWeeklyActivityChart(activities),
      ),
      Container(
        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
        child: _buildGoalList(0),
      ),
    ]);
  }

  Widget _monthlyOverviewWidget(List<RecordedActivity> activities) {
    return Column(children: <Widget>[
        OverviewWidget(activities, 1),
      Container(
        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
        child: _buildGoalList(1),
      ),
    ]);
  }

  /// Method to assemble the yearly overview
  Widget _yearlyOverviewWidget(List<RecordedActivity> activities) {
    return Column(
      children: [
        OverviewWidget(activities, 2),
        Container(
          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
          child: Divider(
            thickness: 1,
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
          child: Text(
            "Total Activity Time " +
                DateTime.now().year.toString(),
            style:
            GoogleFonts.montserrat(color: Colors.white),
          ),
        ),
        _buildYearlyDurationChart(activities),
        Container(
          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
          child: Divider(
            thickness: 1,
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
          child: Text(
            "Total Activity Distance " +
                DateTime.now().year.toString(),
            style:
            GoogleFonts.montserrat(color: Colors.white),
          ),
        ),
        _buildYearlyDistanceChart(activities),
        Container(
          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
          child: _buildGoalList(2),
        ),
      ],
    );
  }

  /// Method to return a list view containing the goals for the specified time span
  /// where 0: week, 1: month, 2: year
  Widget _buildGoalList(int timeSpan){
    return FutureBuilder<List<ActivityGoal>>(
        future: getGoalData(timeSpan),
        builder: (context, AsyncSnapshot<List<ActivityGoal>> snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: <Widget>[
                Divider(),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                  child: Text(
                    "Personal Goals",
                    style: GoogleFonts.montserrat(color: Colors.white),
                  ),
                ),
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder<double>(
                          future:
                          SortingDataService().getCurrentGoalProgress(snapshot.data[index]),
                          builder: (context,
                              AsyncSnapshot<double> goalProgress) {
                            if (goalProgress.hasData) {
                              return GoalWidget(
                                  snapshot.data[index].goalNumber
                                      .toDouble(),
                                  goalProgress.data,
                                  snapshot.data[index].goalTitle,
                                  snapshot.data[index].goalType,
                                  snapshot.data[index].activityType);
                            } else {
                              return Container();
                            }
                          });
                    }),
              ],
            );
          } else {
            return Container();
          }
        });
  }

  _build12WeeksActivityTimeChart(List<RecordedActivity> activities) {
    List<charts.Series<ActivitiesDataDateTime, DateTime>> data =
        SortingDataService().getActivityTimePast12Weeks(activities);

    return _buildLineGraphWithAreaAndPoints(data, 200);
  }

  _build12WeeksCyclingDistanceChart(List<RecordedActivity> activities) {
    List<charts.Series<ActivitiesDataDateTime, DateTime>> data =
        SortingDataService().getActivityDistancePast12Weeks(activities);

    data.removeAt(0);

    return _buildLineGraphWithAreaAndPoints(data, 200);
  }

  _build12WeeksRunningDistanceChart(List<RecordedActivity> activities) {
    List<charts.Series<ActivitiesDataDateTime, DateTime>> data =
        SortingDataService().getActivityDistancePast12Weeks(activities);

    data.removeAt(1);

    return _buildLineGraphWithAreaAndPoints(data, 200);
  }

  Widget _buildWeeklyActivityChart(List<RecordedActivity> activities) {
    List<charts.Series<ActivitiesDataDateTime, DateTime>> data =
        SortingDataService().getWeeklyActivity(activities);

    return _buildLineGraphWithAreaAndPoints(data, 140);
  }

  _buildLineGraphWithAreaAndPoints(
      List<charts.Series<ActivitiesDataDateTime, DateTime>> data,
      double height) {
    if (data.isNotEmpty) {
      return SizedBox(
        height: height,
        child: new charts.TimeSeriesChart(
          data,
          animate: false,
          defaultRenderer: new charts.LineRendererConfig(
            includePoints: true,
            includeArea: true,
          ),
          domainAxis: new charts.DateTimeAxisSpec(
              renderSpec: charts.GridlineRendererSpec(
                  axisLineStyle: charts.LineStyleSpec(
                    color: charts.MaterialPalette
                        .white, // this also doesn't change the Y axis labels
                  ),
                  labelStyle: new charts.TextStyleSpec(
                    fontSize: 10,
                    color: charts.MaterialPalette.white,
                  ),
                  lineStyle: charts.LineStyleSpec(
                    thickness: 0,
                    color: charts.MaterialPalette.white,
                  )),
              tickFormatterSpec: new charts.AutoDateTimeTickFormatterSpec(
                  hour: new charts.TimeFormatterSpec(
                format: 'H',
                transitionFormat: 'H',
              ))),
          primaryMeasureAxis: charts.NumericAxisSpec(
              renderSpec: charts.GridlineRendererSpec(
                  labelStyle: charts.TextStyleSpec(
                      fontSize: 10, color: charts.MaterialPalette.white),
                  lineStyle: charts.LineStyleSpec(
                      thickness: 1, color: charts.MaterialPalette.white))),
          behaviors: [
            new charts.SeriesLegend(
              // Positions for "start" and "end" will be left and right respectively
              // for widgets with a build context that has directionality ltr.
              // For rtl, "start" and "end" will be right and left respectively.
              // Since this example has directionality of ltr, the legend is
              // positioned on the right side of the chart.
              position: charts.BehaviorPosition.bottom,
              // For a legend that is positioned on the left or right of the chart,
              // setting the justification for [endDrawArea] is aligned to the
              // bottom of the chart draw area.
              outsideJustification: charts.OutsideJustification.middleDrawArea,
              // By default, if the position of the chart is on the left or right of
              // the chart, [horizontalFirst] is set to false. This means that the
              // legend entries will grow as new rows first instead of a new column.
              horizontalFirst: true,
              // By setting this value to 2, the legend entries will grow up to two
              // rows before adding a new column.
              desiredMaxRows: 2,
              // This defines the padding around each legend entry.
              cellPadding: new EdgeInsets.only(right: 4.0, bottom: 4.0),
              // Render the legend entry text with custom styles.
              entryTextStyle: charts.TextStyleSpec(
                color: charts.Color.white,
                fontFamily: 'Montserrat',
                fontSize: 10,
              ),
            )
          ],
        ),
      );
    } else {
      return Center(
        child: Text(
          "There seems to be no training data this week...\nTime to start training!",
          style: GoogleFonts.montserrat(color: Colors.white),
        ),
      );
    }
  }

  _buildAverageSpeedProgression(List<RecordedActivity> activities, int type) {
    var data = SortingDataService().getAverageSpeedData(activities, 8, type);

    if (data.isNotEmpty) {
      return SizedBox(
        height: 200.0,
        child: charts.BarChart(
          data,
          animate: false,
          domainAxis: charts.AxisSpec<String>(
            renderSpec: charts.GridlineRendererSpec(
              labelStyle: new charts.TextStyleSpec(
                fontSize: 10,
                color: charts.MaterialPalette.white,
              ),
            ),
          ),
          primaryMeasureAxis: charts.NumericAxisSpec(
            renderSpec: charts.GridlineRendererSpec(
              labelStyle: charts.TextStyleSpec(
                  fontSize: 10, color: charts.MaterialPalette.white),
              lineStyle: charts.LineStyleSpec(
                  thickness: 1, color: charts.MaterialPalette.white),
            ),
          ),
          customSeriesRenderers: [
            new charts.BarTargetLineRendererConfig<String>(
                // ID used to link series to this renderer.
                customRendererId: 'customTargetLine',
                groupingType: charts.BarGroupingType.stacked)
          ],
        ),
      );
    } else {
      return Container(
        child: Text(
          "No activities yet.",
          style: GoogleFonts.montserrat(color: Colors.white),
        ),
      );
    }
  }

  Future<List<ActivityGoal>> getGoalData(int timeFrame) async {
    DatabaseManager dbManager = new DatabaseManager();

    List<ActivityGoal> allGoals = await dbManager.getGoals();
    List<ActivityGoal> returnGoals = new List();

    for (ActivityGoal goal in allGoals) {
      if (goal.timeFrame == timeFrame) {
        returnGoals.add(goal);
      }
    }

    return returnGoals;
  }

  /// Method to return the name of the current month
  String _getCurrentMonthName() {
    switch (DateTime.now().month) {
      case DateTime.january:
        return "January";
      case DateTime.february:
        return "February";
      case DateTime.march:
        return "March";
      case DateTime.april:
        return "April";
      case DateTime.may:
        return "May";
      case DateTime.june:
        return "June";
      case DateTime.july:
        return "July";
      case DateTime.august:
        return "August";
      case DateTime.september:
        return "September";
      case DateTime.october:
        return "October";
      case DateTime.november:
        return "November";
      case DateTime.december:
        return "December";
      default:
        return "Current Month";
    }
  }
}
