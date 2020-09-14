import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:gocar/src/provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../pages.dart';
import 'widget.dart';

class HomePage extends StatefulWidget {
  const HomePage(this.changeDrawer);

  final ValueChanged<BuildContext> changeDrawer;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PassengerHomeBloc _homeBloc;
  BasePassengerBloc _baseBloc;
  GlobalKey<ScaffoldState> _scaffoldKey;
  Completer<GoogleMapController> _controller;

  @override
  void initState() {
    _baseBloc = BlocProvider.getBloc<BasePassengerBloc>();
    _homeBloc = BlocProvider.getBloc<PassengerHomeBloc>();
    _homeBloc.stepProcessEvent.add(StepPassengerHome.Start);
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _baseBloc.orchestration();
    _controller = Completer();
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
        body: StreamBuilder<StepPassengerHome>(
            stream: _homeBloc.stepProcessFlux,
            builder: (BuildContext context,
                AsyncSnapshot<StepPassengerHome> snapshot) {
              print('XXXX: HERE : 6');
              if (!snapshot.hasData) {
                print('XXXX: HERE : 6A');
                return Center(
                    child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.amber),
                ));
              }

              StepPassengerHome step = snapshot.data;
              var widgetsHome = _configHome(step);
              return Stack(
                children: widgetsHome,
              );
            }));
  }

  /*build the screen according to the current stage of the process*/
  List<Widget> _configHome(StepPassengerHome stepHome) {
    print('XXXX: HERE : 7 :: stephome = $stepHome');
    var widgetsHome = <Widget>[];
    widgetsHome = <Widget>[_buildGoogleMap()];
    switch (stepHome) {
      case StepPassengerHome.Start:
        widgetsHome.add(buttonBar(widget.changeDrawer, context));
        widgetsHome.add(SearchInputWidget(_scaffoldKey));
        return widgetsHome;
        break;
      case StepPassengerHome.SelectOriginAndDestination:
        widgetsHome.add(SelectOriginDestinationWidget());
        return widgetsHome;
        break;
      case StepPassengerHome.ConfirmValue:
        widgetsHome.add(ReturnConfirmTripWidget());
        widgetsHome.add(ConfrimPassengerTrip());
        return widgetsHome;
        break;
      case StepPassengerHome.LookingForADriver:
        widgetsHome.add(ReturnLookingForDriverWidget());
        widgetsHome.add(LookingForDriverWidget());
        widgetsHome.add(RadarWidget());
        return widgetsHome;
        break;
      case StepPassengerHome.DriverAccepted:
        widgetsHome.add(DriverFoundWidget(_scaffoldKey));
        return widgetsHome;
        break;
      case StepPassengerHome.TripInProgress:
        widgetsHome.add(TripStartedWidget());
        return widgetsHome;
        break;
      case StepPassengerHome.EndTrip:
        widgetsHome.add(TripFinalizedWidget(_scaffoldKey));
        return widgetsHome;
        break;
      default:
        return widgetsHome;
        break;
    }
  }

  Future _resizeZoom(MapProvider provider) async {
    var next = await _homeBloc.stepProcessFlux.first;

    if (next == StepPassengerHome.ConfirmValue)
      await Future.delayed(const Duration(milliseconds: 1500), () {
        _gotoLocation(provider.originLatLng.latitude,
            provider.originLatLng.longitude, 14, 0, 0);
      });
    else if (next == StepPassengerHome.Start)
      await Future.delayed(const Duration(milliseconds: 1500), () {
        _gotoLocation(provider.originLatLng.latitude,
            provider.originLatLng.longitude, 15, 0, 0);
      });
    else if (next == StepPassengerHome.DriverAccepted &&
        provider.driverPositionLatLng != null &&
        provider.driverPositionLatLng.latitude != null)
      await Future.delayed(const Duration(milliseconds: 1500), () {
        _gotoLocation(provider.driverPositionLatLng.latitude,
            provider.driverPositionLatLng.longitude, 17, 0, 0);
      });
    else if (next == StepPassengerHome.TripInProgress &&
        provider.driverPositionLatLng != null)
      await Future.delayed(const Duration(milliseconds: 1500), () {
        _gotoLocation(provider.driverPositionLatLng.latitude,
            provider.driverPositionLatLng.longitude, 15, 0, 0);
      });
    else if (next == StepPassengerHome.LookingForADriver)
      await Future.delayed(const Duration(milliseconds: 1500), () {
        _gotoLocation(provider.originLatLng.latitude,
            provider.originLatLng.longitude, 17, 0, 0);
      });
    return false;
  }

  Widget _buildGoogleMap() {
    return StreamBuilder(
        stream: _baseBloc.mapProviderFlux,
        builder: (BuildContext context, AsyncSnapshot<MapProvider> snapshot) {
          print('XXXX: HERE : 8 snapshot.hasData = ${snapshot.hasData}');
          MapProvider provider;
          if (!snapshot.hasData) {
            print('XXXX: HERE : 8A');
            _getUserLocation();
            return Center(child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.amber),
            ));
          } else {
            provider = snapshot.data;
          }


          /*reposition with zoom*/
          _resizeZoom(provider);
          print("YYYY: ${provider.circleMap}");
          print(provider);
          return Container(
            height: MediaQuery
                .of(context)
                .size
                .height,
            width: MediaQuery
                .of(context)
                .size
                .width,
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              circles: provider.circleMap,
              initialCameraPosition:
              CameraPosition(target: provider.originLatLng, zoom: 19),
              mapType: MapType.normal,
              compassEnabled: true,
              markers: provider.markers,
              // onCameraMove: appState.onCameraMove,
              polylines: provider.polyLines,
            ),
          );
        });
  }

  //! TO GET THE USERS LOCATION
  void _getUserLocation() async {
    print("GET USER METHOD RUNNING =====");
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    // List<Placemark> placemark = await Geolocator()
    //     .placemarkFromCoordinates(position.latitude, position.longitude);

    print('XXXX: HERE : 17');
    _baseBloc.mapProviderEvent.add(MapProvider(
        originLatLng: LatLng(position.latitude, position.longitude)));
    print('XXXX: HERE : 18');
    // _initialPosition = LatLng(position.latitude, position.longitude);
    // locationController.text = placemark[0].name;


//    print("initial position is : ${ini}")
//     locationController.text = placemark[0].name;
//     notifyListeners();
  }

  Future<void> _gotoLocation(double lat, double long, double zoom, double tilt,
      double bearing) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, long),
      zoom: zoom,
      tilt: tilt,
      bearing: bearing,
    )));
  }
}
