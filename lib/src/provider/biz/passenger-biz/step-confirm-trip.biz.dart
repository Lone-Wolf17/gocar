import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:gocar/src/infra/help/help.dart';
import 'package:gocar/src/provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StepConfirmTripBiz {
  static StepConfirmTripBiz _instance;

  factory StepConfirmTripBiz() {
    _instance ??= StepConfirmTripBiz._internalConstructor();
    return _instance;
  }

  StepConfirmTripBiz._internalConstructor();

  BasePassengerBloc _passengerBaseBloc =
      BlocProvider.getBloc<BasePassengerBloc>();
  GoogleService _googleService = GoogleService();

  Future start() async {
    BasePassengerBloc _baseBloc = BlocProvider.getBloc<BasePassengerBloc>();
    var provider = await _baseBloc.mapProviderFlux.first;

    /*create points of origin and destination, if it was started it generates the point in real time*/
    /*if (tripStatus == TripStatus.Started) {
      await _addMarkerRealTimeTrip(provider, 50);
    } else {*/
    await _addMarkerProcurarMotorista(provider);
    /*}*/

    String route = await _googleService.getRouteCoordinates(
        provider.originLatLng, provider.destinationLatLng);
    /*get list of origin-destination routes*/
    await createRoute(route, provider);
  }

  /*assists in adjusting the image size*/
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  Future _addMarkerProcurarMotorista(MapProvider provider) async {
    provider.markers = Set<Marker>();

    /*starting point*/
    provider.markers.add(Marker(
        markerId: MarkerId(provider.originAddress.toString()),
        position: provider.originLatLng,
        infoWindow: InfoWindow(
            title: provider.originAddress, snippet: "We're here!"),
        icon:
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)));

    /*destination point*/
    provider.markers.add(Marker(
        markerId: MarkerId(provider.destinationAddress.toString()),
        position: provider.destinationLatLng,
        infoWindow:
        InfoWindow(
            title: provider.destinationAddress, snippet: "Let's go here!"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)));
  }

  /*creates line with origin and destination route*/
  Future createRoute(String encondedPoly, MapProvider provider) async {
    provider.polyLines = Set<Polyline>();
    provider.polyLines.add(Polyline(
        polylineId: PolylineId(provider.originAddress.toString()),
        width: 6,
        points:
        HelpService.convertToLatLng(HelpService.decodePoly(encondedPoly)),
        color: Colors.blueAccent));


    _passengerBaseBloc.mapProviderEvent.add(provider);
  }

/*end create line*/
}
