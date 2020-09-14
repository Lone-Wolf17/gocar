import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/feather.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:gocar/src/infra/admin/admin.dart';
import 'package:gocar/src/provider/provider.dart';

import '../../pages.dart';

class PassengerHomeTabPage extends StatefulWidget {
  @override
  _PassengerHomeTabPageState createState() => _PassengerHomeTabPageState();
}

class _PassengerHomeTabPageState extends State<PassengerHomeTabPage> {
  HomeTabBloc _homeBloc;
  PassengerAuthBloc _authBloc;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _homeBloc = BlocProvider.getBloc<HomeTabBloc>();
    _authBloc = BlocProvider.getBloc<PassengerAuthBloc>();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              StreamBuilder(
                  stream: _authBloc.userInfoFlux,
                  builder: (BuildContext context,
                      AsyncSnapshot<Passenger> snapshot) {
                    if (!snapshot.hasData) {
                      return Container(
                        height: 1,
                        width: 1,
                      );
                    }

                    Passenger passenger = snapshot.data;

                    return DrawerHeader(
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
                                    image: passenger.image.indicatesOnLine
                                        ? NetworkImage(passenger.image.url)
                                        : AssetImage(passenger.image.url))),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            passenger.name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          /* Text(
                            passageiro.Email,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          )*/
                        ],
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                    );
                  }),
              _tileGet(0, "home", "Home"),
              _tileGet(1, "user", "Profile"),
              _tileGet(2, "archive", "History"),
              _tileGet(3, "settings", "Configuration"),
              ListTile(
                leading: Icon(
                  Feather.getIconData('log-out'),
                  color: Colors.black,
                  size: 25,
                ),
                title: Text(
                  'Logout',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                onTap: () {
                  _authBloc.signOut().then((r) {
                    PassengerPagesNavigation.goToAccount(context);
                  });
                },
              )
            ],
          ),
        ),
      ),
      body: _getPage(),
    );
  }

  void changeDrawer(BuildContext contextValue) {
    _authBloc.refreshAuth();
    Scaffold.of(contextValue).openDrawer();
  }

  Widget _tileGet(int index, String icon, String title) {
    return ListTile(
      leading: Icon(
        Feather.getIconData(icon),
        color: Colors.black,
        size: 25,
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      onTap: () {
        _homeBloc.tabPageControllerEvent.add(index);
        _scaffoldKey.currentState.openEndDrawer();
      },
    );
  }

  Widget _getPage() => StreamBuilder(
      stream: _homeBloc.tabPageControllerFlux,
      initialData: 0,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        var position = snapshot.hasData ? snapshot.data : 0;
        print('XXXX: HERE : 4');
        switch (position) {
          case 0:
            print('XXXX: HERE : 5');
            return HomePage(changeDrawer);
            break;
          case 1:
            return ProfilePage(changeDrawer);
            break;
          case 2:
            return HistoryPage(changeDrawer);
          case 3:
            return ConfigurationPage(changeDrawer);
            break;
          default:
            return HomePage(changeDrawer);
        }
      });
}
