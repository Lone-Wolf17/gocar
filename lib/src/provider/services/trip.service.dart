import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:gocar/src/infra/infra.dart';

class TripService {
  static final String _baseUrl = dataBaseTables["trip"];
  final CollectionReference _db;

  TripService() : _db = Firestore.instance.collection(_baseUrl);

  Future<Trip> save(Trip entity) async {
    if (entity.id == null) entity.id = _db.document().documentID;

    await _db.document(entity.id).setData(entity.toJson());
    return entity;
  }

  /*if the app has been closed and has open trip*/
  Future<void> cancelAllOpenPassengerTrips(String passengerId) async {
    final CollectionReference _dbs = Firestore.instance.collection(_baseUrl);

    var query = await _dbs
        .where("PassengerEntity.Id", isEqualTo: passengerId)
        .where("Status", isEqualTo: TripStatus.Open.index)
        .getDocuments();

    if (query.documents.isNotEmpty) {
      List<Trip> openTripsList = query.documents
          .map((result) => Trip.fromSnapshotJson(result))
          .toList();

      openTripsList.forEach((r) async {
        r.status = TripStatus.Canceled;
        await save(r);
      });
    }
  }

  /*checks if there is an open trip for passengers*/
  Future<Stream<QuerySnapshot>> startTrip(Trip entity) async {
    await save(entity);

    final CollectionReference _dbs = Firestore.instance.collection(_baseUrl);
    Stream<QuerySnapshot> snapshots =
        _dbs.where("Id", isEqualTo: entity.id).limit(1).snapshots();

    return snapshots;
  }

  /*checks if there is an open trip for passengers*/
  Future<Stream<QuerySnapshot>> startOpenTripSearch() async {
    final CollectionReference _dbs = Firestore.instance.collection(_baseUrl);
    Stream<QuerySnapshot> snapshots = _dbs
        .where("Status", isEqualTo: TripStatus.Open.index)
        .limit(1)
        .snapshots();

    return snapshots;
  }

  Future<Stream<QuerySnapshot>> getTripById(String id) async {
    final CollectionReference _dbs = Firestore.instance.collection(_baseUrl);

    Stream<QuerySnapshot> snapshots =
        await _dbs.where("Id", isEqualTo: id).limit(1).snapshots();

    return snapshots;
  }

  Future<Trip> getStreamTripById(String id) async {
    final CollectionReference _dbs = Firestore.instance.collection(_baseUrl);

    var query = await _dbs.where("Id", isEqualTo: id).getDocuments();

    return query.documents.isEmpty
        ? null
        : Trip.fromSnapshotJson(query.documents[0]);
  }


  Future<Stream<List<DocumentSnapshot>>> getOpenTripGeoPoint(double lat,
      double lng, TripStatus status) async {
    final CollectionReference _dbs = Firestore.instance.collection(_baseUrl);

    Geoflutterfire geo = Geoflutterfire();
    GeoFirePoint center = geo.point(latitude: lat, longitude: lng);
    double radius = 50;
    String field = 'position';

    Stream<List<DocumentSnapshot>> stream = geo
        .collection(
        collectionRef: _dbs.where("Status", isEqualTo: status.index))
        .within(center: center, radius: radius, field: field);

    return stream;
  }


  Future<Trip> getOpenTripByUser(String passengerId,
      TripStatus status) async {
    final CollectionReference _dbs = Firestore.instance.collection(_baseUrl);

    var query = await _dbs
        .where("Status", isEqualTo: status.index)
        .where("PassengerEntity.Id", isEqualTo: passengerId)
        .getDocuments();

    return query.documents.isEmpty
        ? null
        : Trip.fromSnapshotJson(query.documents[0]);
  }

  Future<List<Trip>> getTripsByPassenger(String passengerId) async {
    final CollectionReference _dbs = Firestore.instance.collection(_baseUrl);

    var query = await _dbs.where("PassengerEntity.Id", isEqualTo: passengerId)
        .getDocuments();

    return query.documents.isEmpty
        ? null
        : query.documents
        .map((result) => Trip.fromSnapshotJson(result))
        .toList();
  }

  Future<List<Trip>> getTripsCompletedByDriver(String driverId) async {
    final CollectionReference _dbs = Firestore.instance.collection(_baseUrl);

    var query = await _dbs.where("Status", isEqualTo: 5)
        .where("DriverEntity.Id", isEqualTo: driverId).getDocuments();

    return query.documents.isEmpty
        ? null
        : query.documents
        .map((result) => Trip.fromSnapshotJson(result))
        .toList();
  }

  Future<List<Trip>> getTripsComplimentedByDriverWithStartFinalDate(
      String driverId, DateTime startDate, DateTime endDate) async {
    final CollectionReference _dbs = Firestore.instance.collection(_baseUrl);

    var query = await _dbs.where("Status", isEqualTo: 5)
        .where("DriverEntity.Id", isEqualTo: driverId)
        .where('ModifiedOn', isGreaterThanOrEqualTo: startDate)
        .getDocuments();

    return query.documents.isEmpty
        ? null
        : query.documents
        .map((result) => Trip.fromSnapshotJson(result))
        .toList();
  }


  Future<List<Trip>> getTripsByDriver(String driverId) async {
    final CollectionReference _dbs = Firestore.instance.collection(_baseUrl);

    var query = await _dbs.where("DriverEntity.Id", isEqualTo: driverId)
        .getDocuments();

    return query.documents.isEmpty
        ? null
        : query.documents
        .map((result) => Trip.fromSnapshotJson(result))
        .toList();
  }
}
