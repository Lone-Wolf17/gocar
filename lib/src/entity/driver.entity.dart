import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gocar/src/infra/infra.dart';

import 'entities.dart';

class Driver {
  String id;
  String code;
  String name;
  String email;
  MyImage image;
  Vehicle car;
  DateTime createdOn;
  DateTime modifiedOn;
  bool status;

  Driver(
      {this.id,
      this.code = '',
      this.name,
      this.image,
      this.email,
      this.car,
      this.modifiedOn,
      this.createdOn,
      this.status});

  Driver.fromSnapshot(DocumentSnapshot snapshot)
      : this.id = snapshot.documentID,
        this.code = snapshot.data["code"],
        this.name = snapshot.data["name"] == null ? '' : snapshot.data["name"],
        this.email = snapshot.data["email"],
        this.image = MyImage.fromSnapshotJson(snapshot),
        this.car = Vehicle.fromJson(snapshot.data["car"]),
        this.modifiedOn =
            DateTime.parse(snapshot.data['modifiedOn'].toString()),
        this.createdOn = DateTime.parse(snapshot.data['createdOn']),
        this.status = snapshot.data["status"] as bool;

  Driver.fromJson(Map<dynamic, dynamic> map)
      : code = map["code"],
        this.id = map["id"],
        this.name = map["name"] == null ? '' : map["name"],
        this.email = map["email"] == null ? '' : map["email"],
        this.car = Vehicle.fromJson(map["car"]),
        this.image = MyImage.fromMap(map["image"]),
        this.modifiedOn = DateTime.parse(map['modifiedOn']),
        this.createdOn = DateTime.parse(map['createdOn']),
        this.status = map["status"] as bool;

  static Map<String, dynamic> stringToMap(String s) {
    Map<String, dynamic> map = json.decode(s);
    return map;
  }

  toJson() {
    return {
      "id": this.id,
      "code": this.code == '' ? HelpService.generateCode(12) : this.code,
      "name": this.name == null ? '' : this.name,
      "email": this.email == null ? '' : this.email,
      "image": this.image == null ? MyImage().toJson() : this.image.toJson(),
      "car": this.car == null ? Vehicle().toJson() : this.car.toJson(),
      "modifiedOn": this.modifiedOn == null
          ? DateTime.now().toString()
          : this.modifiedOn.toString(),
      "createdOn": this.createdOn == null
          ? DateTime.now().toString()
          : this.createdOn.toString(),
      "status": this.status == null ? true : this.status,
    };
  }
}
