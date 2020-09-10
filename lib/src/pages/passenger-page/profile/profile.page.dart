import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/font_awesome.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:gocar/src/infra/infra.dart';
import 'package:gocar/src/provider/blocs/blocs.dart';
import 'package:gocar/src/provider/services/services.dart';

import '../../pages.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage(this.changeDrawer);

  final ValueChanged<BuildContext> changeDrawer;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController signupEmailController = new TextEditingController();
  TextEditingController signupNameController = new TextEditingController();
  TextEditingController signupAgeController = new TextEditingController();
  PassengerAuthBloc _authBloc;
  PassengerService _passengerBloc;
  Passenger passenger;
  GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  void initState() {
    _authBloc = BlocProvider.getBloc<PassengerAuthBloc>();
    _passengerBloc = PassengerService();
    _scaffoldKey = new GlobalKey<ScaffoldState>();
    _load();
    super.initState();
  }

  _load() async {
    passenger = await _authBloc.userInfoFlux.first;
    signupNameController.text = passenger.name;
    signupEmailController.text = passenger.email;
    signupAgeController.text = passenger.age.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: NotificationListener<OverscrollIndicatorNotification>(
            /*onNotification: (overscroll) {
              overscroll.disallowGlow();
            },*/
            child: Stack(
          children: <Widget>[
            CustomScrollView(slivers: <Widget>[
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.only(top: 125.0),
                  decoration: new BoxDecoration(
                    gradient: ColorsStyle.getColorBackGround(),
                  ),
                  child: Column(
                    children: <Widget>[
                      Center(
                        child: new Image(
                            width: 275.0,
                            height: 150.0,
                            fit: BoxFit.fill,
                            image: new AssetImage(
                                'assets/images/intro/login.png')),
                      ),
                      Form(
                        key: _formKey,
                        child: new Center(
                            child: Container(
                          padding: EdgeInsets.only(top: 15.0),
                          child: Column(
                            children: <Widget>[
                              Stack(
                                alignment: Alignment.topCenter,
                                overflow: Overflow.visible,
                                children: <Widget>[
                                  Card(
                                    elevation: 2.0,
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Container(
                                      width: 300.0,
                                      height: 235.0,
                                      child: Column(
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 5.0,
                                                bottom: 0.0,
                                                left: 25.0,
                                                right: 25.0),
                                            child: TextFormField(
                                              enabled: true,
                                              controller: signupNameController,
                                              keyboardType: TextInputType.text,
                                              textCapitalization:
                                                  TextCapitalization.words,
                                              validator: (value) {
                                                if (value.isEmpty) {
                                                  return "Name field cannot be empty!";
                                                }
                                                return null;
                                              },
                                              style: TextStyle(
                                                  fontFamily:
                                                      FontStyleApp.fontFamily(),
                                                  fontSize: 16.0,
                                                  color: Colors.black),
                                              decoration: InputDecoration(
                                                errorStyle: TextStyle(
                                                    fontFamily: FontStyleApp
                                                        .fontFamily()),
                                                border: InputBorder.none,
                                                icon: Icon(
                                                  FontAwesome.getIconData(
                                                      "user"),
                                                  color: Colors.black,
                                                ),
                                                labelText: "Name",
                                                hintStyle: TextStyle(
                                                    fontFamily: FontStyleApp
                                                        .fontFamily(),
                                                    fontSize: 17.0),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 250.0,
                                            height: 1.0,
                                            color: Colors.grey[400],
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 0.0,
                                                bottom: 0.0,
                                                left: 25.0,
                                                right: 25.0),
                                            child: TextFormField(
                                              enabled: false,
                                              validator: (value) =>
                                                  HelpService.validateEmail(
                                                      value),
                                              controller: signupEmailController,
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              style: TextStyle(
                                                  fontFamily:
                                                      FontStyleApp.fontFamily(),
                                                  fontSize: 16.0,
                                                  color: Colors.black),
                                              decoration: InputDecoration(
                                                errorStyle: TextStyle(
                                                    fontFamily: FontStyleApp
                                                        .fontFamily()),
                                                border: InputBorder.none,
                                                icon: Icon(
                                                  FontAwesome.getIconData(
                                                      "envelope"),
                                                  color: Colors.black,
                                                ),
                                                labelText: "Email",
                                                hintStyle: TextStyle(
                                                    fontFamily: FontStyleApp
                                                        .fontFamily(),
                                                    fontSize: 17.0),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 250.0,
                                            height: 1.0,
                                            color: Colors.grey[400],
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 5.0,
                                                bottom: 0.0,
                                                left: 25.0,
                                                right: 25.0),
                                            child: TextFormField(
                                              controller: signupAgeController,
                                              keyboardType:
                                                  TextInputType.number,
                                              textCapitalization:
                                                  TextCapitalization.words,
                                              validator: (value) {
                                                if (value.isEmpty) {
                                                  return "Age field cannot be empty!";
                                                }
                                                return null;
                                              },
                                              style: TextStyle(
                                                  fontFamily:
                                                      FontStyleApp.fontFamily(),
                                                  fontSize: 16.0,
                                                  color: Colors.black),
                                              decoration: InputDecoration(
                                                errorStyle: TextStyle(
                                                    fontFamily: FontStyleApp
                                                        .fontFamily()),
                                                border: InputBorder.none,
                                                icon: Icon(
                                                  FontAwesome.getIconData(
                                                      "birthday-cake"),
                                                  color: Colors.black,
                                                ),
                                                labelText: "Age",
                                                hintStyle: TextStyle(
                                                    fontFamily: FontStyleApp
                                                        .fontFamily(),
                                                    fontSize: 17.0),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 250.0,
                                            height: 1.0,
                                            color: Colors.grey[400],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                      margin: EdgeInsets.only(top: 220.0),
                                      decoration: new BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(25.0)),
                                          boxShadow: <BoxShadow>[
                                            BoxShadow(
                                              color: Colors.black,
                                              offset: Offset(0.0, 0.3),
                                              blurRadius: 1.0,
                                            ),
                                          ],
                                          gradient:
                                              ColorsStyle.getColorBotton()),
                                      child: MaterialButton(
                                          highlightColor: Colors.transparent,
                                          splashColor: Color(0xFFFFFFFF),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10.0,
                                                horizontal: 42.0),
                                            child: Text(
                                              "SAVE",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16.0),
                                            ),
                                          ),
                                          onPressed: () {
                                            if (!_formKey.currentState
                                                .validate()) {
                                              ShowSnackBar.build(
                                                  _scaffoldKey,
                                                  'All fields must be filled in!',
                                                  context);
                                              return;
                                            }
                                            int age = int.parse(
                                                signupAgeController
                                                    .value.text);

                                            if (age < 10) {
                                              ShowSnackBar.build(
                                                  _scaffoldKey,
                                                  'User cannot be less than 10 years old!',
                                                  context);

                                              setState(() {
                                                signupAgeController.text =
                                                    passenger.age.toString();
                                              });
                                              return;
                                            }

                                            passenger.age = age;
                                            passenger.name =
                                                signupNameController.text;
                                            _passengerBloc
                                                .save(passenger)
                                                .then((r) {
                                              _passengerBloc
                                                  .setStorage(passenger);
                                              _authBloc
                                                  .refreshAuth()
                                                  .then((result) {
                                                ShowSnackBar.build(
                                                    _scaffoldKey,
                                                    'Age saved successfully!',
                                                    context);
                                              });
                                            });
                                          }))
                                ],
                              ),
                            ],
                          ),
                        )),
                      )
                    ],
                  ),
                ),
              )
            ]),
            buttonBar(widget.changeDrawer, context),
          ],
        )));
  }
}
