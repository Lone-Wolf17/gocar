import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:gocar/src/provider/blocs/blocs.dart';

import '../../../pages.dart';

class SearchInputWidget extends StatelessWidget {
  GlobalKey<ScaffoldState> scaffoldKey;

  SearchInputWidget(this.scaffoldKey);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      top: 100,
      child: Align(
        alignment: Alignment.topCenter,
        child: InkWell(
          onTap: () {
            _functionValidateSearchOriginDestination(context);
          },
          child: new Container(
            margin: EdgeInsets.only(right: 5, left: 5),
            width: MediaQuery.of(context).size.width * 0.98,
            child: Text(
              "Where are we going?",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            decoration: new BoxDecoration(
                borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                color: Colors.white),
            padding: new EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
          ),
        ),
      ),
    );
  }

  _functionValidateSearchOriginDestination(BuildContext context) async {
    PassengerAuthBloc authBloc = BlocProvider.getBloc<PassengerAuthBloc>();
    PassengerHomeBloc homeBloc = BlocProvider.getBloc<PassengerHomeBloc>();
    HomeTabBloc homeTabBloc = BlocProvider.getBloc<HomeTabBloc>();
    print('XXXX: HERE : 9');
    Passenger passenger = await authBloc.userInfoFlux.first;

    if (passenger == null) {
      await authBloc.refreshAuth();
      passenger = await authBloc.userInfoFlux.first;
    }

    if (passenger.age < 10) {
      ShowSnackBar.build(
          scaffoldKey,
          'It is necessary to complete the registration to start a trip. Please fill in the age!',
          context);

      Future.delayed(const Duration(milliseconds: 4000), () {
        homeTabBloc.tabPageControllerEvent.add(1);
      });
    } else {
      print('XXXX: HERE : 10');
      homeBloc.stepProcessEvent
          .add(StepPassengerHome.SelectOriginAndDestination);
    }
  }
}
