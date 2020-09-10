import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:gocar/src/provider/blocs/blocs.dart';

class ReturnLookingForDriverWidget extends StatelessWidget {
  BasePassengerBloc _baseBloc = BlocProvider.getBloc<BasePassengerBloc>();
  PassengerHomeBloc _homeBloc = BlocProvider.getBloc<PassengerHomeBloc>();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: RawMaterialButton(
            onPressed: () async {
              await _baseBloc.cancelTrip();
              _homeBloc.stepProcessEvent.add(StepPassengerHome.Start);
              _baseBloc.tripEvent.add(Trip());
              await _baseBloc.orchestration();
            },
            child: new Icon(
              Icons.arrow_back,
              color: Colors.black,
              size: 25.0,
            ),
            shape: new CircleBorder(),
            elevation: 10.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(1.0),
          )),
    );
  }
}
