import 'package:google_maps_flutter/google_maps_flutter.dart';

class PassengerMapProvider {
  String originAddress;
  String destinationAddress;
  String driverCurrentAddress;
  double zoom;
  LatLng originLatLng;
  LatLng destinationLatLng;
  LatLng driverPositionLatLng;
  Set<Marker> markers;
  Set<Circle> circleMap;
  Set<Polyline> polyLines;

  PassengerMapProvider(
      {this.originAddress,
      this.destinationAddress,
      this.zoom = 15.0,
      this.originLatLng,
      this.destinationLatLng,
      this.driverCurrentAddress,
      this.driverPositionLatLng,
      this.markers,
      this.circleMap,
      this.polyLines});
}
