import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:gocar/src/infra/infra.dart';

class VehicleService {
  static final String _baseUrl = dataBaseTables["vehicle"];
  final CollectionReference _db;

  VehicleService() : _db = Firestore.instance.collection(_baseUrl);

  Future<Vehicle> save(Vehicle entity) async {
    if (entity.id == null) entity.id = _db.document().documentID;

    await _db.document(entity.id).setData(entity.toJson());
    return entity;
  }

  Future<List<Vehicle>> getAll() async {
    final CollectionReference _dbs = Firestore.instance.collection(_baseUrl);
    var query = await _dbs.getDocuments();
    return query.documents.isEmpty
        ? null
        : query.documents
            .map((result) => Vehicle.fromSnapshotJson(result))
            .toList();
  }
}
