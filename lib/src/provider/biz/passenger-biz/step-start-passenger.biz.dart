import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../provider.dart';

class StepStartPassengerBiz {
  static StepStartPassengerBiz _instance;

  factory StepStartPassengerBiz() {
    _instance ??= StepStartPassengerBiz._internalConstructor();
    return _instance;
  }

  StepStartPassengerBiz._internalConstructor();

  GoogleService _googleService = GoogleService();
  BasePassengerBloc _passengerBaseBloc =
      BlocProvider.getBloc<BasePassengerBloc>();
  StreamSubscription<Position> _streamInitialPosition;

  /*passenger start*/
  Future start() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    /*get the address name based on lat and log*/
    var address = await _googleService.getAddressByCoordinates(
        position.latitude.toString(), position.longitude.toString());

    final MapProvider mapProvider = MapProvider(
        originAddress: address,
        originLatLng: LatLng(position.latitude, position.longitude));

    await _addPassengerCurrentMapLocation(mapProvider, 120);
    Future.delayed(const Duration(milliseconds: 500), () {
      startMonitoringPassengerMap();
    });
  }

  void closeStreamsFlow() {
    if (_streamInitialPosition != null) _streamInitialPosition?.cancel();
  }

  /*- responsible for obtaining any change in the passenger’s location and updates the map*/
  Future<void> startMonitoringPassengerMap() async {
    try {
      Geolocator _geoLocator = Geolocator();

      if (_streamInitialPosition != null) _streamInitialPosition?.cancel();

      var locationOptions =
          LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);

      MapProvider mapProvider = await _passengerBaseBloc.mapProviderFlux.first;
      bool semaforo = true;

      _streamInitialPosition = _geoLocator
          .getPositionStream(locationOptions)
          .listen((Position position) {
        if (position != null && semaforo) {
          semaforo = false;
          Future.delayed(const Duration(milliseconds: 100), () async {
            /*get the address name based on lat and log*/
            var address = await _googleService.getAddressByCoordinates(
                position.latitude.toString(), position.longitude.toString());

            mapProvider.originLatLng =
                LatLng(position.latitude, position.longitude);
            mapProvider.originAddress = address;
            print('Initial monitoring of the passenger location.');

            _addPassengerCurrentMapLocation(mapProvider, 120).then((r) {
              /*waiting to finish to set the cart on the map*/
              semaforo = true;
            });
          });
        }
      });
    } on Exception catch (ex) {
      print(
          'Error method startMonitoringPassengerMap, class StepStartPassengerBiz -  $ex');
    }
  }

  /*set cart on map*/
  Future _addPassengerCurrentMapLocation(
      MapProvider provider, int iconSize) async {
    try {
      provider.markers = Set<Marker>();
      /*add cart*/
      provider.markers.add(Marker(
          markerId: MarkerId(provider.originAddress.toString()),
          position: provider.originLatLng,
          flat: true,
          infoWindow:
              InfoWindow(title: provider.originAddress, snippet: "This One!"),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen)));

      _passengerBaseBloc.mapProviderEvent.add(provider);
    } on Exception catch (ex) {
      print(
          'Error method _addPassengerCurrentMapLocation, class StepStartPassengerBiz -  $ex');
    }
  }

/*end method*/

}
