import 'package:gocar/src/entity/entities.dart';
import 'package:gocar/src/provider/provider.dart';

class VehicleData {
  static buildVehicle() async {
    final _database = new VehicleService();
    var vehicle = Vehicle(
        status: true,
        image: MyImage(),
        brand: "Audi",
        model: "A3",
        type: CarType.Top);

    var vehicle1 = Vehicle(
        type: CarType.Top,
        status: true,
        image: MyImage(),
        brand: "Audi",
        model: "A4");

    var vehicle2 = Vehicle(
        type: CarType.Top,
        status: true,
        image: MyImage(),
        brand: "BMW",
        model: "X5");

    var vehicle3 = Vehicle(
        type: CarType.Pop,
        status: true,
        image: MyImage(),
        brand: "Chevrolet",
        model: "Blazer");

    var vehicle4 = Vehicle(
        status: true,
        image: MyImage(),
        type: CarType.Pop,
        brand: "Chevrolet",
        model: "Captiva");

    await _database.save(vehicle);
    await _database.save(vehicle1);
    await _database.save(vehicle2);
    await _database.save(vehicle3);
    await _database.save(vehicle4);
  }
}
