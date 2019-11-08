import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:gocar/src/pages/passageiro-page/pages.dart';

import '../../provider/blocs/blocs.dart';
import 'shared/tab/hometab.page.dart';

class StartPassageiroPage extends StatefulWidget {
  @override
  _StartPassageiroPageState createState() => _StartPassageiroPageState();
}

class _StartPassageiroPageState extends State<StartPassageiroPage> {
  AuthPassageiroBloc _startPage;

  @override
  void initState() {
    _startPage = BlocProvider.getBloc<AuthPassageiroBloc>();
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
          return snapshot.data ? IntroPage() : HomeTabPage();
        });
  }
}
