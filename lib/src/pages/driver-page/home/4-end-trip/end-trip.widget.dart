import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:gocar/src/provider/provider.dart';

import '../../../pages.dart';
import '../../pages.dart';

class EndTripWidget extends StatelessWidget {
  GlobalKey<ScaffoldState> scaffoldKey;

  EndTripWidget(this.scaffoldKey);

  DriverBaseBloc _authBase = BlocProvider.getBloc<DriverBaseBloc>();
  TripService _tripService = new TripService();
  DriverBaseBloc _baseBloc = BlocProvider.getBloc<DriverBaseBloc>();
  DriveHomeBloc _homeBloc = BlocProvider.getBloc<DriveHomeBloc>();

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
                'Finish Trip !',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            onChanged: (result) {
              if (result == SwipePosition.SwipeRight) {
                _endTrip().then((r) {
                  ShowSnackBar.build(
                      scaffoldKey, 'Trip successfully completed.', context);
                });
              } else {}
            },
          ),
        ),
      ),
    );
  }

  Future<void> _endTrip() async {
    Trip trip = await _authBase.tripFlux.first;
    trip.status = TripStatus.Finished;
    await _tripService.save(trip);
    Future.delayed(const Duration(milliseconds: 1000), () {
      _homeBloc.stepDriverEvent.add(StepDriverHome.Start);
      _baseBloc.orchestration();
    });
  }
}
