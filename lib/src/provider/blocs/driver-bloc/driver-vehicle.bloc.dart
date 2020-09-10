import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:rxdart/rxdart.dart';

import '../../provider.dart';

class DriverVehicleBloc extends BlocBase {
  final BehaviorSubject<List<Vehicle>> _vehicleBrandListController =
      BehaviorSubject<List<Vehicle>>.seeded(List<Vehicle>());

  Stream<List<Vehicle>> get vehicleBrandListFlux =>
      _vehicleBrandListController.stream;

  Sink<List<Vehicle>> get vehicleBrandListEvent =>
      _vehicleBrandListController.sink;

  final BehaviorSubject<List<Vehicle>> _vehicleModelListController =
      BehaviorSubject<List<Vehicle>>.seeded(List<Vehicle>());

  Stream<List<Vehicle>> get vehicleModelListFlux =>
      _vehicleModelListController.stream;

  Sink<List<Vehicle>> get vehicleModelListEvent =>
      _vehicleModelListController.sink;

  final BehaviorSubject<List<String>> _vehicleColorListController =
      BehaviorSubject<List<String>>.seeded(List<String>());

  Stream<List<String>> get vehicleColorListFlux =>
      _vehicleColorListController.stream;

  Sink<List<String>> get vehicleColorListEvent =>
      _vehicleColorListController.sink;

  final BehaviorSubject<List<String>> _vehicleYearListController =
      BehaviorSubject<List<String>>.seeded(List<String>());

  Stream<List<String>> get vehicleYearListFlux =>
      _vehicleYearListController.stream;

  Sink<List<String>> get vehicleYearListEvent =>
      _vehicleYearListController.sink;

  final BehaviorSubject<List<String>> _categoryListController =
      BehaviorSubject<List<String>>.seeded(List<String>());

  Stream<List<String>> get categoryListFlux => _categoryListController.stream;

  Sink<List<String>> get categoryListEvent => _categoryListController.sink;

  final BehaviorSubject<String> _selectCategoryController =
      new BehaviorSubject<String>.seeded(null);

  Stream<String> get selectCategoryFlux => _selectCategoryController.stream;

  Sink<String> get selectCategoryEvent => _selectCategoryController.sink;

  final BehaviorSubject<String> _selectBrandController =
      new BehaviorSubject<String>.seeded(null);

  Stream<String> get selectBrandFlux => _selectBrandController.stream;

  Sink<String> get selectBrandEvent => _selectBrandController.sink;

  final BehaviorSubject<String> _selectModelController =
      new BehaviorSubject<String>.seeded(null);

  Stream<String> get selectModelFlux => _selectModelController.stream;

  Sink<String> get selectModelEvent => _selectModelController.sink;

  final BehaviorSubject<String> _selectColorController =
      new BehaviorSubject<String>.seeded(null);

  Stream<String> get selectColorFlux => _selectColorController.stream;

  Sink<String> get selectColorEvent => _selectColorController.sink;

  final BehaviorSubject<String> _selectYearController =
      new BehaviorSubject<String>.seeded(null);

  Stream<String> get selectYearFlux => _selectYearController.stream;

  Sink<String> get selectYearEvent => _selectYearController.sink;

  static List<Vehicle> vehiclesList;

  VehicleService _vehicleService;

  DriverVehicleBloc() {
    _vehicleService = new VehicleService();
  }

  load(bool first) async {
    if (first) {
      DriverAuthBloc _auth = BlocProvider.getBloc<DriverAuthBloc>();
      Driver driver = await _auth.userInfoFlux.first;
      selectCategoryEvent.add(driver.car.type == CarType.Top ? 'Top' : 'Pop');
      selectBrandEvent.add(driver.car.brand == '' ? null : driver.car.brand);
      selectModelEvent.add(driver.car.model == '' ? null : driver.car.model);
      selectYearEvent.add(driver.car.year == '' ? null : driver.car.year);
      selectColorEvent.add(driver.car.color == '' ? null : driver.car.color);
    }

    String selectedType = (await selectCategoryFlux.first);
    String selectedBrand = (await selectBrandFlux.first);
    String selectModel = (await selectModelFlux.first);
    String selectedYear = (await selectYearFlux.first);
    String selectedColor = (await selectColorFlux.first);

    /*mount category*/
    buildCategory(selectedType);

    /*avoid is always going to the bank */
    if (vehiclesList == null || vehiclesList.length == 0)
      vehiclesList = await _vehicleService.getAll();

    /*build Brands */
    buildBrand(selectedType, selectedBrand);
    /*end brand*/

    /*build years */
    buildYear(selectedYear);
    /*end year*/

    /*build Colors */
    buildColor(selectedColor);
    /*end color*/

    /*build Models */
    buildModel(selectedBrand, selectModel);
    /*end model*/
  }

