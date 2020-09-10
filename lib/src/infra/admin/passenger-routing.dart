import 'package:flutter/material.dart';
import 'package:gocar/src/pages/passenger-page/pages.dart';

final passengerRoutesConfig = <String, WidgetBuilder>{
  "/intro": (BuildContext context) => PassengerIntroPage(),
  "/account": (BuildContext context) => PassengerAccountPage(),
  "/recoveryPass": (BuildContext context) => PassengerRecoverPasswordPage(),
  "/homeTab": (BuildContext context) => PassengerHomeTabPage(),
};

class PassengerPagesNavigation {
  static void goToIntroReplacementNamed(BuildContext context) {
    Navigator.pushReplacementNamed(context, "/intro");
  }

  static void goToAccount(BuildContext context) {
    Navigator.pushReplacementNamed(context, "/account");
  }

  static void goToRecoveryPass(BuildContext context) {
    Navigator.pushNamed(context, "/recoveryPass");
  }

  static void goToHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, "/homeTab");
  }

  static void goToStartTrip(BuildContext context) {
    Navigator.pushNamed(context, "/startTrip");
  }
}
