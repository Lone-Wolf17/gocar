import 'package:gocar/src/entity/entities.dart';
import 'package:gocar/src/infra/admin/protected_data.dart';

/*<key, firebaseUrl>*/
final dataBaseTables = <String, String>{
  'passenger': 'Passenger',
  'driver': 'Driver',
  'trip': 'Trip',
  'report': 'Report',
  'Vehicle': 'Vehicle',
};

final PersonType configPersonType = PersonType.Passenger;

final double valueKm = 5;

final keyGoogle = google_maps_api_key;