  void buildCategory(String selectedType) async {
    List<String> currentCategoryList = await categoryListFlux.first;
    List<String> _categoryList = <String>['Pop', 'Top'];

    /*only mount the drop the first time*/
    if (currentCategoryList.length == 0) categoryListEvent.add(_categoryList);

    selectCategoryEvent.add(selectedType);
  }

  void buildYear(String selectedYear) async {
    List<String> yearList = await vehicleYearListFlux.first;

    if (yearList.length == 0 || yearList == null)
      vehicleYearListEvent
          .add(List<String>.generate(29, (i) => ((i + 1990) + 1).toString()));

    selectYearEvent.add(selectedYear);
  }

  void buildColor(String selectedColor) async {
    List<String> colorList = await vehicleColorListFlux.first;
    List<String> _colorsList = <String>[
      'Red',
      'Yellow',
      'Blue',
      'White',
      'Black',
      'Grey',
      'Orange'
    ];

    if (colorList.length == 0 || colorList == null)
      vehicleColorListEvent.add(_colorsList);

    selectColorEvent.add(selectedColor);
  }

  void buildBrand(String tipo, String marcaSelecionada) {
    CarType selectedType =
        tipo == null ? null : (tipo == 'Pop' ? CarType.Pop : CarType.Top);

    List<Vehicle> list = vehiclesList;

    if (selectedType != null) {
      var result = list.where((o) => o.type.index == selectedType.index);

      if (result != null) {
        list = result.toList();
        list = _uniquifyList(list);
      } else {
        list = List<Vehicle>();
      }
    } else {
      list = List<Vehicle>();
    }
    selectBrandEvent.add(marcaSelecionada);
    print(list.length);
    vehicleBrandListEvent.add(list);
  }

  void buildModel(String brand, String selectedModel) {
    List<Vehicle> list = vehiclesList;

    if (brand != null) {
      var result = list.where((o) => o.brand == brand);

      if (result != null) {
        list = result.toList();
        list = _uniquifyModelList(list);
      } else {
        list = List<Vehicle>();
      }
    } else {
      list = List<Vehicle>();
    }

    selectModelEvent.add(selectedModel);
    vehicleModelListEvent.add(list);
  }

  List<Vehicle> _uniquifyList(List<Vehicle> list) {
    List<Vehicle> vehicleList = List<Vehicle>();

    for (int i = 0; i < list.length; i++) {
      var item = vehicleList.firstWhere((o) => o.brand == list[i].brand,
          orElse: () => null);

      if (item == null) vehicleList.add(list[i]);
    }
    return vehicleList;
  }

  List<Vehicle> _uniquifyModelList(List<Vehicle> list) {
    List<Vehicle> vehicleList = List<Vehicle>();

    for (int i = 0; i < list.length; i++) {
      var item = vehicleList.firstWhere((o) => o.model == list[i].model,
          orElse: () => null);

      if (item == null) vehicleList.add(list[i]);
    }
    return vehicleList;
  }

  @override
  void dispose() {
    _selectBrandController?.close();
    _vehicleBrandListController?.close();
    _selectYearController?.close();
    _selectColorController?.close();
    _categoryListController?.close();
    _vehicleModelListController?.close();
    _selectCategoryController?.close();
    _selectModelController?.close();
    _vehicleYearListController?.close();
    _vehicleColorListController?.close();
    super.dispose();
  }
}
