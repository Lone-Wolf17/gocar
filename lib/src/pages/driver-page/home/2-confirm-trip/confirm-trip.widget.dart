import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:gocar/src/entity/enums.dart';
import 'package:gocar/src/provider/blocs/blocs.dart';
import 'package:gocar/src/provider/provider.dart';

import '../../pages.dart';

class ConfirmTripWidget extends StatelessWidget {
  DriverBaseBloc _authBase = BlocProvider.getBloc<DriverBaseBloc>();
  DriverAuthBloc _driverAuthBloc = BlocProvider.getBloc<DriverAuthBloc>();
  TripService _tripService = new TripService();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SwipeButton(
            thumb: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Align(
                    widthFactor: 0.90,
                    child: Icon(
                      Icons.chevron_right,
                      size: 30.0,
                      color: Colors.black,
                    )),
              ],
            ),
            content: Center(
              child: Text(
                'Accept Trip!',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            onChanged: (result) {
              if (result == SwipePosition.SwipeRight) {
                _startTrip().then(((r) => {}));
              } else {}
            },
          ),
        ),
      ),
    );
  }

  Future<void> _startTrip() async {
    Trip trip = await _authBase.tripFlux.first;
    Driver driver = await _driverAuthBloc.userInfoFlux.first;
    trip.status = TripStatus.DriverOnTheWay;
    trip.driverEntity = driver;
    await _tripService.save(trip);
  }
}
