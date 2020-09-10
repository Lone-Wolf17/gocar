import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../provider.dart';
import 'blocs.dart';

class BasePassengerBloc extends BlocBase {
  /*observable variables*/

  /*trip management*/
  final BehaviorSubject<Trip> _tripController = new BehaviorSubject<Trip>();

  Stream<Trip> get tripFlow => _tripController.stream;

  Sink<Trip> get tripEvent => _tripController.sink;

/*end trip*/

/*variable related to the map provider*/
  final BehaviorSubject<MapProvider> _mapProviderController =
      new BehaviorSubject<MapProvider>();

  Observable<MapProvider> get mapProviderFlux => _mapProviderController.stream;

  Sink<MapProvider> get mapProviderEvent => _mapProviderController.sink;

/*end map provider*/

  BasePassengerBloc();

  /*central class, responsible for concentrating intelligence of the actions taken*/
  Future<void> orchestration() async {
    PassengerHomeBloc _passengerHomeBloc =
    BlocProvider.getBloc<PassengerHomeBloc>();
    StepPassengerHome _stepHome =
    await _passengerHomeBloc.stepProcessFlux.first;
    StepStartPassengerBiz _stepStartPassengerBiz =
    StepStartPassengerBiz();
    StepConfirmTripBiz _stepConfirmTripBiz = StepConfirmTripBiz();
    StepPassengerDriverSearch _stepPassengerDriverSearch =
    StepPassengerDriverSearch();

    /*ensures that there will be no active flow while the initial process*/
    closeStreamsFlow();


    switch (_stepHome) {
      case StepPassengerHome.Start:
        _stepStartPassengerBiz.start();
        break;
      case StepPassengerHome.ConfirmValue:
        _stepConfirmTripBiz.start();
        break;
      case StepPassengerHome.LookingForADriver:
        _stepPassengerDriverSearch.start();
        break;
      default:
        throw new Exception("Call for action that shouldn't exist.");
        break;
    }
  }

  void closeStreamsFlow() {
    StepStartPassengerBiz _stepStartPassengerBiz =
    StepStartPassengerBiz();
    StepPassengerDriverSearch _stepPassengerDriverSearch =
    StepPassengerDriverSearch();

    /*ensures that there will be no active flow while the initial process*/
    _stepStartPassengerBiz.closeStreamsFlow();
    _stepPassengerDriverSearch.closeStreamsFlow();
    //stepMotoristaProcurarViagem.encerrarFluxosStream();
    //stepMotoristaViagemIniciada.encerrarFluxosStream();
  }

  /*second level trip cancellation*/
  Future cancelTrip() async {
    TripService _tripService = TripService();
    Trip trip = await tripFlow.first;
    trip.status = TripStatus.Canceled;
    /*kills the firebase stream if it is open and others*/
    closeStreamsFlow();
    await _tripService.save(trip);
  }

  /*end trip cancellation*/

  /*add point to provider map*/
  refreshProvider(LatLng location, String address,
      LocalReference localReference) async {
    MapProvider provider = await mapProviderFlux.first;
    provider.markers = Set<Marker>();
    if (localReference != LocalReference.Destination) {
      provider.originLatLng = location;
      provider.originAddress = address;
    } else {
      provider.destinationAddress = address;
      provider.destinationLatLng = location;
    }
    mapProviderEvent.add(provider);
  }

  /* end provider  */

  @override
  void dispose() {
    _tripController?.close();
    _mapProviderController?.close();
    super.dispose();
  }
}
