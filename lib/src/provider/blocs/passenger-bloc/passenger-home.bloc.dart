import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:rxdart/rxdart.dart';

class PassengerHomeBloc extends BlocBase {
  final BehaviorSubject<StepPassengerHome> _stepProcessController =
      new BehaviorSubject<StepPassengerHome>();

  Stream<StepPassengerHome> get stepProcessFlux =>
      _stepProcessController.stream;

  Sink<StepPassengerHome> get stepProcessEvent => _stepProcessController.sink;

  final BehaviorSubject<String> _timeController = new BehaviorSubject<String>();

  Stream<String> get timeFlux => _timeController.stream;

  Sink<String> get timeEvent => _timeController.sink;

  /*price / distance management */
  final BehaviorSubject<CarType> _carTypeController =
      new BehaviorSubject<CarType>();

  Stream<CarType> get carTypeFlux => _carTypeController.stream;

  Sink<CarType> get carTypeEvent => _carTypeController.sink;

  /*end trip*/

  PassengerHomeBloc() {
    _stepProcessController.add(StepPassengerHome.Start);
  }

  @override
  void dispose() {
    _carTypeController?.close();
    _stepProcessController?.close();
    _timeController?.close();
    super.dispose();
  }
}
