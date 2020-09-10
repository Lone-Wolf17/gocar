import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:gocar/src/infra/help/help.dart';
import 'package:gocar/src/provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StepPassengerDriverSearch {
  static StepPassengerDriverSearch _instance;

  factory StepPassengerDriverSearch() {
    _instance ??= StepPassengerDriverSearch._internalConstructor();
    return _instance;
  }

  StepPassengerDriverSearch._internalConstructor();

  PassengerAuthBloc _passengerAuthBloc =
      BlocProvider.getBloc<PassengerAuthBloc>();
  BasePassengerBloc _passengerBaseBloc =
      BlocProvider.getBloc<BasePassengerBloc>();
  TripService _tripService = TripService();
  StreamSubscription<QuerySnapshot> _streamAllOpenTrip;
  PassengerHomeBloc _homeBloc = BlocProvider.getBloc<PassengerHomeBloc>();
  GoogleService _googleService = GoogleService();

  Future start() async {
    Passenger passenger = await _passengerAuthBloc.userInfoFlux.first;
    Trip trip = await _passengerBaseBloc.tripFlow.first;

    trip.passengerEntity = passenger;

    Trip tripResult =
        await _tripService.getOpenTripByUser(passenger.id, TripStatus.Open);

    /*get open trip id*/
    if (tripResult != null) trip.id = tripResult.id;

    bool processStatus = false;
    bool semaforoStatus = false;
    bool tripStartedProcessStatus = false;

    var stream = await _tripService.startTrip(trip);

    _streamAllOpenTrip = stream.listen((data) {
      data.documentChanges.forEach((change) async {
        if (!semaforoStatus) {
          semaforoStatus = true;

          var resultTrip = Trip.fromSnapshotJson(change.document);
          _passengerBaseBloc.tripEvent.add(resultTrip);

          if (resultTrip.status == TripStatus.DriverOnTheWay) {
            if (!processStatus) {
              _passengerBaseBloc.tripEvent.add(resultTrip);
              _homeBloc.stepProcessEvent.add(StepPassengerHome.DriverAccepted);
              processStatus = true;
            }

            if (resultTrip.driverCurrentAddress != null)
              await routeDriverToUser(resultTrip);

            semaforoStatus = false;
          } else if (resultTrip.status == TripStatus.Started) {
            if (resultTrip.driverCurrentAddress != null) {
              await tripRouteStarted(resultTrip);

              if (!tripStartedProcessStatus) {
                _homeBloc.stepProcessEvent
                    .add(StepPassengerHome.TripInProgress);
                tripStartedProcessStatus = true;
              }
            }
            semaforoStatus = false;
          } else if (resultTrip.status == TripStatus.Canceled) {
            _homeBloc.stepProcessEvent.add(StepPassengerHome.Start);
            _passengerBaseBloc.tripEvent.add(Trip());
            closeStreamsFlow();
            await _passengerBaseBloc.orchestration();
          } else if (resultTrip.status == TripStatus.Open) {
            semaforoStatus = false;
          } else if (resultTrip.status == TripStatus.Finished) {
            _homeBloc.stepProcessEvent.add(StepPassengerHome.EndTrip);
            await makePayment();
            _passengerBaseBloc.tripEvent.add(Trip());
            closeStreamsFlow();
          }
        }
      });
    });
  }

  Future makePayment() async {
    BasePassengerBloc _baseBloc = BlocProvider.getBloc<BasePassengerBloc>();
    TripService _tripService = new TripService();
    var trip = await _baseBloc.tripFlow.first;

    // CieloService cieloService = CieloService();
    // Sale sale = Sale(
    //     merchantOrderId: "123", // unique id of your sale
    //     customer: Customer(
    //         //user data object
    //         name: ""),
    //     payment: Payment(
    //         // object for payment
    //         type: TypePayment.creditCard,
    //         //type of payment
    //         amount: trip.carType == CarType.Pop
    //             ? (trip.valuePop * 1000).toInt()
    //             : (trip.valueTop * 1000).toInt(),
    //         // purchase amount in cents
    //         installments: 1,
    //         //number of installments
    //         softDescriptor: "",
    //         //description that will appear on the user's statement. Only 15 characters
    //         creditCard: CreditCard(
    //           //Credit Card object
    //           cardNumber: "",
    //           //card number
    //           holder: "",
    //           //username printed on the card
    //           expirationDate: "",
    //           // expiration date
    //           securityCode: "",
    //           // security code
    //           brand: "", // brand
    //         )));
    // var result = await cieloService.ExecutePayment(sale);
    // trip.paymentId = result.payment.paymentId;
    // await _tripService.save(trip);
  }

  Future tripRouteStarted(Trip viagem) async {
    MapProvider mapProvider = MapProvider(
        destinationAddress: viagem.destinationAddress,
        driverCurrentAddress: viagem.driverCurrentAddress,
        originLatLng: LatLng(
            viagem.driverPositionLatitude, viagem.driverPositionLatitude),
        driverPositionLatLng: LatLng(
            viagem.driverPositionLatitude, viagem.driverPositionLongitude),
        destinationLatLng:
            LatLng(viagem.destinationLatitude, viagem.destinationLongitude),
        zoom: 15);

    /*create points of origin and destination, if it was started it generates the point in real time*/
    await _addMarkerRealTimeTripStarted(mapProvider, 120);

    String route = await _googleService.getRouteCoordinates(
        mapProvider.driverPositionLatLng, mapProvider.destinationLatLng);

    /*get list of origin-destination routes*/
    await createRouteTripStarted(route, mapProvider);
    _passengerBaseBloc.mapProviderEvent.add(mapProvider);
  }

  /*starts the process of generating line on the map*/
  Future routeDriverToUser(Trip trip) async {
    MapProvider mapProvider = MapProvider(
        originAddress: trip.originAddress,
        driverCurrentAddress: trip.driverCurrentAddress,
        driverPositionLatLng:
            LatLng(trip.driverPositionLatitude, trip.driverPositionLongitude),
        originLatLng: LatLng(trip.originLatitude, trip.originLongitude),
        zoom: 15);

    /*create points of origin and destination, if it was started it generates the point in real time*/
    await _addMarkerRealTimeTripDriverToPassenger(mapProvider, 120);

    String route = await _googleService.getRouteCoordinates(
        mapProvider.driverPositionLatLng, mapProvider.originLatLng);

    /*get list of origin-destination routes*/
    await createRoute(route, mapProvider);
    _passengerBaseBloc.mapProviderEvent.add(mapProvider);
  }

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

  Future createRouteTripStarted(
      String encodedPoly, MapProvider provider) async {
    provider.polyLines = Set<Polyline>();
    provider.polyLines.add(Polyline(
        polylineId: PolylineId(provider.driverCurrentAddress.toString()),
        width: 6,
        points:
            HelpService.convertToLatLng(HelpService.decodePoly(encodedPoly)),
        color: Colors.blueAccent));
  }

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
        infoWindow:
            InfoWindow(title: provider.originAddress, snippet: "We're here!"),
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)));
  }

  /*draws driver points to meet passenger*/
  Future _addMarkerRealTimeTripStarted(
      MapProvider provider, int iconSize) async {
    provider.markers = Set<Marker>();

    final Uint8List markerIcon =
        await getBytesFromAsset('assets/images/car/taximarker.png', iconSize);

    /*driver spot points*/
    provider.markers.add(Marker(
        markerId: MarkerId(provider.driverCurrentAddress.toString()),
        position: provider.driverPositionLatLng,
        infoWindow: InfoWindow(
            title: provider.driverCurrentAddress, snippet: "We're here!"),
        icon: BitmapDescriptor.fromBytes(markerIcon)));

    /*passenger spot point*/
    provider.markers.add(Marker(
        markerId: MarkerId(provider.destinationAddress.toString()),
        position: provider.destinationLatLng,
        infoWindow: InfoWindow(
            title: provider.destinationAddress, snippet: "Let's go here!"),
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)));
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
    if (_streamAllOpenTrip != null) _streamAllOpenTrip?.cancel();
  }
}
