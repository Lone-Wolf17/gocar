import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/feather.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:gocar/src/infra/infra.dart';
import 'package:gocar/src/provider/blocs/blocs.dart';
import 'package:gocar/src/provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../pages.dart';

class StartTripWidget extends StatelessWidget {
  GlobalKey<ScaffoldState> scaffoldKey;

  StartTripWidget(this.scaffoldKey);

  DriverBaseBloc _authBase = BlocProvider.getBloc<DriverBaseBloc>();
  TripService _tripService = new TripService();
  DriveHomeBloc _homeBloc = BlocProvider.getBloc<DriveHomeBloc>();
  GoogleService _googleService = GoogleService();
  DriverBaseBloc _baseBloc = BlocProvider.getBloc<DriverBaseBloc>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _authBase.tripFlux,
        builder: (BuildContext context, AsyncSnapshot<Trip> snapshot) {
          if (!snapshot.hasData)
            return Container(
              height: 1,
              width: 1,
            );

          var trip = snapshot.data;

          if (trip?.id == null || trip.status == TripStatus.Canceled)
            return Container(
              height: 1,
              width: 1,
            );

          var height = MediaQuery.of(context).size.height * 0.35;
          var width = MediaQuery.of(context).size.width;
          print(trip.passengerEntity.image.url);
          return Positioned.fill(
              child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.transparent,
              child: new Container(
                  height: height,
                  width: width,
                  decoration: new BoxDecoration(
                      color: Colors.white,
                      borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(40.0),
                          topRight: const Radius.circular(40.0))),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "The passenger is waiting!",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w600),
                            ),
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
                                                    size: 28,
                                                    color: Colors.black,
                                                  ),
                                                ],
                                              )
                                            ],
                                          )),
                                      Text(
                                        "R\$${(CarType.Pop ==
                                            trip.carType
                                            ? trip.valuePop
                                            : trip.valueTop).toStringAsFixed(
                                            2)}  ",
                                        style:
                                        TextStyle(
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
                                                                .passengerEntity
                                                                .image
                                                                .indicatesOnLine
                                                                ? NetworkImage(
                                                                trip
                                                                    .passengerEntity
                                                                    .image
                                                                    .url)
                                                                : AssetImage(
                                                                trip
                                                                    .passengerEntity
                                                                    .image
                                                                    .url))),
                                                  )
                                                ],
                                              )
                                            ],
                                          )),
                                      Text(
                                        trip.passengerEntity.name,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(trip.passengerEntity.email,
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
                                        style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                ),
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
                                      "Start Trip",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0),
                                    ),
                                  ),
                                  onPressed: () {
                                    _startTrip(context);
                                  }))
                        ],
                      )),
                ),
              )
            /* */
          );
        });
  }

  Future<void> _startTrip(BuildContext context) async {
    Trip trip = await _authBase.tripFlux.first;

    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);


    /*validates the approximation, prevents the trip from being started with a distance greater than 1km*/
    DistanceTime distanceTime = await _googleService.getDistance(
        LatLng(trip.originLatitude, trip.originLongitude),
        LatLng(position.latitude, position.longitude));

    if (distanceTime.distance.contains('km')) {
      var distance = double.tryParse(
          distanceTime.distance.replaceAll('km', '').replaceAll(',', '.'));

      if (distance > 1) {
        ShowSnackBar.build(
            scaffoldKey,
            'Sorry the trip cannot be started yet you are $distance km from the departure point.',
            context);
        return false;
      }
    }

    trip.status = TripStatus.Started;
    await _tripService.save(trip);
    _homeBloc.stepDriverEvent.add(StepDriverHome.StartTravel);
    _baseBloc.orchestration();
  }
}
