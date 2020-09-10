import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:gocar/src/infra/infra.dart';
import 'package:gocar/src/provider/blocs/blocs.dart';
import 'package:gocar/src/provider/provider.dart';

import '../../pages.dart';

class MyCarPage extends StatefulWidget {
  const MyCarPage(this.changeDrawer);

  final ValueChanged<BuildContext> changeDrawer;

  @override
  _MyCarPageState createState() => _MyCarPageState();
}

class _MyCarPageState extends State<MyCarPage> {
  DriverVehicleBloc _driverVehicleBloc;
  DriverAuthBloc _auth;
  DriverService _driverService;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scaffoldKey;
  TextEditingController _textBoardName = new TextEditingController();

  @override
  void initState() {
    _scaffoldKey = new GlobalKey<ScaffoldState>();
    _driverVehicleBloc = DriverVehicleBloc();
    _auth = BlocProvider.getBloc<DriverAuthBloc>();
    _driverService = DriverService();

    _driverVehicleBloc.load(true);
    _loadBoard();
    super.initState();
  }

  @override
  void dispose() {
    _driverVehicleBloc?.dispose();
    _textBoardName?.dispose();
    super.dispose();
  }

  _loadBoard() async {
    var driver = await _auth.userInfoFlux.first;
    _textBoardName.text = driver.car.board != null ? driver.car.board : '';
  }

