import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gocar/src/infra/infra.dart';
import 'package:gocar/src/provider/provider.dart';

import '../../../pages.dart';


class RegisterAccount extends StatefulWidget {
  LoadingBloc _baseBloc;
  GlobalKey<ScaffoldState> _scaffoldLoginKey;

  RegisterAccount(this._baseBloc, this._scaffoldLoginKey);

  @override
  _RegisterAccountState createState() => _RegisterAccountState();
}

class _RegisterAccountState extends State<RegisterAccount> {
  final FocusNode focusPassword = FocusNode();
  final FocusNode focusEmail = FocusNode();
  final FocusNode focusName = FocusNode();
  final FocusNode focusAge = FocusNode();
  PassengerAuthBloc _auth;
  bool _obscureTextSignUp = true;
  bool _obscureTextSignUpConfirm = true;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController signUpEmailController = new TextEditingController();
  TextEditingController signUpNameController = new TextEditingController();
  TextEditingController signUpAgeController = new TextEditingController();
  TextEditingController signUpPasswordController = new TextEditingController();
  TextEditingController signUpConfirmPasswordController =
      new TextEditingController();

  @override
  void initState() {
    _auth = PassengerAuthBloc();
    super.initState();
  }

  @override
  void dispose() {
    focusPassword?.dispose();
    focusEmail?.dispose();
    focusName?.dispose();
    super.dispose();
  }

  void _toggleSignUp() {
    setState(() {
      _obscureTextSignUp = !_obscureTextSignUp;
    });
  }

  void _toggleSignUpConfirm() {
    setState(() {
      _obscureTextSignUpConfirm = !_obscureTextSignUpConfirm;
    });
  }

  void _registerWithEmailPass(BuildContext mContext) {
    if (_formKey.currentState.validate()) {
      widget._baseBloc.loadingStatusEvent.add(true);

      _auth
          .registerWithEmailPassword(
          name: signUpNameController.value.text,
          email: signUpEmailController.value.text,
          password: signUpPasswordController.value.text,
          age: int.parse(signUpAgeController.value.text))
          .then((r) {
        widget._baseBloc.loadingStatusEvent.add(false);
        _functionResetFields();
        ShowSnackBar.build(
            widget._scaffoldLoginKey,
            'Congratulations, User created successfully !!', context);
      }, onError: (ex) {
        widget._baseBloc.loadingStatusEvent.add(false);
        switch (ex.code) {
          case "ERROR_EMAIL_ALREADY_IN_USE":
            ShowSnackBar.build(
                widget._scaffoldLoginKey,
                'Attention, There is already a user with this email!', context);
            break;
          case "ERROR_INVALID_EMAIL":
            ShowSnackBar.build(
                widget._scaffoldLoginKey, 'Attention, Invalid email!', context);

            break;
          default:
            ShowSnackBar.build(widget._scaffoldLoginKey,
                'Sorry, an unknown error has occurred!', context);
            break;
        }
      });
    }
  }

