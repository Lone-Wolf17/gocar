import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:gocar/src/pages/driver-page/pages.dart';
import 'package:gocar/src/provider/provider.dart';

class StartDriverPage extends StatefulWidget {
  @override
  _StartDriverPageState createState() => _StartDriverPageState();
}

class _StartDriverPageState extends State<StartDriverPage> {
  DriverAuthBloc _startPage;

  @override
  void initState() {
    _startPage = BlocProvider.getBloc<DriverAuthBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _startPage.startFlux,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {

          if (!snapshot.hasData) {
            return Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
            color: Colors.white,
                child: Center(child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.amber),
                )));
          }
          return snapshot.data ? DriverIntroPage() : DriverHomeTabPage();
        });
  }
}
