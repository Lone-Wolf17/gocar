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
import 'package:gocar/src/provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../biz.dart';

class StepDriverTripSearchBiz {
  TripService _tripService = TripService();
  DriveHomeBloc _driverHomeBloc = BlocProvider.getBloc<DriveHomeBloc>();
  DriverAuthBloc _authBloc = BlocProvider.getBloc<DriverAuthBloc>();
  DriverBaseBloc _driverBaseBloc = BlocProvider.getBloc<DriverBaseBloc>();
  GoogleService _googleService = GoogleService();
  Geolocator _geoLocator = Geolocator();
  StreamSubscription<QuerySnapshot> _streamAllOpenTrip;
  StreamSubscription<QuerySnapshot> _streamSpecificOpenTrip;
  StreamSubscription<Position> _streamPosition;
  StepStartDriverBiz _stepStartDriverBiz = StepStartDriverBiz();
  bool indicatesProcessStatus = true;
  StreamSubscription<Position> _streamInitialPosition;

  static StepDriverTripSearchBiz _instance;

  factory StepDriverTripSearchBiz() {
    _instance ??= StepDriverTripSearchBiz._internalConstructor();
    return _instance;
  }

  StepDriverTripSearchBiz._internalConstructor();

  /*start monitoring firebase*/
  Future<void> start() async {
    /*activates monitoring of the driver's current location*/
    await startMonitoringActualLocation();

    /*driver*/
    Driver driver = await _authBloc.userInfoFlux.first;

    /*stream relates a specific trip*/
    var stream = await _tripService.startOpenTripSearch();

    _streamAllOpenTrip = stream.listen((data) {
      data.documentChanges.forEach((change) async {
        /*cancels search for trip because it already has a trip on set*/
        _streamAllOpenTrip?.cancel();

        print(
            'Open search fetch stream is active based on radio parameter series ....');
        Trip trip = Trip.fromSnapshotJson(change.document);
        indicatesProcessStatus = true;
        await streamMonitoringSpecificTrip(trip, driver);
      });
    });
  }

  Future<void> streamMonitoringSpecificTrip(Trip trip, Driver driver) async {
    /*ends monitoring of current driver location*/
    closeDriverLocalPositionStreams();

    /*adds trip in the stream for later use*/
    _driverBaseBloc.tripEvent.add(trip);

    /*add driver location based on user*/
    addsPassengerDriverInitialLocation(trip);

    /*obtain flow to monitor specific trip*/
    var streamSpecificTrip = await _tripService.getTripById(trip.id);

    _streamSpecificOpenTrip = streamSpecificTrip.listen((data) {
      data.documentChanges.forEach((changeResult) async {
        var specificTrip = Trip.fromSnapshotJson(changeResult.document);
        print('Specific search fetch stream is active');

        if (specificTrip.status == TripStatus.DriverOnTheWay) {
          /*kills the stream avoid stalling processes*/
          //streamSpecificAbertaViagem?.cancel();

          /*starts the travel process by updating the travel variable */
          if (driver.id == specificTrip.driverEntity.id) {
            if (!indicatesProcessStatus) return;

            /*updates firebase with the location of the driver and their respective location*/
            await viewDriverPassengerLocation(
                specificTrip, TripStatus.DriverOnTheWay);
            /*refreshes the screen*/
            _driverHomeBloc.stepDriverEvent.add(StepDriverHome.TravelAccepted);

            /*updates the flow of the trip with new information*/
            _driverBaseBloc.tripEvent.add(specificTrip);

            indicatesProcessStatus = false;
          } else {
            /*send notification that the trip was accepted by another driver and start the trip search process again */
            closesFlow();
            _driverHomeBloc.stepDriverEvent
                .add(StepDriverHome.LookingForTravel);
            start();
          }
          /*closes the modal because the trip has started*/
        } else if (specificTrip.status == TripStatus.Canceled) {
          /*kills the stream avoid stalling processes*/
          closesFlow();
          _driverHomeBloc.stepDriverEvent.add(StepDriverHome.LookingForTravel);
          start();
        }
      });
    });
  }

  /*fix solve problem when I was looking for the trip the monitoring stopped*/
  Future<void> startMonitoringActualLocation() async {
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

  void closeStreamsFlow() {
    if (_streamPosition != null) _streamPosition?.cancel();
    if (_streamAllOpenTrip != null) _streamAllOpenTrip?.cancel();
    if (_streamSpecificOpenTrip != null) _streamSpecificOpenTrip?.cancel();

    closeDriverLocalPositionStreams();
  }

  void closesFlow() {
    closeStreamsFlow();
    _stepStartDriverBiz.closeStreamFlow();
    /*calls method of the previous process so that the current location and the displacement in real time are added to the map*/
    _stepStartDriverBiz.start();
  }

  /*adds starting point to pilot driver position*/
  Future<void> addsPassengerDriverInitialLocation(Trip trip) async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    /*get the address name based on lat and log*/
    var address = await _googleService.getAddressByCoordinates(
        position.latitude.toString(), position.longitude.toString());

    final MapProvider mapProvider = MapProvider(
        driverCurrentAddress: address,
        originAddress: trip.originAddress,
        originLatLng: LatLng(trip.originLatitude, trip.originLongitude),
        zoom: 15,
        driverPositionLatLng: LatLng(position.latitude, position.longitude));

    await routeDriverToUser(mapProvider);
    /*starts flow asking you to show the acceptance mode*/
    _driverHomeBloc.stepDriverEvent.add(StepDriverHome.TravelFound);
    /*adds monitoring */
    Future.delayed(const Duration(milliseconds: 500), () async {
      await viewDriverPassengerLocation(trip, TripStatus.DriverNotified);
    });
  }