  void _functionResetFields() {
    signUpPasswordController.text = "";
    signUpEmailController.text = "";
    signUpNameController.text = "";
    signUpAgeController.text = "";
    signUpConfirmPasswordController.text = "";
    setState(() {
      _formKey = GlobalKey<FormState>();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.only(top: 23.0),
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
                    height: 380.0,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              top: 5.0, bottom: 0.0, left: 25.0, right: 25.0),
                          child: TextFormField(
                            focusNode: focusName,
                            controller: signUpNameController,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Name field cannot be empty!";
                              }
                              return null;
                            },
                            style: TextStyle(
                                fontFamily: FontStyleApp.fontFamily(),
                                fontSize: 16.0,
                                color: Colors.black),
                            decoration: InputDecoration(
                              errorStyle: TextStyle(
                                  fontFamily: FontStyleApp.fontFamily()),
                              border: InputBorder.none,
                              icon: Icon(
                                FontAwesome.getIconData("user"),
                                color: Colors.black,
                              ),
                              labelText: "Name",
                              hintStyle: TextStyle(
                                  fontFamily: FontStyleApp.fontFamily(),
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
                              top: 5.0, bottom: 0.0, left: 25.0, right: 25.0),
                          child: TextFormField(
                            focusNode: focusAge,
                            controller: signUpAgeController,
                            keyboardType: TextInputType.number,
                            textCapitalization: TextCapitalization.words,
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Age field cannot be empty!";
                              }
                              return null;
                            },
                            style: TextStyle(
                                fontFamily: FontStyleApp.fontFamily(),
                                fontSize: 16.0,
                                color: Colors.black),
                            decoration: InputDecoration(
                              errorStyle: TextStyle(
                                  fontFamily: FontStyleApp.fontFamily()),
                              border: InputBorder.none,
                              icon: Icon(
                                FontAwesome.getIconData("birthday-cake"),
                                color: Colors.black,
                              ),
                              labelText: "Age",
                              hintStyle: TextStyle(
                                  fontFamily: FontStyleApp.fontFamily(),
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
                              top: 0.0, bottom: 0.0, left: 25.0, right: 25.0),
                          child: TextFormField(
                            validator: (value) =>
                                HelpService.validateEmail(value),
                            focusNode: focusEmail,
                            controller: signUpEmailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                                fontFamily: FontStyleApp.fontFamily(),
                                fontSize: 16.0,
                                color: Colors.black),
                            decoration: InputDecoration(
                              errorStyle: TextStyle(
                                  fontFamily: FontStyleApp.fontFamily()),
                              border: InputBorder.none,
                              icon: Icon(
                                FontAwesome.getIconData("envelope"),
                                color: Colors.black,
                              ),
                              labelText: "Email",
                              hintStyle: TextStyle(
                                  fontFamily: FontStyleApp.fontFamily(),
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
                              top: 0.0, bottom: 0.0, left: 25.0, right: 25.0),
                          child: TextFormField(
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Password cannot be empty!";
                              }

                              if (value !=
                                  signUpConfirmPasswordController.text) {
                                return "Password does not match!";
                              }
                              return null;
                            },
                            focusNode: focusPassword,
                            controller: signUpPasswordController,
                            obscureText: _obscureTextSignUp,
                            style: TextStyle(
                                fontFamily: FontStyleApp.fontFamily(),
                                fontSize: 16.0,
                                color: Colors.black),
                            decoration: InputDecoration(
                              errorStyle: TextStyle(
                                  fontFamily: FontStyleApp.fontFamily()),
                              border: InputBorder.none,
                              icon: Icon(
                                FontAwesome.getIconData("lock"),
                                color: Colors.black,
                              ),
                              labelText: "Password",
                              hintStyle: TextStyle(
                                  fontFamily: FontStyleApp.fontFamily(),
                                  fontSize: 17.0),
                              suffixIcon: GestureDetector(
                                onTap: _toggleSignUp,
                                child: Icon(
                                  FontAwesome.getIconData("eye"),
                                  size: 15.0,
                                  color: Colors.black,
                                ),
                              ),
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
                              top: 0, bottom: 0.0, left: 25.0, right: 25.0),
                          child: TextField(
                            controller: signUpConfirmPasswordController,
                            obscureText: _obscureTextSignUpConfirm,
                            onTap: _toggleSignUpConfirm,
                            style: TextStyle(
                                fontFamily: FontStyleApp.fontFamily(),
                                fontSize: 16.0,
                                color: Colors.black),
                            decoration: InputDecoration(
                              errorStyle: TextStyle(
                                  fontFamily: FontStyleApp.fontFamily()),
                              border: InputBorder.none,
                              icon: Icon(
                                FontAwesome.getIconData("lock"),
                                color: Colors.black,
                              ),
                              labelText: "Confirm",
                              hintStyle: TextStyle(
                                  fontFamily: FontStyleApp.fontFamily(),
                                  fontSize: 17.0),
                              suffixIcon: GestureDetector(
                                onTap: () => {},
                                child: Icon(
                                  FontAwesome.getIconData("eye"),
                                  size: 15.0,
                                  color: Colors.black,
                                ),
                              ),
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
                    margin: EdgeInsets.only(top: 360.0),
                    decoration: new BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
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
                            "REGISTER",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        onPressed: () => _registerWithEmailPass(context))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
