import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/feather.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:gocar/src/provider/blocs/blocs.dart';

import '../../pages.dart';
import '../add-place/add-place.dart';

class ConfigurationPage extends StatefulWidget {
  const ConfigurationPage(this.changeDrawer);

  final ValueChanged<BuildContext> changeDrawer;

  @override
  _ConfigurationPageState createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {
  PassengerAuthBloc _authBloc;

  @override
  void initState() {
    _authBloc = BlocProvider.getBloc<PassengerAuthBloc>();
    _authBloc.refreshAuth();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _updatePassenger(Passenger passenger) async {
    await _authBloc.addPassengerAuth(passenger);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              StreamBuilder(
                  stream: _authBloc.userInfoFlux,
                  builder: (BuildContext context,
                      AsyncSnapshot<Passenger> snapshot) {
                    if (!snapshot.hasData)
                      return Container(
                        height: 1,
                        width: 1,
                      );
                    Passenger passenger = snapshot.data;
                    return Container(
                      height: 200,
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 50),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white, width: 2),
                                borderRadius: BorderRadius.circular(70),
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(passenger.image.url))),
                          ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                passenger.name,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ],
                          ),
                        );
                      }),
                  Padding(
                    padding: const EdgeInsets.only(left: 18),
                    child: Container(
                      child: Text(
                        'Favorite Places',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                  ),
                  _getLocal('home', 'Add House', LocaleType.Home),
                  _getContentAddress(LocaleType.Home),
                  _getLocal('briefcase', 'Add Work', LocaleType.Work),
                  _getContentAddress(LocaleType.Work),
                ],
              ),
              buttonBar(widget.changeDrawer, context),
            ],
          ),
        ));
  }

  Widget _getLocal(String icon, String label, LocaleType localeType) =>
      GestureDetector(
        onTap: () =>
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddLocationPage(localeType))),
        child: Padding(
          padding: const EdgeInsets.only(left: 18, top: 10),
          child: Container(
            margin: EdgeInsets.only(left: 10, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Feather.getIconData(icon)),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(label, style: TextStyle(color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0),),
                  ),
                ),
                StreamBuilder(
                    stream: _authBloc.userInfoFlux,
                    builder: (BuildContext context,
                        AsyncSnapshot<Passenger> snapshot) {
                      if (!snapshot.hasData)
                        return Center(child: CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(
                              Colors.amber),
                        ));

                      Passenger passenger = snapshot.data;

                      if (localeType == LocaleType.Home) {
                        if (passenger.home == null ||
                            passenger.home?.address == null)
                          return Container(width: 10, height: 10);
                      } else {
                        if (passenger.work == null ||
                            passenger.work?.address == null)
                          return Container(width: 10, height: 10);
                      }

                      return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (localeType == LocaleType.Home) {
                                passenger.home = null;
                              } else {
                                passenger.work = null;
                              }
                              _updatePassenger(passenger);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Text(
                                'Delete',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ));
                    })
              ],
            ),
          ),
        ),
      );

  Widget _getContentAddress(LocaleType localeType) =>
      StreamBuilder(
          stream: _authBloc.userInfoFlux,
          builder: (BuildContext context, AsyncSnapshot<Passenger> snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.amber),
              ));

            Passenger passenger = snapshot.data;

            if (localeType == LocaleType.Home) {
              if (passenger.home == null || passenger?.home?.name == null)
                return Container(width: 10, height: 10);
            } else {
              if (passenger.work == null || passenger?.work?.name == null)
                return Container(width: 10, height: 10);
            }
            return Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Text(localeType == LocaleType.Home
                  ? passenger.home.name
                  : passenger.work.name, style: TextStyle(fontSize: 12),),
            );
      });
}
