import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/feather.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:gocar/src/infra/infra.dart';
import 'package:gocar/src/provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../pages.dart';

class DriverFoundWidget extends StatelessWidget {
  GlobalKey<ScaffoldState> scaffoldKey;

  DriverFoundWidget(this.scaffoldKey);

  BasePassengerBloc _baseBloc = BlocProvider.getBloc<BasePassengerBloc>();
  PassengerHomeBloc _homeBloc = BlocProvider.getBloc<PassengerHomeBloc>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _baseBloc.tripFlow,
        builder: (BuildContext context, AsyncSnapshot<Trip> snapshot) {
          if (!snapshot.hasData)
            return Container(
              height: 1,
              width: 1,
            );

          var height = MediaQuery.of(context).size.height * 0.43;
          var width = MediaQuery.of(context).size.width;

          var trip = snapshot.data;

          if (trip?.id == null || trip.status == TripStatus.Canceled)
            return Container(
              height: 1,
              width: 1,
            );

          var timeLimit = (trip.tripAcceptedOn).add(Duration(minutes: 5));
          var canceledAt = DateFormat('hh:mm').format(timeLimit);

          return Positioned(
              height: height,
              width: width,
              bottom: 0,
              child: new Container(
                color: Colors.transparent,
                child: new Container(
                    decoration: new BoxDecoration(
                        color: Colors.white,
                        borderRadius: new BorderRadius.only(
                            topLeft: const Radius.circular(40.0),
                            topRight: const Radius.circular(40.0))),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 2,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Your driver is on the way!",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          child: Text(
                              'The driver is on his way, please wait .If you want to change your trip, you can cancel '
                                  'free of charge before ${canceledAt}.',
                              style: TextStyle(fontSize: 14)),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          height: 1,
                          color: Colors.grey.withOpacity(0.4),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    CircleAvatar(
                                        radius: 25.0,
                                        backgroundColor:
                                            Colors.grey.withOpacity(0.1),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: <Widget>[
                                            Stack(
                                              alignment: Alignment.center,
                                              children: <Widget>[
                                                Icon(
                                                  Feather.getIconData(
                                                      'dollar-sign'),
                                                  size: 24,
                                                  color: Colors.black,
                                                ),
                                              ],
                                            )
                                          ],
                                        )),
                                    Text(
                                      "R\$${(CarType.Pop == trip.carType ? trip
                                          .valuePop : trip.valueTop)
                                          .toStringAsFixed(2)}  ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'roboto'),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    CircleAvatar(
                                        radius: 25.0,
                                        backgroundColor:
                                            Colors.grey.withOpacity(0.1),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: <Widget>[
                                            Stack(
                                              alignment: Alignment.center,
                                              children: <Widget>[
                                                Container(
                                                  height: 60,
                                                  width: 50,
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.white,
                                                          width: 2),
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          70),
                                                      image: DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: trip
                                                              .driverEntity
                                                              .image
                                                              .indicatesOnLine
                                                              ? NetworkImage(
                                                              trip
                                                                  .driverEntity
                                                                  .image
                                                                  .url)
                                                              : AssetImage(trip
                                                              .driverEntity
                                                              .image
                                                              .url))),
                                                )
                                              ],
                                            )
                                          ],
                                        )),
                                    Text(
                                      '${HelpService.fixString(
                                          trip.driverEntity.name, 15)}',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                        '${HelpService.fixString(
                                            trip.driverEntity.email, 13)}',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    CircleAvatar(
                                        radius: 25.0,
                                        backgroundColor:
                                            Colors.grey.withOpacity(0.1),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: <Widget>[
                                            Stack(
                                              alignment: Alignment.center,
                                              children: <Widget>[
                                                Icon(
                                                  Feather.getIconData(
                                                      'map-pin'),
                                                  size: 24,
                                                  color: Colors.black,
                                                ),
                                              ],
                                            )
                                          ],
                                        )),
                                    Text(
                                      trip.distance,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Center(
                          child: Column(
                            children: <Widget>[
                              Text(
                                '${HelpService.fixString(
                                    trip.driverEntity.car.board, 10)}',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                  '${HelpService.fixString(
                                      trip.driverEntity.car.color,
                                      10)} - ${HelpService.fixString(
                                      trip.driverEntity.car.model, 10)}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Container(
                            width: width * 0.9,
                            margin: EdgeInsets.only(top: 10.0),
                            decoration: new BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: Colors.black,
                                    offset: Offset(0.0, 0.3),
                                    blurRadius: 1.0,
                                  ),
                                ],
                                gradient: ColorsStyle.getColorBotton()),
                            child: MaterialButton(
                                highlightColor: Colors.transparent,
                                splashColor: Color(0xFFFFFFFF),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 35.0),
                                  child: Text(
                                    "Cancelar",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                  ),
                                ),
                                onPressed: () async {
                                  if (DateTime.now().isAfter(timeLimit)) {
                                    ShowSnackBar.build(
                                        scaffoldKey,
                                        'Sorry the trip cannot be canceled by the app,'
                                            ' the time for cancellation is over, wait for the driver and cancel in person!',
                                        context);
                                    return;
                                  }

                                  await _baseBloc.cancelTrip();
                                  _homeBloc.stepProcessEvent
                                      .add(StepPassengerHome.Start);
                                  _baseBloc.tripEvent.add(Trip());
                                  await _baseBloc.orchestration();
                                }))
                      ],
                    )),
              )
              /* */
              );
        });
  }
}
