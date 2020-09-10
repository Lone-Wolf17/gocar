import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gocar/src/infra/infra.dart';

import 'entities.dart';

class Passenger {
  String id;
  String code;
  String name;
  String email;
  int age;
  MyImage image;
  DateTime createdOn;
  DateTime modifiedOn;
  bool status;
  Local home;
  Local work;

  Passenger(
      {this.id,
      this.code = '',
      this.name,
      this.age,
      this.email,
      this.image,
      this.modifiedOn,
      this.home,
      this.work,
      this.createdOn,
      this.status = true});

  Passenger.fromSnapshot(DocumentSnapshot snapshot)
      : this.id = snapshot.documentID,
        this.code = snapshot.data["code"],
        this.name =
            snapshot.data["name"] == null ? '---' : snapshot.data["name"],
        this.age = snapshot.data["age"],
        this.email = snapshot.data["email"],
        this.image = MyImage.fromMap(snapshot.data["image"]),
        this.home = Local.fromMap(snapshot.data["home"]),
        this.work = Local.fromMap(snapshot.data["work"]),
        this.modifiedOn =
            DateTime.parse(snapshot.data['modifiedOn'].toString()),
        this.createdOn = DateTime.parse(snapshot.data['createdOn']),
        this.status = snapshot.data["status"] as bool;

  Passenger.fromJson(Map<dynamic, dynamic> map)
      : code = map["code"],
        this.id = map["id"],
        this.email = map["email"],
        this.name = map["name"] == null ? '---' : map["name"],
        this.age = map["age"],
        this.image = MyImage.fromMap(map["image"]),
        this.home = map["home"] == null ? null : Local.fromMap(map["home"]),
        this.work = map["work"] == null ? null : Local.fromMap(map["work"]),
        this.modifiedOn = DateTime.parse(map['modifiedOn']),
        this.createdOn = DateTime.parse(map['createdOn']),
        this.status = map["status"] as bool;

  static Map<dynamic, dynamic> stringToMap(String s) {
    Map<dynamic, dynamic> map = jsonDecode(s) as Map<dynamic, dynamic>;
    return map;
  }

  toJson() {
    return {
      "id": this.id,
      "code": this.code == '' ? HelpService.generateCode(12) : this.code,
      "name": this.name == null ? '---' : this.name,
      "age": this.age,
      "email": this.email,
      "image": this.image == null ? MyImage().toJson() : this.image.toJson(),
      "home": this.home == null ? Local().toJson() : this.home.toJson(),
      "work": this.work == null ? Local().toJson() : this.work.toJson(),
      "modifiedOn": this.modifiedOn == null
          ? DateTime.now().toString()
          : this.modifiedOn.toString(),
      "createdOn": this.createdOn == null
          ? DateTime.now().toString()
          : this.createdOn.toString(),
      "status": this.status == null ? true : this.status
    };
  }
}
