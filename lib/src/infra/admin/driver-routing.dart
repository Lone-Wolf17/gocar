import 'package:flutter/material.dart';
import 'package:gocar/src/pages/driver-page/pages.dart';
import 'package:gocar/src/pages/driver-page/recover-password/recoverpassword.page.dart';

final driverRoutesConfig = <String, WidgetBuilder>{
  "/intro": (BuildContext context) => DriverIntroPage(),
  "/account": (BuildContext context) => DriverAccountPage(),
  "/recoveryPass": (BuildContext context) => DriverRecoverPasswordPage(),
  "/homeTab": (BuildContext context) => DriverHomeTabPage(),
};

class DriverPagesNavigation {
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
