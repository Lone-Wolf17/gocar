import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:gocar/src/pages/driver-page/home/3-start-trip/starttrip.widget.dart';
import 'package:gocar/src/pages/driver-page/home/4-end-trip/end-trip.widget.dart';
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
  DriveHomeBloc _homeBloc;
  DriverBaseBloc _baseBloc;
  GlobalKey<ScaffoldState> _scaffoldKey;
  Completer<GoogleMapController> _controller;

  @override
  void initState() {
    _scaffoldKey = new GlobalKey<ScaffoldState>();
    _controller = Completer();
    _baseBloc = BlocProvider.getBloc<DriverBaseBloc>();
    _homeBloc = BlocProvider.getBloc<DriveHomeBloc>();
    _homeBloc.stepDriverEvent.add(StepDriverHome.Start);
    _baseBloc.orchestration();
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
        body: StreamBuilder<StepDriverHome>(
            stream: _homeBloc.stepDriverFlux,
            builder: (BuildContext context,
                AsyncSnapshot<StepDriverHome> snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.amber),
                ));
              }

              StepDriverHome step = snapshot.data;
              var widgetsHome = _configHome(step);
              return Stack(
                children: widgetsHome,
              );
            }));
  }

  /*constroi a tela de acordo com a etapa atual do processo*/
  List<Widget> _configHome(StepDriverHome stepHome) {
    var widgetsHome = <Widget>[];
    widgetsHome = <Widget>[_buildGoogleMap()];

    switch (stepHome) {
      case StepDriverHome.Start:
        widgetsHome.add(buttonBar(widget.changeDrawer, context));
        widgetsHome.add(SwitchEnableRunSearch(false, _scaffoldKey));
        return widgetsHome;
        break;
      case StepDriverHome.LookingForTravel:
        widgetsHome.add(buttonBar(widget.changeDrawer, context));
        widgetsHome.add(InputLookingForTrip());
        widgetsHome.add(RadarWidget());
        widgetsHome.add(SwitchEnableRunSearch(true, _scaffoldKey));
        return widgetsHome;
        break;
      case StepDriverHome.TravelFound:
        widgetsHome.add(ConfirmTripWidget());
        return widgetsHome;
        break;
      case StepDriverHome.TravelAccepted:
        widgetsHome.add(StartTripWidget(_scaffoldKey));
        return widgetsHome;
        break;
      case StepDriverHome.EndTrip:
        widgetsHome.add(EndTripWidget(_scaffoldKey));
        return widgetsHome;
        break;
      default:
        return widgetsHome;
        break;
    }
  }

  Future _resizeZoom(MapProvider provider) async {
    var next = await _homeBloc.stepDriverFlux.first;

    if (next == StepDriverHome.Start)
      await Future.delayed(const Duration(milliseconds: 1500), () {
        _gotoLocation(provider.driverPositionLatLng.latitude,
            provider.driverPositionLatLng.longitude, 18, 0, 0);
      });
    else if (next == StepDriverHome.LookingForTravel) {
      await Future.delayed(const Duration(milliseconds: 1500), () {
        _gotoLocation(provider.driverPositionLatLng.latitude,
            provider.driverPositionLatLng.longitude, 14, 0, 0);
      });
    } else if (next == StepDriverHome.TravelFound) {
      await Future.delayed(const Duration(milliseconds: 1500), () {
        _gotoLocation(provider.driverPositionLatLng.latitude,
            provider.driverPositionLatLng.longitude, 17, 0, 0);
      });
    } else if (next == StepDriverHome.TravelAccepted) {
      await Future.delayed(const Duration(milliseconds: 1500), () {
        _gotoLocation(provider.driverPositionLatLng.latitude,
            provider.driverPositionLatLng.longitude, 18, 0, 0);
      });
    } else if (next == StepDriverHome.EndTrip) {
      await Future.delayed(const Duration(milliseconds: 1500), () {
        _gotoLocation(provider.driverPositionLatLng.latitude,
            provider.driverPositionLatLng.longitude, 16, 0, 0);
      });
    }

    return false;
  }

  Widget _buildGoogleMap() {
    return StreamBuilder(
        stream: _baseBloc.mapProviderFlux,
        builder: (BuildContext context, AsyncSnapshot<MapProvider> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.amber),
            ));
          }

          MapProvider provider = snapshot.data;

          /*reposition with zoom*/
          _resizeZoom(provider);

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
              initialCameraPosition: CameraPosition(
                  target: provider.driverPositionLatLng, zoom: 16),
              //onMapCreated: appState.onCreated,
              myLocationEnabled: false,
              mapType: MapType.normal,
              compassEnabled: true,
              markers: provider.markers,
              // onCameraMove: appState.onCameraMove,
              polylines: provider.polyLines,
            ),
          );
        });
  }

  Future<void> _gotoLocation(
      double lat, double long, double zoom, double tilt, double bearing) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, long),
      zoom: zoom,
      tilt: tilt,
      bearing: bearing,
    )));
  }
}
