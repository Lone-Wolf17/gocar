import 'dart:convert';

import 'package:gocar/src/entity/entities.dart';
import 'package:gocar/src/infra/admin/admin.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;


class GoogleService {

  Future<String> getRouteCoordinates(LatLng l1, LatLng l2) async {
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&destination=${l2.latitude},${l2.longitude}&key=$keyGoogle";
    http.Response response = await http.get(url);
    Map values = jsonDecode(response.body);
    return values["routes"][0]["overview_polyline"]["points"];
  }

  Future<String> getAddressByCoordinates(String latitude,
      String longitude) async {
    String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$keyGoogle";
    http.Response response = await http.get(url);
    Map values = jsonDecode(response.body);

    return values["results"][0]["formatted_address"];
  }

  Future<List<Local>> searchPlace(Filter filter) async {
    String url =
        "https://maps.googleapis.com/maps/api/place/textsearch/json?key=$keyGoogle&language=pt&query=" +
            Uri.encodeQueryComponent(filter.keyWord);

    var res = await http.get(url);
    if (res.statusCode == 200) {
      return Local.fromJson(json.decode(res.body), filter.reference);
    } else {
      return List();
    }
  }

  Future<DistanceTime> getDistance(LatLng l1, LatLng l2) async {
    String url = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=${l1
        .latitude},${l1.longitude}&destinations=${l2.latitude},${l2
        .longitude}&mode=driving&language=pt-BR&key=$keyGoogle";

    http.Response response = await http.get(url);
    Map values = jsonDecode(response.body);
    String distance = values["rows"][0]["elements"][0]["distance"]["text"];
    String distanceKm = (values["rows"][0]["elements"][0]["distance"]["value"])
        .toString();
    String time = values["rows"][0]["elements"][0]["duration"]["text"];
    double value = (((double.parse(distanceKm)) * valueKm) / 1000)
        .roundToDouble();
    return DistanceTime(distance: distance, time: time, value: value);
  }

}
