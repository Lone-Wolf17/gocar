import 'package:gocar/src/entity/entities.dart';
import 'package:flutter_config/flutter_config.dart';


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

final keyGoogle = FlutterConfig.get('GOOGLE_MAPS_API_KEY');
