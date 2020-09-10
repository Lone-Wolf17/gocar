import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/feather.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:gocar/src/infra/infra.dart';
import 'package:gocar/src/provider/blocs/blocs.dart';
import 'package:gocar/src/provider/provider.dart';
import 'package:line_icons/line_icons.dart';

import '../../../pages.dart';

class ReportRegisterPage extends StatefulWidget {
  String reportId;

  ReportRegisterPage(this.reportId);

  @override
  _ReportRegisterPageState createState() => _ReportRegisterPageState();
}

class _ReportRegisterPageState extends State<ReportRegisterPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _textFood =
      MoneyMaskedTextController(decimalSeparator: '.');
  TextEditingController _textGasoline =
      MoneyMaskedTextController(decimalSeparator: '.');
  TextEditingController _textMaintenance =
      MoneyMaskedTextController(decimalSeparator: '.');
  DriverAuthBloc _auth;
  ReportService _reportService;
  Driver _driver;
  DriverReportBloc _reportBloc;

  _loadPlaca() async {
    _driver = await _auth.userInfoFlux.first;

    if (widget.reportId != null) {
      var report = await _reportService.getById(widget.reportId);
      _textMaintenance.text = report.carMaintenance.toString();
      _textGasoline.text = report.gasoline.toString();
      _textFood.text = report.food.toString();
    } else {
      _textFood.text = '';
      _textMaintenance.text = '';
      _textGasoline.text = '';
    }
  }

  @override
  void initState() {
    _reportBloc = DriverReportBloc();
    _reportService = ReportService();
    _auth = BlocProvider.getBloc<DriverAuthBloc>();
    _loadPlaca();
    super.initState();
  }

  @override
  void dispose() {
    _textFood?.dispose();
    _reportBloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              LineIcons.arrow_left,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          automaticallyImplyLeading: true,
        ),
        body: Scaffold(
            key: _scaffoldKey,
            body: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height +
                    (MediaQuery.of(context).size.height * 0.1),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: <Widget>[
                    new Center(
                        child: Container(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Column(
                        children: <Widget>[
                          Card(
                            elevation: 30.0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.85,
                              child: Form(
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 16.0, top: 10, bottom: 25),
                                          child: Row(
                                            children: <Widget>[
                                              Text(
                                                'SPENDING',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 22),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5),
                                                child: Icon(
                                                  Feather.getIconData(
                                                      'dollar-sign'),
                                                  size: 28,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
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
                                            contentPadding:
                                                EdgeInsets.only(left: 5),
                                          ),
                                          child: TextFormField(
                                            controller: _textFood,
                                            /* inputFormatters: [
                                              WhitelistingTextInputFormatter.digitsOnly,
                                              // Fit the validating format.
                                              //make the formatter for money
                                              new CurrencyInputFormatter()
                                            ],*/
                                            onFieldSubmitted: (term) {
                                              _save();
                                            },
                                            keyboardType: TextInputType.number,
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                color: Colors.black
                                                    .withOpacity(0.7),
                                                fontFamily:
                                                    FontStyleApp.fontFamily()),
                                            decoration: InputDecoration(
                                              hintText: 'Food Expenditures',
                                              errorStyle: TextStyle(
                                                  fontFamily: FontStyleApp
                                                      .fontFamily()),
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
                                    Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8,
                                            bottom: 28,
                                            left: 8,
                                            right: 8),
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            contentPadding:
                                                EdgeInsets.only(left: 5),
                                          ),
                                          child: TextFormField(
                                            controller: _textMaintenance,
                                            onFieldSubmitted: (term) {
                                              _save();
                                            },
                                            keyboardType: TextInputType.number,
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                color: Colors.black
                                                    .withOpacity(0.7),
                                                fontFamily:
                                                FontStyleApp.fontFamily()),
                                            decoration: InputDecoration(
                                              hintText:
                                              'Maintenance Expenses',
                                              errorStyle: TextStyle(
                                                  fontFamily: FontStyleApp
                                                      .fontFamily()),
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
                                    Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8,
                                            bottom: 28,
                                            left: 8,
                                            right: 8),
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            contentPadding:
                                                EdgeInsets.only(left: 5),
                                          ),
                                          child: TextFormField(
                                            controller: _textGasoline,
                                            onFieldSubmitted: (term) {
                                              _save();
                                            },
                                            keyboardType: TextInputType.number,
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                color: Colors.black
                                                    .withOpacity(0.7),
                                                fontFamily:
                                                FontStyleApp.fontFamily()),
                                            decoration: InputDecoration(
                                              hintText: 'Gasoline Expenses',
                                              errorStyle: TextStyle(
                                                  fontFamily: FontStyleApp
                                                      .fontFamily()),
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
                                    _save();
                                  }))
                        ],
                      ),
                        ))
                  ],
                ),
              ),
            )));
  }

  _save() async {
    if (_textFood == null ||
        _textFood.text == null ||
        _textFood.value.text == '' ||
        _textFood.value.text == null ||
        _textFood.value.text.length > 6) {
      if (_textFood.value.text.length > 6)
        ShowSnackBar.build(
            _scaffoldKey, 'The maximum allowed value is 70,000 Naira.',
            context);
      else
        ShowSnackBar.build(
            _scaffoldKey, 'It is necessary to add value to field food.',
            context);
      return;
    }

    if (_textGasoline == null ||
        _textGasoline.text == null ||
        _textGasoline.value.text == '' ||
        _textGasoline.value.text == null ||
        _textGasoline.value.text.length > 6) {
      if (_textGasoline.value.text.length > 6)
        ShowSnackBar.build(
            _scaffoldKey, 'The maximum allowed value is 70,000 Naira.',
            context);
      else
        ShowSnackBar.build(_scaffoldKey,
            'You are required to add gasoline field value.', context);
      return;
    }
    if (_textMaintenance == null ||
        _textMaintenance.text == null ||
        _textMaintenance.value.text == '' ||
        _textMaintenance.value.text == null ||
        _textMaintenance.value.text.length > 6) {
      if (_textMaintenance.value.text.length > 6)
        ShowSnackBar.build(
            _scaffoldKey, 'The maximum allowed value is 70,000 Naira.',
            context);
      else
        ShowSnackBar.build(_scaffoldKey,
            'It is necessary to add maintenance field value.', context);
      return;
    }

    await _reportService.save(Report(
        food: double.tryParse(_textFood.value.text),
        driverId: _driver.id,
        id: widget.reportId,
        gasoline: double.tryParse(_textGasoline.value.text),
        carMaintenance: double.tryParse(_textMaintenance.value.text)));

    await _reportBloc.loadReportsByDriver();

    ShowSnackBar.build(_scaffoldKey, 'Data saved successfully.', context);
    Future.delayed(const Duration(milliseconds: 1000), () {
      Navigator.of(context).pop();
    });
  }
}

/*class CurrencyInputFormatter extends TextInputFormatter {

  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {

    if(newValue.selection.baseOffset == 0){
      print(true);
      return newValue;
    }

    double value = double.parse(newValue.text);

    final formatter = new NumberFormat("###,###.###", "pt-br");

    String newText = formatter.format(value/100);

    return newValue.copyWith(
        text: newText,
        selection: new TextSelection.collapsed(offset: newText.length));
  }
}*/
