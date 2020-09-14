import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:gocar/src/pages/pages.dart';
import 'package:gocar/src/provider/blocs/blocs.dart';
import 'package:gocar/src/provider/provider.dart';

import 'infra/admin/admin.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Bloc<BlocBase>> passengerBlocs = _passengerBloc();
    List<Bloc<BlocBase>> driverBlocs = _driverBloc();

    return BlocProvider(
      blocs: configPersonType == PersonType.Passenger
          ? passengerBlocs
          : driverBlocs,
      child: MaterialApp(
          locale: Locale('en', 'NG'),
          title: "GoCar App ",
          debugShowCheckedModeBanner: false,
          home: configPersonType == PersonType.Passenger
              ? StartPassengerPage()
              : StartDriverPage(),
          routes: configPersonType == PersonType.Passenger
              ? passengerRoutesConfig
              : driverRoutesConfig,
          theme: ThemeData(
              fontFamily: "Raleway",
              scaffoldBackgroundColor: Colors.white,
              textTheme: TextTheme(bodyText2: TextStyle(fontSize: 16)))),
    );
  }

  /*passenger provider*/
  List<Bloc<BlocBase>> _passengerBloc() {
    final List<Bloc<BlocBase>> passengerBlocs = [
      Bloc((i) => LoadingBloc()),
      Bloc((i) => HomeTabBloc()),
      Bloc((i) => PassengerHomeBloc()),
      Bloc((i) => PassengerAuthBloc()),
      Bloc((i) => PassengerTripBloc()),
      Bloc((i) => BasePassengerBloc()),
    ];
    return passengerBlocs;
  }

/*driver provider*/
  List<Bloc<BlocBase>> _driverBloc() {
    final List<Bloc<BlocBase>> driverBlocs = [
      Bloc((i) => LoadingBloc()),
      Bloc((i) => HomeTabBloc()),
      Bloc((i) => DriveHomeBloc()),
      Bloc((i) => DriverAuthBloc()),
      Bloc((i) => DriverBaseBloc()),
    ];
    return driverBlocs;
  }
}
