import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:rxdart/rxdart.dart';

import '../../provider.dart';

class DriverReportBloc extends BlocBase {
  final BehaviorSubject<List<Report>> _reportListController =
      BehaviorSubject<List<Report>>.seeded(List<Report>());

  Stream<List<Report>> get reportListFlux => _reportListController.stream;

  Sink<List<Report>> get reportListEvent => _reportListController.sink;

  final BehaviorSubject<double> _totalReportController =
      BehaviorSubject<double>();

  Stream<double> get totalReportFlux => _totalReportController.stream;

  Sink<double> get totalReportEvent => _totalReportController.sink;

  final BehaviorSubject<double> _totalReportFilterController =
      BehaviorSubject<double>();

  Stream<double> get totalReportFilterFlux =>
      _totalReportFilterController.stream;

  Sink<double> get totalReportFilterEvent => _totalReportFilterController.sink;

  ReportService _reportService = ReportService();

  loadReportsByDriver() async {
    DriverAuthBloc _auth = BlocProvider.getBloc<DriverAuthBloc>();
    Driver driver = await _auth.userInfoFlux.first;
    TripService tripService = TripService();

    List<Report> reportsList = await _reportService.getByDriver(driver.id);

    reportListEvent.add(reportsList == null ? List<Report>() : reportsList);

    List<Trip> trips = await tripService.getTripsCompletedByDriver(driver.id);

    await calculateTotal(reportsList, trips);
  }

  loadReportsByDriverWithData(DateTime initialData, DateTime dataFinal) async {
    DriverAuthBloc _auth = BlocProvider.getBloc<DriverAuthBloc>();
    Driver driver = await _auth.userInfoFlux.first;
    TripService tripService = TripService();

    List<Report> reports = await _reportService.getByDriver(driver.id);

    reportListEvent.add(reports == null ? List<Report>() : reports);

    List<Trip> trips = await tripService.getTripsCompletedByDriver(driver.id);

    if (trips != null)
      trips = trips
          .where((v) =>
              v.modifiedOn.isAfter(initialData) &&
              v.modifiedOn.isBefore(dataFinal))
          .toList();

    if (reports != null)
      reports = reports
          .where((v) =>
              v.modifiedOn.isAfter(initialData) &&
              v.modifiedOn.isBefore(dataFinal))
          .toList();

    /*it didn’t work*/
    /* List<Viagem> trips =
    await tripService.getViagensByMotoristaConcluidaWithDataInicialFinal(driver.Id,dataInicial,dataFinal);*/

    await calculateTotalFilter(reports, trips);
  }

  calculateTotal(List<Report> reports, List<Trip> trips) async {
    double totalTrips = 0;
    double totalSpending = 0;

    if (trips != null)
      trips.forEach((Trip e) {
        totalTrips += (e.carType == CarType.Top ? e.valueTop : e.valuePop);
      });
    if (reports != null)
      reports.forEach((Report e) {
        totalSpending += (e.food + e.gasoline + e.carMaintenance);
      });

    totalReportEvent.add(totalTrips - totalSpending);
  }

  calculateTotalFilter(List<Report> reports, List<Trip> trips) async {
    double totalTrips = 0;
    double totalSpending = 0;

    if (trips != null)
      trips.forEach((Trip e) {
        totalTrips += (e.carType == CarType.Top ? e.valueTop : e.valuePop);
      });
    if (reports != null)
      reports.forEach((Report e) {
        totalSpending += (e.food + e.gasoline + e.carMaintenance);
      });

    totalReportFilterEvent.add(totalTrips - totalSpending);
  }

  @override
  void dispose() {
    _reportListController?.close();
    _totalReportController?.close();
    _totalReportFilterController?.close();
    super.dispose();
  }
}
