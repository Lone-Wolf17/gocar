import 'package:bloc_pattern/bloc_pattern.dart';
import "package:collection/collection.dart";
import 'package:gocar/src/entity/entities.dart';
import 'package:gocar/src/infra/help/chart.dart';
import 'package:random_color/random_color.dart';
import 'package:rxdart/rxdart.dart';

import '../../provider.dart';

class DriverTripBloc extends BlocBase {
  final BehaviorSubject<List<Trip>> _tripsListController =
      BehaviorSubject<List<Trip>>.seeded(List<Trip>());

  Stream<List<Trip>> get tripsListFlux => _tripsListController.stream;

  Sink<List<Trip>> get tripsListEvent => _tripsListController.sink;

  final BehaviorSubject<List<PieChartFlutter>> _locationChartListController =
      BehaviorSubject<List<PieChartFlutter>>.seeded(List<PieChartFlutter>());

  Stream<List<PieChartFlutter>> get locationChartListFlux =>
      _locationChartListController.stream;

  Sink<List<PieChartFlutter>> get locationChartListEvent =>
      _locationChartListController.sink;

  final BehaviorSubject<List<PieChartFlutter>> _ageChartListController =
      BehaviorSubject<List<PieChartFlutter>>.seeded(List<PieChartFlutter>());

  Stream<List<PieChartFlutter>> get ageChartListFlux =>
      _ageChartListController.stream;

  Sink<List<PieChartFlutter>> get ageChartListEvent =>
      _ageChartListController.sink;

  final BehaviorSubject<List<Trip>> _tripsChartByAgeController =
      BehaviorSubject<List<Trip>>.seeded(List<Trip>());

  Stream<List<Trip>> get tripsChartByAgeFlux =>
      _tripsChartByAgeController.stream;

  Sink<List<Trip>> get tripsChartByAgeEvent => _tripsChartByAgeController.sink;

  TripService _tripService;
  DriverService _driverService;

  DriverTripBloc() {
    _tripService = new TripService();
    _driverService = new DriverService();
  }

  loadTrip() async {
    Driver driver = await _driverService.getCustomerStorage();
    List<Trip> tripList = await _tripService.getTripsByDriver(driver.id);
    if (tripList == null) tripList = List<Trip>();

    tripsListEvent.add(tripList);
  }

  loadChartByAge(List<Trip> tripList) async {
    RandomColor _randomColor = RandomColor();
    List<PieChartFlutter> chartPie = List<PieChartFlutter>();
    groupBy((tripList.map((r) => r.toJson())),
            (obj) => (obj['PassengerEntity']['Age']).toString())
        .forEach((key, itens) {
      chartPie.add(PieChartFlutter(
          itens.length.toDouble(), '$key years', _randomColor.randomColor()));
    });

    ageChartListEvent.add(chartPie);
  }

  loadChartByLocation(List<Trip> tripList) async {
    RandomColor _randomColor = RandomColor();

    List<PieChartFlutter> chartPie = List<PieChartFlutter>();
    groupBy((tripList.map((r) => r.toJson())),
        (obj) => obj['DestinationAddress']).forEach((key, itens) {
      chartPie.add(PieChartFlutter(
          itens.length.toDouble(), key, _randomColor.randomColor()));
    });

    locationChartListEvent.add(chartPie);
  }

  loadChar() async {
    Driver driver = await _driverService.getCustomerStorage();
    List<Trip> tripList = await _tripService.getTripsByDriver(driver.id);
    loadChartByAge(tripList);
    loadChartByLocation(tripList);
  }

  @override
  void dispose() {
    _tripsListController?.close();
    _tripsChartByAgeController?.close();
    _ageChartListController?.close();
    _locationChartListController?.close();
    super.dispose();
  }
}
