import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gocar/src/entity/driver.entity.dart';
import 'package:gocar/src/entity/passenger.entity.dart';
import 'package:gocar/src/infra/infra.dart';

import 'entities.dart';

class Trip {
  String id;
  String code;
  String distance;
  String time;
  DateTime createdOn;
  DateTime modifiedOn;
  DateTime tripAcceptedOn;
  Passenger passengerEntity;
  Driver driverEntity;
  CarType carType;
  String originMainAddress;
  String originAddress;
  String driverCurrentAddress;
  double valuePop;
  double valueTop;
  double driverPositionLongitude;
  double driverPositionLatitude;
  double originLatitude;
  double originLongitude;
  String destinationMainAddress;
  String destinationAddress;
  double destinationLatitude;
  double destinationLongitude;
  String paymentId;
  TripStatus status;

  Trip(
      {this.id,
      this.code = '',
      this.distance,
      this.time,
      this.valuePop,
      this.valueTop,
      this.originMainAddress,
      this.originAddress,
      this.originLatitude,
      this.originLongitude,
      this.driverPositionLongitude,
      this.driverPositionLatitude,
      this.carType,
      this.destinationMainAddress,
      this.destinationAddress,
      this.driverCurrentAddress,
      this.destinationLatitude,
      this.destinationLongitude,
      this.passengerEntity,
      this.driverEntity,
      this.modifiedOn,
      this.createdOn,
      this.paymentId = '',
      this.tripAcceptedOn,
      this.status});

  Trip.fromSnapshotJson(DocumentSnapshot snapshot)
      : this.id = snapshot.documentID,
        this.code = snapshot.data["code"],
        this.paymentId = snapshot.data["paymentId"],
        this.originMainAddress = snapshot.data["originMainAddress"],
        this.originAddress = snapshot.data["originAddress"],
        this.originLatitude = snapshot.data["originLatitude"],
        this.originLongitude = snapshot.data["originLongitude"],
        this.driverCurrentAddress = snapshot.data["driverCurrentAddress"],
        this.valuePop = snapshot.data["valuePop"].toDouble(),
        this.valueTop = snapshot.data["valueTop"].toDouble(),
        this.destinationMainAddress = snapshot.data["destinationMainAddress"],
        this.destinationAddress = snapshot.data["destinationAddress"],
        this.destinationLatitude = snapshot.data["destinationLatitude"],
        this.destinationLongitude = snapshot.data["destinationLongitude"],
        this.driverPositionLongitude = snapshot.data["driverPositionLongitude"],
        this.driverPositionLatitude = snapshot.data["driverPositionLatitude"],
        this.distance = snapshot.data["distance"],
        this.time = snapshot.data["time"],
        this.passengerEntity =
            Passenger.fromJson(snapshot.data["passengerEntity"]),
        this.driverEntity = Driver.fromJson(snapshot.data["driverEntity"]),
        this.modifiedOn = snapshot.data['modifiedOn'].toDate(),
        this.createdOn = snapshot.data['createdOn'].toDate(),
        this.tripAcceptedOn = snapshot.data['tripAcceptedOn'].toDate(),
        this.carType = CarType.values[snapshot.data['TipoCorrida']],
        this.status = TripStatus.values[(snapshot.data["Status"])];

  static Map<String, dynamic> stringToMap(String s) {
    Map<String, dynamic> map = json.decode(s);
    return map;
  }

  toJson() {
    return {
      "id": this.id,
      "code": this.code == '' ? HelpService.generateCode(12) : this.code,
      "originMainAddress": this.originMainAddress,
      "originAddress": this.originAddress,
      "paymentId": this.paymentId,
      "originLatitude": this.originLatitude,
      "originLongitude": this.originLongitude,
      "driverCurrentAddress": this.driverCurrentAddress,
      "destinationMainAddress": this.destinationMainAddress,
      "destinationAddress": this.destinationAddress,
      "destinationLatitude": this.destinationLatitude,
      "destinationLongitude": this.destinationLongitude,
      "driverPositionLongitude": this.driverPositionLongitude,
      "driverPositionLatitude": this.driverPositionLatitude,
      "valuePop": this.valuePop,
      "valueTop": this.valueTop,
      "time": this.time,
      "distance": this.distance,
      "passengerEntity": this.passengerEntity.toJson(),
      "driverEntity": this.driverEntity == null
          ? Driver().toJson()
          : this.driverEntity.toJson(),
      "modifiedOn": this.modifiedOn == null ? DateTime.now() : this.modifiedOn,
      "createdOn": this.createdOn == null ? DateTime.now() : this.createdOn,
      "tripAcceptedOn":
          this.tripAcceptedOn == null ? DateTime.now() : this.tripAcceptedOn,
      "status": this.status == null ? 0 : this.status.index,
      "carType": this.carType == null ? 0 : this.carType.index,
    };
  }
}
