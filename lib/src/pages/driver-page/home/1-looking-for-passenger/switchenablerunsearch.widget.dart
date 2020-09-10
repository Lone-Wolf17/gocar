import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:gocar/src/provider/provider.dart';

import '../../../pages.dart';

class SwitchEnableRunSearch extends StatefulWidget {
  bool _value;
  GlobalKey<ScaffoldState> scaffoldKey;

  SwitchEnableRunSearch(this._value, this.scaffoldKey);

  @override
  _SwitchEnableRunSearchState createState() => _SwitchEnableRunSearchState();
}

class _SwitchEnableRunSearchState extends State<SwitchEnableRunSearch> {
  bool _value = false;
  DriverBaseBloc _baseBloc;
  DriveHomeBloc _homeBloc;
  DriverAuthBloc _driverAuthBloc;
  HomeTabBloc _homeTabBloc;

  @override
  void initState() {
    _baseBloc = BlocProvider.getBloc<DriverBaseBloc>();
    _homeBloc = BlocProvider.getBloc<DriveHomeBloc>();
    _homeTabBloc = BlocProvider.getBloc<HomeTabBloc>();
    _driverAuthBloc = BlocProvider.getBloc<DriverAuthBloc>();
    _value = widget._value;
    super.initState();
  }

  validateStartTrip(bool value) async {
    Driver driver = await _driverAuthBloc.userInfoFlux.first;

    if (driver == null) {
      await _driverAuthBloc.refreshAuth();
      driver = await _driverAuthBloc.userInfoFlux.first;
    }

    if (driver.car == null ||
        driver.car.board == null ||
        driver.car.board == '') {
      ShowSnackBar.build(
          widget.scaffoldKey,
          'It is necessary to complete the registration to start a trip. Please fill in vehicle related information!',
          context);

      Future.delayed(const Duration(milliseconds: 4000), () {
        _homeTabBloc.tabPageControllerEvent.add(1);
      });
      return;
    }

    _onChanged1(value);
  }

  void _onChanged1(bool value) =>
      setState(() {
    if (value) {
      _homeBloc.stepDriverEvent.add(StepDriverHome.LookingForTravel);

        } else {
      _homeBloc.stepDriverEvent.add(StepDriverHome.Start);
        }

    Future.delayed(const Duration(milliseconds: 2000), () {
      _baseBloc.orchestration();
    });
        _value = value;
      });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.topRight,
        child: new Container(
          margin: EdgeInsets.only(top: 30, right: 25),
          child: Switch(
              activeColor: Colors.blueAccent,
              value: _value,
              onChanged: validateStartTrip),
        ),
      ),
    );
  }
}