  Future<void> viewDriverPassengerLocation(
      Trip trip, TripStatus tripStatus) async {
    var locationOptions =
        LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);

    /*Translation of semaforo unknown, could be traffic light */
    bool semaforo = true;

    if (_streamPosition != null) _streamPosition.cancel();

    _streamPosition = _geoLocator
        .getPositionStream(locationOptions)
        .listen((Position position) async {
      if (position != null && semaforo) {
        semaforo = false;
        Future.delayed(const Duration(milliseconds: 1800), () async {
          var address = await _googleService.getAddressByCoordinates(
              position.latitude.toString(), position.longitude.toString());

          if (tripStatus == TripStatus.DriverOnTheWay) {
            /*obtain the current trip flow */
            trip.driverPositionLatitude = position.latitude;
            trip.driverPositionLongitude = position.longitude;
            trip.driverCurrentAddress = address;
            /*saves the driver's current location so that the passenger can have real-time updates*/
            await _tripService.save(trip);
          }

          /*arrow with current driver position at destination*/
          MapProvider mapProvider = MapProvider(
              originAddress: trip.originAddress,
              driverCurrentAddress: address,
              driverPositionLatLng:
                  LatLng(position.latitude, position.longitude),
              originLatLng: LatLng(trip.originLatitude, trip.originLongitude),
              zoom: 15);

          await routeDriverToUser(mapProvider);

          semaforo = true;
        });
      }
    });
  }

  /*starts the process of generating line on the map*/
  Future routeDriverToUser(MapProvider provider) async {
    /*create points of origin and destination, if it was started it generates the point in real time*/
    await _addMarkerRealTimeTripDriverToPassenger(provider, 120);

    String route = await _googleService.getRouteCoordinates(
        provider.driverPositionLatLng, provider.originLatLng);
    /*get list of origin-destination routes*/
    await createRoute(route, provider);
    _driverBaseBloc.mapProviderEvent.add(provider);
  }

/*end line map*/

  /*draws driver points to meet passenger*/
  Future _addMarkerRealTimeTripDriverToPassenger(
      MapProvider provider, int iconSize) async {
    provider.markers = Set<Marker>();

    final Uint8List markerIcon =
        await getBytesFromAsset('assets/images/car/taximarker.png', iconSize);

    /*driver spot points*/
    provider.markers.add(Marker(
        markerId: MarkerId(provider.driverCurrentAddress.toString()),
        position: provider.driverPositionLatLng,
        infoWindow: InfoWindow(
            title: provider.driverCurrentAddress, snippet: "Driver is Here!"),
        icon: BitmapDescriptor.fromBytes(markerIcon)));

    /*passenger spot point*/
    provider.markers.add(Marker(
        markerId: MarkerId(provider.originAddress.toString()),
        position: provider.originLatLng,
        infoWindow: InfoWindow(
            title: provider.originAddress, snippet: "Passenger is Here!"),
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)));
  }

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
          'Error method getBytesFromAsset, class StepTripDriverSearchBiz -  $ex');
    }
  }

/*end method*/

  /*creates line with origin and destination route*/
  Future createRoute(String encodedPoly, MapProvider provider) async {
    provider.polyLines = Set<Polyline>();
    provider.polyLines.add(Polyline(
        polylineId: PolylineId(provider.originAddress.toString()),
        width: 6,
        points:
            HelpService.convertToLatLng(HelpService.decodePoly(encodedPoly)),
        color: Colors.blueAccent));
  }

/*end create line*/

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
      print('Error method _addCartMap, class StepTripDriverSearchBiz -  $ex');
    }
  }

  /*- responsible for obtaining any change in the driver's location and updates the map*/
  Future<void> startMonitoringDriverMap() async {
    try {
      Geolocator _geoLocator = Geolocator();

      if (_streamInitialPosition != null) _streamInitialPosition?.cancel();

      var locationOptions =
          LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);

      MapProvider mapProvider = await _driverBaseBloc.mapProviderFlux.first;
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

            mapProvider.driverPositionLatLng =
                LatLng(position.latitude, position.longitude);
            mapProvider.driverCurrentAddress = address;
            print(
                "Monitoring the driver's current location from the driver's location.");

            _addCartMap(mapProvider, 120).then((r) {
              /*waiting to finish to set the cart on the map*/
              semaforo = true;
            });
          });
        }
      });
    } on Exception catch (ex) {
      print(
          'Error method startMonitoringDriverMap, class StepTripDriverSearchBiz -  $ex');
    }
  }

  void closeDriverLocalPositionStreams() {
    if (_streamInitialPosition != null) _streamInitialPosition?.cancel();
  }
}
