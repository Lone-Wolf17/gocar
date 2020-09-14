import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';

import '../../provider/blocs/blocs.dart';
import 'pages.dart';
import 'shared/tab/hometab.page.dart';

class StartPassengerPage extends StatefulWidget {
  @override
  _StartPassengerPageState createState() => _StartPassengerPageState();
}

class _StartPassengerPageState extends State<StartPassengerPage> {
  PassengerAuthBloc _startPage;

  @override
  void initState() {
    _startPage = BlocProvider.getBloc<PassengerAuthBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _startPage.startFlux,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          print('XXXX: HERE : 1');
          if (!snapshot.hasData) {
            print('XXXX: HERE : 1A');
            return Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                child: Center(
                    child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.amber),
                )));
          }
          print('XXXX: HERE : 3 ${snapshot.data}');
          return snapshot.data ? PassengerIntroPage() : PassengerHomeTabPage();
        });
  }
}
