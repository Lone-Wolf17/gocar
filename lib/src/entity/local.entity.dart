import 'entities.dart';

class Local {
  String name;
  String address;
  double latitude;
  double longitude;
  LocalReference reference;

  Local(
      {this.name, this.address, this.latitude, this.longitude, this.reference});

  static List<Local> fromJson(
      Map<String, dynamic> json, LocalReference reference) {
    List<Local> resultList = List();

    var results = json['results'] as List;
    for (var item in results) {
      var itemList = Local(
          name: item['name'],
          address: item['formatted_address'],
          latitude: item['geometry']['location']['lat'],
          longitude: item['geometry']['location']['lng'],
          reference: reference);
      resultList.add(itemList);
    }
    return resultList;
  }

  toJson() {
    return {
      "name": this.name,
      "address": this.address,
      "latitude": this.latitude,
      "longitude": this.longitude,
    };
  }

  Local.fromMap(Map<dynamic, dynamic> data)
      : name = data["name"],
        address = data["address"],
        latitude = data["latitude"],
        longitude = data["longitude"];
}

class DistanceTime {
  String distance;
  String time;
  double value;

  DistanceTime({this.distance, this.time, this.value});
}
