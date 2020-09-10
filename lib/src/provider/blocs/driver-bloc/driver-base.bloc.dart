import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:gocar/src/entity/enums.dart';
import 'package:rxdart/rxdart.dart';

import '../../provider.dart';

class DriverBaseBloc extends BlocBase {
  /*services used */
  static StreamSubscription<QuerySnapshot> _streamFirebaseAllOpenTrip;
  static StreamSubscription<QuerySnapshot> _streamSpecificOpenTrip;
  bool indicatesMonitoringPassengerDriver;

  /*end*/

/*variable related to the map provider*/
  final BehaviorSubject<MapProvider> _providerMapController =
      new BehaviorSubject<MapProvider>();

  Observable<MapProvider> get mapProviderFlux => _providerMapController.stream;

  Sink<MapProvider> get mapProviderEvent => _providerMapController.sink;

  /*end map provider*/

  /*trip management*/
  final BehaviorSubject<Trip> _tripController = new BehaviorSubject<Trip>();

  Stream<Trip> get tripFlux => _tripController.stream;

  Sink<Trip> get tripEvent => _tripController.sink;

/*end trip*/

  DriverBaseBloc();

  /*central class, responsible for concentrating intelligence of the actions taken*/
  Future<void> orchestration() async {
    DriveHomeBloc _driverHome =
    BlocProvider.getBloc<DriveHomeBloc>();
    StepDriverHome _stepHome = await _driverHome.stepDriverFlux.first;
    StepStartDriverBiz stepStartDriverBiz = StepStartDriverBiz();
    StepDriverTripSearchBiz stepDriverTripSearchBiz =
    StepDriverTripSearchBiz();
    StepDriverTripStartedBiz stepDriverTripStartedBiz =
    StepDriverTripStartedBiz();

    /*ensures that there will be no active flow while the initial process*/
    closeStreamsFlow();

    switch (_stepHome) {
      case StepDriverHome.Start:
        stepStartDriverBiz.start();
        break;
      case StepDriverHome.LookingForTravel:
        stepDriverTripSearchBiz.start();
        break;
      case StepDriverHome.StartTravel:
        stepDriverTripStartedBiz.start();
        break;
      default:
        throw new Exception("Call for action that shouldn't exist.");
        break;
    }
  }

  /*end*/

  void closeStreamsFlow() {
    StepStartDriverBiz stepStartDriverBiz = StepStartDriverBiz();
    StepDriverTripSearchBiz stepDriverTripSearchBiz =
    StepDriverTripSearchBiz();
    StepDriverTripStartedBiz stepDriverTripStartedBiz =
    StepDriverTripStartedBiz();

    /*ensures that there will be no active flow while the initial process*/
    stepStartDriverBiz.closeStreamFlow();
    stepDriverTripSearchBiz.closeStreamsFlow();
    stepDriverTripStartedBiz.closeStreamsFlow();
  }

  @override
  void dispose() {
    closeStreamsFlow();
    _providerMapController?.close();
    _streamSpecificOpenTrip?.cancel();
    _streamFirebaseAllOpenTrip?.cancel();
    _tripController?.close();
    super.dispose();
  }
}