  Future<void> _saveInfo() async {
    Driver driver = await _auth.userInfoFlux.first;
    String typeSelected = (await _driverVehicleBloc.selectCategoryFlux.first);
    String brandSelected = (await _driverVehicleBloc.selectBrandFlux.first);
    String yearSelected = (await _driverVehicleBloc.selectYearFlux.first);
    String colorSelected = (await _driverVehicleBloc.selectColorFlux.first);
    String modelSelected = (await _driverVehicleBloc.selectModelFlux.first);

    if (typeSelected == null || typeSelected == '') {
      ShowSnackBar.build(
          _scaffoldKey, 'It is necessary to select the type of car.', context);
      return;
    }

    if (brandSelected == null || brandSelected == '') {
      ShowSnackBar.build(
          _scaffoldKey, 'It is necessary to select a car brand.', context);
      return;
    }

    if (modelSelected == null || modelSelected == '') {
      ShowSnackBar.build(
          _scaffoldKey, 'It is necessary to select a car model.', context);
      return;
    }

    if (yearSelected == null || yearSelected == '') {
      ShowSnackBar.build(
          _scaffoldKey, 'Car year required.', context);
      return;
    }

    if (colorSelected == null || colorSelected == '') {
      ShowSnackBar.build(
          _scaffoldKey, 'It is necessary to select the car color.', context);
      return;
    }

    final alphanumeric = RegExp(r'[a-zA-Z]{3}[0-9]{4}');
    if (_textBoardName == null ||
        _textBoardName.value == null ||
        _textBoardName.value.text == '' ||
        (_textBoardName.value.text
            .replaceAll('-', '')
            .length != 7) ||
        !alphanumeric.hasMatch(_textBoardName.value.text.replaceAll('-', ''))) {
      ShowSnackBar.build(
          _scaffoldKey, 'It is necessary to add a valid card.', context);
      return;
    }

    var vehicle = Vehicle(
        board: _textBoardName.text,
        brand: brandSelected,
        year: yearSelected,
        color: colorSelected,
        model: modelSelected,
        status: true,
        type: typeSelected == 'Pop' ? CarType.Pop : CarType.Top);

    driver.car = vehicle;

    await _driverService.save(driver);
    _driverService.setStorage(driver);
    _auth.userInfoEvent.add(driver);
    ShowSnackBar.build(
        _scaffoldKey, 'Car data saved successfully.', context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Stack(children: <Widget>[
          SingleChildScrollView(
            child: Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height +
                  (MediaQuery
                      .of(context)
                      .size
                      .height * 0.1),
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              child: Column(
                children: <Widget>[
                  new Center(
                      child: Container(
                        padding: EdgeInsets.only(top: 100.0),
                        child: Column(
                          children: <Widget>[
                            Card(
                              elevation: 30.0,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Container(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.85,
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16.0,
                                                top: 10,
                                                bottom: 25),
                                            child: Text(
                                              'Car Details',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 22),
                                            ),
                                          ),
                                        ],
                                      ),
                                      StreamBuilder(
                                          initialData: List<String>(),
                                          stream: _driverVehicleBloc
                                              .categoryListFlux,
                                          builder: (BuildContext context,
                                              AsyncSnapshot<List<String>>
                                              snapshot) {
                                            if (!snapshot.hasData)
                                              return Container(
                                                  height: 1, width: 1);

                                            List<String> list = snapshot.data;

                                            if (list.length == 0)
                                              return Padding(
                                                padding: const EdgeInsets.all(
                                                    8.0),
                                                child: Container(
                                                  height: 1,
                                                  width: 1,
                                                ),
                                              );

                                            return Padding(
                                              padding: const EdgeInsets.all(
                                                  8.0),
                                              child: InputDecorator(
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  contentPadding:
                                                  EdgeInsets.all(8.0),
                                                ),
                                                child: DropdownButtonHideUnderline(
                                                    child: StreamBuilder(
                                                        initialData: null,
                                                        stream: _driverVehicleBloc
                                                            .selectCategoryFlux,
                                                        builder: (BuildContext
                                                        context,
                                                            AsyncSnapshot<
                                                                String>
                                                            snapshots) {
                                                          return DropdownButton<
                                                              String>(
                                                            elevation: 8,
                                                            hint: Text(
                                                                'Select a Category'),
                                                            iconSize: 24.0,
                                                            isExpanded: true,
                                                            isDense: true,
                                                            value: snapshots
                                                                .data,
                                                            onChanged:
                                                                (
                                                                String category) {
                                                              _driverVehicleBloc
                                                                  .selectBrandEvent
                                                                  .add(null);
                                                              _driverVehicleBloc
                                                                  .selectModelEvent
                                                                  .add(null);
                                                              _driverVehicleBloc
                                                                  .selectCategoryEvent
                                                                  .add(
                                                                  category);
                                                              _driverVehicleBloc
                                                                  .load(false);
                                                            },
                                                            items: (list.map((
                                                                result) =>
                                                                DropdownMenuItem(
                                                                    value:
                                                                    result,
                                                                    child: Text(
                                                                        result))))
                                                                .toList(),
                                                          );
                                                        })),
                                              ),
                                            );
                                          }),
                                      StreamBuilder(
                                          initialData: List<Vehicle>(),
                                          stream: _driverVehicleBloc
                                              .vehicleBrandListFlux,
                                          builder: (BuildContext context,
                                              AsyncSnapshot<List<Vehicle>>
                                              snapshot) {
                                            if (!snapshot.hasData ||
                                                snapshot.connectionState ==
                                                    ConnectionState.waiting)
                                              return Center(
                                                  child: CircularProgressIndicator(
                                                    valueColor: new AlwaysStoppedAnimation<
                                                        Color>(Colors.amber),
                                                  ));


                                            List<Vehicle> list = snapshot.data;

                                            if (list.length == 0)
                                              return Container(
                                                height: 1,
                                                width: 1,
                                              );

                                            return Padding(
                                              padding: const EdgeInsets.all(
                                                  8.0),
                                              child: InputDecorator(
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  contentPadding:
                                                  EdgeInsets.all(8.0),
                                                ),
                                                child: DropdownButtonHideUnderline(
                                                    child: StreamBuilder(
                                                        initialData: null,
                                                        stream: _driverVehicleBloc
                                                            .selectBrandFlux,
                                                        builder: (BuildContext
                                                        context,
                                                            AsyncSnapshot<
                                                                String>
                                                            snapshots) {
                                                          return DropdownButton<
                                                              String>(
                                                            elevation: 8,
                                                            hint: Text(
                                                                'Select a Brand'),
                                                            iconSize: 24.0,
                                                            isExpanded: true,
                                                            isDense: true,
                                                            value: snapshots
                                                                .data,
                                                            onChanged:
                                                                (String brand) {
                                                              _driverVehicleBloc
                                                                  .selectBrandEvent
                                                                  .add(brand);
                                                              _driverVehicleBloc
                                                                  .selectModelEvent
                                                                  .add(null);
                                                              _driverVehicleBloc
                                                                  .load(false);
                                                            },
                                                            items: (list.map((
                                                                result) =>
                                                                DropdownMenuItem(
                                                                    value: result
                                                                        .brand,
                                                                    child: Text(
                                                                        result
                                                                            .brand))))
                                                                .toList(),
                                                          );
                                                        })),
                                              ),
                                            );
                                          }),
                                      StreamBuilder(
                                          initialData: List<Vehicle>(),
                                          stream: _driverVehicleBloc
                                              .vehicleModelListFlux,
                                          builder: (BuildContext context,
                                              AsyncSnapshot<List<Vehicle>>
                                              snapshot) {
                                            if (!snapshot.hasData)
                                              return Container(
                                                  height: 1, width: 1);

                                            List<Vehicle> list = snapshot.data;

                                            if (list.length == 0)
                                              return Padding(
                                                padding: const EdgeInsets.all(
                                                    0.0),
                                                child: Container(
                                                  height: 1,
                                                  width: 1,
                                                ),
                                              );

                                            return Padding(
                                              padding: const EdgeInsets.all(
                                                  8.0),
                                              child: InputDecorator(
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  contentPadding:
                                                  EdgeInsets.all(8.0),
                                                ),
                                                child: DropdownButtonHideUnderline(
                                                    child: StreamBuilder(
                                                        initialData: null,
                                                        stream: _driverVehicleBloc
                                                            .selectModelFlux,
                                                        builder: (BuildContext
                                                        context,
                                                            AsyncSnapshot<
                                                                String>
                                                            snapshots) {
                                                          return DropdownButton<
                                                              String>(
                                                            elevation: 8,
                                                            hint: Text(
                                                                'Select a Model'),
                                                            iconSize: 24.0,
                                                            isExpanded: true,
                                                            isDense: true,
                                                            value: snapshots
                                                                .data,
                                                            onChanged:
                                                                (String model) {
                                                              _driverVehicleBloc
                                                                  .selectModelEvent
                                                                  .add(model);
                                                              _driverVehicleBloc
                                                                  .load(false);
                                                            },
                                                            items: (list.map((
                                                                result) =>
                                                                DropdownMenuItem(
                                                                    value: result
                                                                        .model,
                                                                    child: Text(
                                                                        result
                                                                            .model))))
                                                                .toList(),
                                                          );
                                                        })),
                                              ),
                                            );
                                          }),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: StreamBuilder(
                                            initialData: List<String>(),
                                            stream: _driverVehicleBloc
                                                .vehicleYearListFlux,
                                            builder: (BuildContext context,
                                                AsyncSnapshot<List<String>>
                                                snapshot) {
                                              if (!snapshot.hasData)
                                                return Container(
                                                    height: 1, width: 1);

                                              List<String> list = snapshot.data;

                                              if (list.length == 0)
                                                return Container(
                                                  height: 1,
                                                  width: 1,
                                                );

                                              return InputDecorator(
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  contentPadding:
                                                  EdgeInsets.all(8.0),
                                                ),
                                                child: DropdownButtonHideUnderline(
                                                    child: StreamBuilder(
                                                        initialData: null,
                                                        stream:
                                                        _driverVehicleBloc
                                                            .selectYearFlux,
                                                        builder: (BuildContext
                                                        context,
                                                            AsyncSnapshot<
                                                                String>
                                                            snapshots) {
                                                          return DropdownButton<
                                                              String>(
                                                            elevation: 8,
                                                            hint: Text(
                                                                'Select the year of the vehicle.'),
                                                            iconSize: 24.0,
                                                            isExpanded: true,
                                                            isDense: true,
                                                            value: snapshots
                                                                .data,
                                                            onChanged:
                                                                (String year) {
                                                              _driverVehicleBloc
                                                                  .selectYearEvent
                                                                  .add(year);
                                                              _driverVehicleBloc
                                                                  .buildYear(
                                                                  year);
                                                            },
                                                            items: (list.map((
                                                                result) =>
                                                                DropdownMenuItem(
                                                                    value:
                                                                    result,
                                                                    child: Text(
                                                                        result))))
                                                                .toList(),
                                                          );
                                                        })),
                                              );
                                            }),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: StreamBuilder(
                                            initialData: List<String>(),
                                            stream: _driverVehicleBloc
                                                .vehicleColorListFlux,
                                            builder: (BuildContext context,
                                                AsyncSnapshot<List<String>>
                                                snapshot) {
                                              if (!snapshot.hasData)
                                                return Container(
                                                    height: 1, width: 1);

                                              List<String> list = snapshot.data;

                                              if (list.length == 0)
                                                return Container(
                                                  height: 1,
                                                  width: 1,
                                                );

                                              return InputDecorator(
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  contentPadding:
                                                  EdgeInsets.all(8.0),
                                                ),
                                                child: DropdownButtonHideUnderline(
                                                    child: StreamBuilder(
                                                        initialData: null,
                                                        stream:
                                                        _driverVehicleBloc
                                                            .selectColorFlux,
                                                        builder: (BuildContext
                                                        context,
                                                            AsyncSnapshot<
                                                                String>
                                                            snapshots) {
                                                          return DropdownButton<
                                                              String>(
                                                            elevation: 8,
                                                            hint: Text(
                                                                'Select the color of the vehicle.'),
                                                            iconSize: 24.0,
                                                            isExpanded: true,
                                                            isDense: true,
                                                            value: snapshots
                                                                .data,
                                                            onChanged:
                                                                (String color) {
                                                              _driverVehicleBloc
                                                                  .selectColorEvent
                                                                  .add(color);
                                                              _driverVehicleBloc
                                                                  .buildColor(
                                                                  color);
                                                            },
                                                            items: (list.map((
                                                                result) =>
                                                                DropdownMenuItem(
                                                                    value:
                                                                    result,
                                                                    child: Text(
                                                                        result))))
                                                                .toList(),
                                                          );
                                                        })),
                                              );
                                            }),
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              top: 8,
                                              bottom: 28,
                                              left: 8,
                                              right: 8),
                                          child: InputDecorator(
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              contentPadding: EdgeInsets.only(
                                                  left: 5),
                                            ),
                                            child: TextFormField(

                                              controller: _textBoardName,
                                              onFieldSubmitted: (term) {
                                                _saveInfo();
                                              },
                                              keyboardType: TextInputType.text,
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  color: Colors.black
                                                      .withOpacity(0.7),
                                                  fontFamily:
                                                  FontStyleApp.fontFamily()),
                                              decoration: InputDecoration(
                                                hintText: 'Add a board',
                                                errorStyle: TextStyle(
                                                    fontFamily:
                                                    FontStyleApp.fontFamily()),
                                                border: InputBorder.none,
                                                hintStyle: TextStyle(
                                                    fontFamily:
                                                    FontStyleApp.fontFamily(),
                                                    fontSize: 17.0,
                                                    color: Colors.black
                                                        .withOpacity(0.4)),
                                              ),
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                                margin: EdgeInsets.only(top: 20.0),
                                decoration: new BoxDecoration(
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(25.0)),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: Colors.black,
                                        offset: Offset(0.0, 0.3),
                                        blurRadius: 1.0,
                                      ),
                                    ],
                                    gradient: ColorsStyle.getColorBotton()),
                                child: MaterialButton(
                                    highlightColor: Colors.transparent,
                                    splashColor: Color(0xFFFFFFFF),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 42.0),
                                      child: Text(
                                        "SAVE",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0),
                                      ),
                                    ),
                                    onPressed: () {
                                      _saveInfo();
                                    }))
                          ],
                        ),
                      ))
                ],
              ),
            ),
          ),
          buttonBar(widget.changeDrawer, context)
        ]));
  }
}
