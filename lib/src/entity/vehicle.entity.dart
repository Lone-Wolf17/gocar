import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gocar/src/infra/infra.dart';

import 'entities.dart';


class Vehicle {
  String id;
  String code;
  String brand;
  String model;
  String year;
  String board;
  String color;
  MyImage image;
  DateTime createdOn;
  DateTime modifiedOn;
  bool status;
  CarType type;

  Vehicle(
      {this.id,
      this.code = '',
      this.brand,
      this.model,
      this.year,
      this.board,
      this.color,
      this.image,
      this.type,
      this.modifiedOn,
      this.createdOn,
      this.status});

  Vehicle.fromSnapshotJson(DocumentSnapshot snapshot)
      : this.id = snapshot.documentID,
        this.code = snapshot.data["code"],
        this.brand = snapshot.data["brand"],
        this.model = snapshot.data["model"],
        this.year = snapshot.data["year"],
        this.color = snapshot.data["color"],
        this.board = snapshot.data["board"],
        this.type = snapshot.data['type'] == null
            ? snapshot.data['type']
            : CarType.values[snapshot.data['type']],
        this.image = MyImage.fromSnapshotJson(snapshot),
        this.modifiedOn =
            DateTime.parse(snapshot.data['modifiedOn'].toString()),
        this.createdOn = DateTime.parse(snapshot.data['createdOn']),
        this.status = snapshot.data["status"] as bool;

  Vehicle.fromJson(Map<dynamic, dynamic> map)
      : code = map["code"],
        this.id = map["id"],
        this.brand = map["brand"],
        this.model = map["model"],
        this.board = map["board"],
        this.year = map["year"],
        this.color = map["color"],
        this.type = CarType.values[map['type']],
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
      "brand": this.brand,
      "model": this.model,
      "year": this.year == null ? '' : this.year,
      "color": this.color == null ? '' : this.color,
      "board": this.board,
      "image": this.image == null ? MyImage().toJson() : this.image.toJson(),
      "modifiedOn": this.modifiedOn == null
          ? DateTime.now().toString()
          : this.modifiedOn.toString(),
      "createdOn": this.createdOn == null
          ? DateTime.now().toString()
          : this.createdOn.toString(),
      "status": this.status == null ? true : this.status,
      "type": this.type == null ? 0 : this.type.index,
    };
  }
}
