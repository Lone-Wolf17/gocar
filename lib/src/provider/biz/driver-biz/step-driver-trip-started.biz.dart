import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:gocar/src/infra/help/help.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../provider.dart';

class StepDriverTripStartedBiz {
  DriverBaseBloc _driverBaseBloc = BlocProvider.getBloc<DriverBaseBloc>();
  TripService _tripService = TripService();
  StreamSubscription<QuerySnapshot> _streamSpecificTrip;
  DriveHomeBloc _driverHomeBloc = BlocProvider.getBloc<DriveHomeBloc>();
  StreamSubscription<Position> _streamPosition;
  Geolocator _geoLocator = Geolocator();
  GoogleService _googleService = GoogleService();
  DriveHomeBloc _homeBloc = BlocProvider.getBloc<DriveHomeBloc>();

  static StepDriverTripStartedBiz _instance;

  factory StepDriverTripStartedBiz() {
    _instance ??= StepDriverTripStartedBiz._internalConstructor();
    return _instance;
  }

  StepDriverTripStartedBiz._internalConstructor();

  /*start monitoring firebase*/
  Future<void> start() async {
    Trip trip = await _driverBaseBloc.tripFlux.first;

    await monitoringOriginDestination(trip);
    /*obtain flow to monitor specific trip*/
    var streamSpecificTrip = await _tripService.getTripById(trip.id);

    /*calls the method to assemble the layout allowing the user to finish the trip*/
    _homeBloc.stepDriverEvent.add(StepDriverHome.EndTrip);

    _streamSpecificTrip = streamSpecificTrip.listen((data) {
      data.documentChanges.forEach((changeResult) async {
        var specificTrip = Trip.fromSnapshotJson(changeResult.document);
        print('Trip stream started Specifies is active');

        if (specificTrip.status == TripStatus.Finished) {
          /*shut down flow */
          closeStreamsFlow();
        }
      });
    });
  }

  /*monitoring from source to destination*/
  Future<void> monitoringOriginDestination(Trip trip) async {
    var locationOptions =
        LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);

    bool semaforo = true;

    if (_streamPosition != null) _streamPosition.cancel();

    _streamPosition = _geoLocator
        .getPositionStream(locationOptions)
        .listen((Position position) async {
      if (position != null && semaforo) {
        semaforo = false;
        /*the home two seconds saves the current location*/
        Future.delayed(const Duration(milliseconds: 2000), () async {
          var address = await _googleService.getAddressByCoordinates(
              position.latitude.toString(), position.longitude.toString());

          /*obtain the current flow trip*/
          trip.driverPositionLatitude = position.latitude;
          trip.driverPositionLongitude = position.longitude;
          trip.originLongitude = position.longitude;
          trip.originLatitude = position.latitude;
          trip.originAddress = address;
          trip.originMainAddress = address;
          trip.driverCurrentAddress = address;

          /*saves the driver's current location so that the passenger can have real-time updates*/
          await _tripService.save(trip);

          /*arrow with current driver position at destination*/
          MapProvider mapProvider = MapProvider(
              originAddress: address,
              driverCurrentAddress: address,
              destinationAddress: trip.destinationAddress,
              destinationLatLng:
                  LatLng(trip.destinationLatitude, trip.destinationLongitude),
              driverPositionLatLng:
                  LatLng(position.latitude, position.longitude),
              originLatLng: LatLng(position.latitude, position.longitude),
              zoom: 15);

          await routeOriginDestination(mapProvider);

          semaforo = true;
        });
      }
    });
  }

  /*starts the process of generating line on the map*/
  Future routeOriginDestination(MapProvider provider) async {
    /*create points of origin and destination, if it was started it generates the point in real time*/
    await _addMarkerRealTimeOriginDestination(provider, 100);

    String route = await _googleService.getRouteCoordinates(
        provider.originLatLng, provider.destinationLatLng);
    /*get list of origin-destination routes*/
    await createRoute(route, provider);
    _driverBaseBloc.mapProviderEvent.add(provider);
  }

  /*creates line with origin and destination route*/
  Future createRoute(String encodedPoly, MapProvider provider) async {
    provider.polyLines = Set<Polyline>();
    provider.polyLines.add(Polyline(
        polylineId: PolylineId(provider.originAddress.toString()),
        width: 6,
        points:
            HelpService.convertToLatLng(HelpService.decodePoly(encodedPoly)),
        color: Colors.black));
  }

  /*draws driver points to meet passenger*/
  Future _addMarkerRealTimeOriginDestination(
      MapProvider provider, int iconSize) async {
    provider.markers = Set<Marker>();

    final Uint8List markerIcon =
        await getBytesFromAsset('assets/images/car/taximarker.png', iconSize);

    /*car rotation on the map*/
    var rotation = await _geoLocator.bearingBetween(
        provider.originLatLng.latitude,
        provider.originLatLng.longitude,
        provider.destinationLatLng.latitude,
        provider.destinationLatLng.longitude);

    /*driver spot points*/
    provider.markers.add(Marker(
        markerId: MarkerId(provider.originAddress.toString()),
        position: provider.originLatLng,
        // rotation: rotation ,
        flat: true,
        infoWindow:
            InfoWindow(title: provider.originAddress, snippet: "We're here!"),
        icon: BitmapDescriptor.fromBytes(markerIcon)));

    /*passenger spot point*/
    provider.markers.add(Marker(
        markerId: MarkerId(provider.destinationAddress.toString()),
        position: provider.destinationLatLng,
        infoWindow: InfoWindow(
            title: provider.destinationAddress,
            snippet: "We have arrived at the Destination!!"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)));
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

  void closeStreamsFlow() {
    if (_streamSpecificTrip != null) _streamSpecificTrip?.cancel();

    if (_streamPosition != null) _streamPosition?.cancel();
  }
}
