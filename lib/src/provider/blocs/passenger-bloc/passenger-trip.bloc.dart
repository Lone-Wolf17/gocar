import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:rxdart/rxdart.dart';

import '../../provider.dart';

class PassengerTripBloc extends BlocBase {
  final BehaviorSubject<List<Trip>> _tripsListController =
      BehaviorSubject<List<Trip>>.seeded(List<Trip>());

  Stream<List<Trip>> get tripsListFlux => _tripsListController.stream;

  Sink<List<Trip>> get tripsListEvent => _tripsListController.sink;

  TripService _tripService;
  PassengerService _passengerService;

  PassengerTripBloc() {
    _tripService = new TripService();
    _passengerService = new PassengerService();
  }

  loadTrip() async {
    Passenger passenger = await _passengerService.getCustomerStorage();
    List<Trip> tripList = await _tripService.getTripsByPassenger(passenger.id);
    if (tripList == null) tripList = List<Trip>();

    tripsListEvent.add(tripList);
  }

  @override
  void dispose() {
    _tripsListController?.close();
    super.dispose();
  }
}
