import 'package:flutter/material.dart';
import 'package:flutter_icons/feather.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:gocar/src/infra/help/help.dart';
import 'package:gocar/src/provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../entity/entities.dart';
import '../../pages.dart';

class DriverHistoryPage extends StatefulWidget {
  const DriverHistoryPage(this.changeDrawer);

  final ValueChanged<BuildContext> changeDrawer;

  @override
  _DriverHistoryPageState createState() => _DriverHistoryPageState();
}

class _DriverHistoryPageState extends State<DriverHistoryPage> {
  Future<List<Trip>> tripList;
  TripService tripService;
  Driver driver;
  DriverTripBloc _tripBloc;

  @override
  void initState() {
    _tripBloc = new DriverTripBloc();
    _tripBloc.loadTrip();
    super.initState();
  }

  @override
  void dispose() {
    _tripBloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        Container(
          child: StreamBuilder(
              stream: _tripBloc.tripsListFlux,
              builder:
                  (BuildContext context, AsyncSnapshot<List<Trip>> snapshot) {
                if (!snapshot.hasData ||
                    snapshot.connectionState == ConnectionState.waiting)
                  return Center(
                      child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.amber),
                  ));

                List<Trip> tripList = snapshot.data;

                if (tripList.length == 0)
                  return Center(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Icon(
                            Feather.getIconData('search'),
                            size: 40,
                          ),
                        ),
                        Container(
                            child: Text('No registered trip!',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold))),
                      ]));

                return Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: ListView.builder(
                      itemCount: tripList.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return Container(
                          child: _itemHistory(tripList[index]),
                          margin: EdgeInsets.only(top: 25),
                        );
                      }),
                );
              }),
        ),
        buttonBar(widget.changeDrawer, context),
      ],
        ));
  }

  _verifyTripCost(Trip trip) {
    if (trip.status != TripStatus.Finished) return "Canceled";

    print(trip.status);

    return trip.carType == CarType.Pop
        ? 'R\$${(trip.valuePop).toStringAsFixed(2)} '
        : 'R\$${(trip.valueTop).toStringAsFixed(2)} ';
  }

  _itemHistory(Trip trip) =>
      new Container(
        child: new Container(
          margin: new EdgeInsets.only(top: 15, bottom: 15, left: 5, right: 5),
          constraints: new BoxConstraints.expand(),
          child: new Container(
            child: new Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 10),
                  // width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: <Widget>[
                      Image(
                        height: 130,
                        width: 110,
                        image: AssetImage('assets/images/historico/mapa.png'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                SizedBox(width: 5),
                                Text(
                                  DateFormat('dd-MM-yyyy H:mm')
                                      .format(trip.createdOn),
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontFamily: 'roboto',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                                SizedBox(
                                    width:
                                    TripStatus.Finished != trip.status
                                            ? 25
                                            : 30),
                                Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      _verifyTripCost(trip),
                                      style: TextStyle(
                                          fontFamily: 'roboto',
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                    height: 20,
                                    width:
                                    TripStatus.Finished != trip.status
                                            ? 80
                                            : 55,
                                    decoration: new BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0)),
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                            color: Colors.black,
                                            offset: Offset(0.0, 0.3),
                                            blurRadius: 3.0,
                                          ),
                                        ],
                                        gradient: LinearGradient(
                                            colors: TripStatus.Finished !=
                                                trip.status
                                                ? [Colors.red, Colors.redAccent]
                                                : [
                                              Colors.yellowAccent,
                                              Colors.yellow
                                            ],
                                            tileMode: TileMode.repeated)))
                                /*Text("R 58,00")*/
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Image(
                                  height: 100,
                                  image: AssetImage(
                                      'assets/images/history/pick.png'),
                                ),
                                Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Origin",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                        child: new Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            new Text(
                                                HelpService.fixString(
                                                    trip.originAddress, 30),
                                                style: TextStyle(fontSize: 12),
                                                textAlign: TextAlign.left),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Destination",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                        child: new Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            new Text(
                                                HelpService.fixString(
                                                    trip.destinationAddress,
                                                    30),
                                                style: TextStyle(fontSize: 12),
                                                textAlign: TextAlign.left),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        height: 170.0,
        decoration: new BoxDecoration(
          color: new Color(0xFFFFFFFF),
          shape: BoxShape.rectangle,
          borderRadius: new BorderRadius.circular(8.0),
          boxShadow: <BoxShadow>[
            new BoxShadow(
              color: Colors.black12,
              blurRadius: 10.0,
              offset: new Offset(1.0, 10.0),
            ),
          ],
        ),
      );
}
