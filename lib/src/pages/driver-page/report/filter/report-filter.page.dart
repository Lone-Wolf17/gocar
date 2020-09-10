import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:gocar/src/infra/infra.dart';
import 'package:gocar/src/provider/blocs/blocs.dart';
import 'package:line_icons/line_icons.dart';

import '../../../pages.dart';

class ReportListPage extends StatefulWidget {
  @override
  _ReportListPageState createState() => _ReportListPageState();
}

class _ReportListPageState extends State<ReportListPage> {
  DriverReportBloc _reportBloc;
  String _startDate = "Start";
  String _endDate = "End";
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _reportBloc = DriverReportBloc();
    _reportBloc.totalReportFilterEvent.add(0);
    super.initState();
  }

  @override
  void dispose() {
    _reportBloc?.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        bottomNavigationBar: _buildFooter(context),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              LineIcons.arrow_left,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          automaticallyImplyLeading: true,
        ),
        body: Scaffold(
            body: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height +
                    (MediaQuery.of(context).size.height * 0.1),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: <Widget>[
                    new Center(
                        child: Container(
                          padding: EdgeInsets.only(top: 50.0),
                          child: Column(
                            children: <Widget>[
                              Card(
                                elevation: 30.0,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.85,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Container(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          RaisedButton(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(5.0)),
                                            elevation: 4.0,
                                            onPressed: () {
                                              DatePicker.showDatePicker(context,
                                                  theme: DatePickerTheme(
                                                    containerHeight: 210.0,
                                                  ),
                                                  showTitleActions: true,
                                                  minTime: DateTime(2018, 1, 1),
                                                  maxTime: DateTime(2022, 12, 31),
                                                  onConfirm: (date) {
                                        _startDate =
                                            '${date.day}-${date.month}-${date.year}';
                                        setState(() {});
                                      },
                                                  currentTime: DateTime.now(),
                                                  locale: LocaleType.pt);
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              height: 50.0,
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
                                                      Container(
                                                        child: Row(
                                                          children: <Widget>[
                                                            Icon(
                                                              Icons.date_range,
                                                              size: 18.0,
                                                              color: Colors.black,
                                                            ),
                                                            Text(
                                                              " $_startDate",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                  fontSize: 16.0),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Text(
                                                    "Change",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight
                                                            .bold,
                                                        fontSize: 18.0),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            color: Colors.white,
                                          ),
                                          SizedBox(
                                            height: 20.0,
                                          ),
                                          RaisedButton(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(5.0)),
                                            elevation: 4.0,
                                            onPressed: () {
                                              DatePicker.showDatePicker(context,
                                                  theme: DatePickerTheme(
                                                    containerHeight: 210.0,
                                                  ),
                                                  showTitleActions: true,
                                                  minTime: DateTime(2018, 1, 1),
                                                  maxTime: DateTime(2022, 12, 31),
                                                  onConfirm: (date) {
                                                    _endDate =
                                                    '${date.day}-${date
                                                        .month}-${date.year}';
                                                    setState(() {});
                                                  },
                                                  currentTime: DateTime.now(),
                                                  locale: LocaleType.pt);
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              height: 50.0,
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
                                                      Container(
                                                        child: Row(
                                                          children: <Widget>[
                                                            Icon(
                                                              Icons.date_range,
                                                              size: 18.0,
                                                              color: Colors.black,
                                                            ),
                                                            Text(
                                                              " $_endDate",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                  fontSize: 16.0),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Text(
                                                    "Change",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight
                                                            .bold,
                                                        fontSize: 18.0),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.only(top: 50.0),
                                  decoration: new BoxDecoration(
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)),
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          color: Colors.black,
                                          offset: Offset(0.0, 0.3),
                                          blurRadius: 3.0,
                                        ),
                                      ],
                                      gradient: ColorsStyle.getColorBotton()),
                                  child: MaterialButton(
                                      elevation: 10,
                                      highlightColor: Colors.transparent,
                                      splashColor: Color(0xFFFFFFFF),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10.0, horizontal: 42.0),
                                        child: Text(
                                          "Filter",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18.0),
                                        ),
                                      ),
                                      onPressed: () {
                                        filterData();
                                      }))
                            ],
                          ),
                        ))
                  ],
                ),
              ),
            )));
  }

  filterData() {
    if (_startDate == null ||
        _startDate == '' ||
        _startDate == 'Start') {
      ShowSnackBar.build(
          _scaffoldKey, 'Add the start date!', context);
      return;
    }

    if (_endDate == null || _endDate == '' || _endDate == 'End') {
      ShowSnackBar.build(
          _scaffoldKey, 'Add the End date!', context);
      return;
    }


    var startDateSplit = _startDate.split('-');
    String startDay = startDateSplit[0].trim();
    String startMonth = startDateSplit[1].trim();
    String startYear = startDateSplit[2].trim();
    startMonth = startMonth.length == 1 ? "0$startMonth" : startMonth;
    startDay = startDay.length == 1 ? "0$startDay" : startDay;

    var endDateSplit = _endDate.split('-');
    String endDay = endDateSplit[0].trim();
    String endMonth = endDateSplit[1].trim();
    String endYear = endDateSplit[2].trim();
    endMonth = endMonth.length == 1 ? "0$endMonth" : endMonth;
    endDay = endDay.length == 1 ? "0$endDay" : endDay;


    var startDate = DateTime.parse('$startYear$startMonth$startDay');
    var endDate = DateTime.parse('$endYear$endMonth$endDay');

    _reportBloc.loadReportsByDriverWithData(startDate, endDate);
  }

  Widget _buildFooter(context) => Container(
        color: Colors.white,
        height: 40,
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.lightBlue.withOpacity(0.9),
                child: Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: MaterialButton(
                    child: Text(
                      "PROFIT : ",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    onPressed: () {},
                  ),
                ),
              ),
            ),
            Expanded(
                child: Padding(
                    padding:
                        EdgeInsets.only(top: 5, right: 25, left: 15, bottom: 5),
                    child: StreamBuilder(
                        stream: _reportBloc.totalReportFilterFlux,
                        builder: (BuildContext context,
                            AsyncSnapshot<double> snapshot) {
                          if (!snapshot.hasData)
                            return Text('R\$ 0,0',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'roboto'));
                          return Text(
                              'R\$  ${(snapshot.data).toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'roboto'));
                        }))),
          ],
        ),
      );
}
