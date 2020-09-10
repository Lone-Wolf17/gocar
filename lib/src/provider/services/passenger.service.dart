import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:gocar/src/infra/infra.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PassengerService {
  static final String _baseUrl = dataBaseTables["passenger"];
  final CollectionReference _db;

  PassengerService() : _db = Firestore.instance.collection(_baseUrl);

  Future<Passenger> save(Passenger entity) async {
    if (entity.id == null) entity.id = _db.document().documentID;

    await _db.document(entity.id).setData(entity.toJson());
    return entity;
  }

  Future<void> verifyExistsByEmailAndSave(Passenger entity) async {
    var result = await getByEmail(entity.email);

    /*if the user already exists, it reuses the id and age that has already been registered*/
    if (result != null) {
      entity.id = result.id;
      entity.age = result.age;
    }
    await save(entity);
  }

  Future<Passenger> getByEmail(String email) async {
    final CollectionReference _dbs = Firestore.instance.collection(_baseUrl);
    var query = await _dbs.where("Email", isEqualTo: email).getDocuments();

    return query.documents.isEmpty
        ? null
        : Passenger.fromSnapshot(query.documents[0]);
  }

  Future<Passenger> getCustomerStorage() async {
    SharedPreferences storageData = await SharedPreferences.getInstance();

    var passenger = storageData.getString('passenger');
    var customerResult = passenger == null
        ? null
        : Passenger.fromJson(Passenger.stringToMap(passenger.toString()));
    return (customerResult);
  }

  Future setStorage(Passenger customer) async {
    try {
      SharedPreferences storageData = await SharedPreferences.getInstance();
      await storageData.setString('passenger', json.encode(customer.toJson()));
    } catch (ex) {
      throw ('Error in SetCardStorage' + ex);
    }
  }

  Future<void> remove() async {
    SharedPreferences storageData = await SharedPreferences.getInstance();
    await storageData.remove('passenger');
  }
}
