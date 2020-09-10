import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../provider.dart';

class StepStartDriverBiz {
  static StepStartDriverBiz _instance;

  factory StepStartDriverBiz() {
    _instance ??= StepStartDriverBiz._internalConstructor();
    return _instance;
  }

  StepStartDriverBiz._internalConstructor();

  GoogleService _googleService = GoogleService();
  DriverBaseBloc _driverBaseBloc = BlocProvider.getBloc<DriverBaseBloc>();
  StreamSubscription<Position> _initialStreamPosition;

  /*start driver*/
  Future start() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    /*get the address name based on lat and log*/
    var address = await _googleService.getAddressByCoordinates(
        position.latitude.toString(), position.longitude.toString());

    final MapProvider mapProvider = MapProvider(
        driverCurrentAddress: address,
        driverPositionLatLng: LatLng(position.latitude, position.longitude));

    await _addCartMap(mapProvider, 120);
    Future.delayed(const Duration(milliseconds: 500), () {
      startMonitoringDriverMap();
    });
  }

  void closeStreamFlow() {
    if (_initialStreamPosition != null) _initialStreamPosition?.cancel();
  }

  /*-responsible for obtaining any change in the driver's location and updates the map*/
  Future<void> startMonitoringDriverMap() async {
    try {
      Geolocator _geoLocator = Geolocator();

      if (_initialStreamPosition != null) _initialStreamPosition?.cancel();

      var locationOptions =
          LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);

      MapProvider mapProvider = await _driverBaseBloc.mapProviderFlux.first;

      // semaforo translation unknown
      bool semaforo = true;

      _initialStreamPosition = _geoLocator
          .getPositionStream(locationOptions)
          .listen((Position position) {
        if (position != null && semaforo) {
          semaforo = false;
          Future.delayed(const Duration(milliseconds: 100), () async {
            /*get the address name based on lat and log*/
            var address = await _googleService.getAddressByCoordinates(
                position.latitude.toString(), position.longitude.toString());

            mapProvider.driverPositionLatLng =
                LatLng(position.latitude, position.longitude);
            mapProvider.driverCurrentAddress = address;
            print("Initial monitoring of the driver's location.");

            _addCartMap(mapProvider, 120).then((r) {
              /*waiting to finish to set the cart on the map*/
              semaforo = true;
            });
          });
        }
      });
    } on Exception catch (ex) {
      print(
          'Error method startMonitoringDriverMap, class StepDriverStartBiz -  $ex');
    }
  }

  /*define cart on map*/
  Future _addCartMap(MapProvider provider, int iconSize) async {
    try {
      provider.markers = Set<Marker>();

      final Uint8List markerIcon =
          await getBytesFromAsset('assets/images/car/taximarker.png', iconSize);

      //_geolocator.bearingBetween(startLatitude, startLongitude, endLatitude, endLongitude)

      /*add cart*/
      provider.markers.add(Marker(
          markerId: MarkerId(provider.driverCurrentAddress.toString()),
          position: provider.driverPositionLatLng,
          flat: true,
          infoWindow: InfoWindow(
              title: provider.driverCurrentAddress, snippet: "This One!"),
          icon: BitmapDescriptor.fromBytes(markerIcon)));

      _driverBaseBloc.mapProviderEvent.add(provider);
    } on Exception catch (ex) {
      print(
          'Error method _addCartMap, class StepStartDriverBiz -  $ex');
    }
  }

/*end method*/

  /*assists in adjusting the image size*/
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    try {
      ByteData data = await rootBundle.load(path);
      ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
          targetWidth: width);
      ui.FrameInfo fi = await codec.getNextFrame();
      return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
          .buffer
          .asUint8List();
    } on Exception catch (ex) {
      print(
          'Error method getBytesFromAsset, class StepStartDriverBiz -  $ex');
    }
  }

/*end method*/

}
