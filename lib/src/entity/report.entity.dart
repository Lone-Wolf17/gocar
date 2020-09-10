import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gocar/src/infra/infra.dart';

class Report {
  String id;
  String code;
  String driverId;
  double gasoline;
  double food;
  double carMaintenance;
  DateTime createdOn;
  DateTime modifiedOn;

  Report({
    this.id,
    this.code = '',
    this.gasoline,
    this.driverId,
    this.food,
    this.carMaintenance,
    this.createdOn,
    this.modifiedOn,
  });

  Report.fromSnapshotJson(DocumentSnapshot snapshot)
      : this.id = snapshot.documentID,
        this.code = snapshot.data["code"],
        this.gasoline = snapshot.data["gasoline"].toDouble(),
        this.driverId = snapshot.data["driverId"],
        this.food = snapshot.data["food"].toDouble(),
        this.carMaintenance = snapshot.data["carMaintenance"].toDouble(),
        this.modifiedOn = DateTime.parse(snapshot.data['modifiedOn']),
        this.createdOn = DateTime.parse(snapshot.data['createdOn']);

  static Map<String, dynamic> stringToMap(String s) {
    Map<String, dynamic> map = json.decode(s);
    return map;
  }

  toJson() {
    return {
      "id": this.id,
      "code": this.code == '' ? HelpService.generateCode(12) : this.code,
      "gasoline": this.gasoline,
      "food": this.food,
      "driverId": this.driverId,
      "carMaintenance": this.carMaintenance,
      "modifiedOn": this.modifiedOn == null
          ? DateTime.now().toString()
          : this.modifiedOn.toString(),
      "createdOn": this.createdOn == null
          ? DateTime.now().toString()
          : this.createdOn.toString(),
    };
  }
}
