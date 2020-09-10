import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:gocar/src/infra/infra.dart';

class ReportService {
  static final String _baseUrl = dataBaseTables["report"];
  final CollectionReference _db;

  ReportService() : _db = Firestore.instance.collection(_baseUrl);

  Future<Report> save(Report entity) async {
    if (entity.id == null) entity.id = _db.document().documentID;

    await _db.document(entity.id).setData(entity.toJson());
    return entity;
  }

  Future<Report> getById(String id) async {
    final CollectionReference _dbs = Firestore.instance.collection(_baseUrl);
    var query = await _dbs.where("Id", isEqualTo: id).getDocuments();

    return query.documents.isEmpty
        ? null
        : Report.fromSnapshotJson(query.documents[0]);
  }

  Future<void> deleteById(String id) async {
    await _db.document(id).delete();
  }

  Future<List<Report>> getByDriver(String motoristaId) async {
    final CollectionReference _dbs = Firestore.instance.collection(_baseUrl);
    var query =
    await _dbs.where("DriverId", isEqualTo: motoristaId).getDocuments();

    return query.documents.isEmpty
        ? null
        : query.documents
        .map((result) => Report.fromSnapshotJson(result))
        .toList();
  }

  Future<List<Report>> getByDriverWithDate(String driverId,
      DateTime initialDate, DateTime dataFinal) async {
    final CollectionReference _dbs = Firestore.instance.collection(_baseUrl);
    var query =
    await _dbs.where("DriverId", isEqualTo: driverId).getDocuments();

    return query.documents.isEmpty
        ? null
        : query.documents
        .map((result) => Report.fromSnapshotJson(result))
        .toList();
  }
}
