import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:gocar/src/infra/infra.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverService {
  static final String _baseUrl = dataBaseTables["driver"];
  final CollectionReference _db;

  DriverService() : _db = Firestore.instance.collection(_baseUrl);

  Future<Driver> save(Driver entity) async {
    if (entity.id == null) entity.id = _db.document().documentID;

    await _db.document(entity.id).setData(entity.toJson());
    return entity;
  }

  Future<void> verifyExistsByEmailAndSave(Driver entity) async {
    var result = await getByEmail(entity.email);

    /*if the user already exists, it reuses the id and age that has already been registered*/
    if (result != null) {
      entity.id = result.id;
      entity.car = result.car;
    }
    await save(entity);
  }

  Future<Driver> getByEmail(String email) async {
    final CollectionReference _dbs = Firestore.instance.collection(_baseUrl);
    var query = await _dbs.where("Email", isEqualTo: email).getDocuments();

    return query.documents.isEmpty
        ? null
        : Driver.fromSnapshot(query.documents[0]);
  }

  Future<Driver> getCustomerStorage() async {
    SharedPreferences storageData = await SharedPreferences.getInstance();

    var driver = storageData.getString('driver');
    var customerResult = driver == null
        ? null
        : Driver.fromJson(Driver.stringToMap(driver.toString()));
    return (customerResult);
  }

  Future setStorage(Driver driver) async {
    try {
      SharedPreferences storageData = await SharedPreferences.getInstance();
      var r = driver.toJson();
      await storageData.setString('driver', json.encode(driver.toJson()));
    } catch (ex) {
      throw ('Error in SetCardStorage' + ex);
    }
  }

  Future<void> remove() async {
    SharedPreferences storageData = await SharedPreferences.getInstance();
    await storageData.remove('driver');
  }

}
