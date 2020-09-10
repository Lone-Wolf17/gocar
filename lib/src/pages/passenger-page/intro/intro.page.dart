import 'package:flutter/material.dart';
import 'package:gocar/src/infra/infra.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';

import 'widgets/pageview.widget.dart';

class PassengerIntroPage extends StatefulWidget {
  @override
  _PassengerIntroPageState createState() => _PassengerIntroPageState();
}

class _PassengerIntroPageState extends State<PassengerIntroPage> {
  final pages = [
    PageviewWidget.buildViewModel(
        'assets/images/intro/pick.png',
        'assets/images/intro/driver.png',
        'Your travel platform, simple and safe.'),
    PageviewWidget.buildViewModel('assets/images/intro/pick.png',
        'assets/images/intro/time.png', 'Make your trips.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: IntroViewsFlutter(pages,
          doneText:
              const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
          showNextButton: true,
          pageButtonsColor: Colors.black,
          pageButtonTextSize: 18,
          showBackButton: true,
          nextText: const Text(
            "NEXT",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          skipText:
              const Text("JUMP", style: TextStyle(fontWeight: FontWeight.bold)),
          backText: const Text("RETURN",
              style: TextStyle(fontWeight: FontWeight.bold)),
          onTapSkipButton: () => DriverPagesNavigation.goToAccount(context),
          onTapDoneButton: () => DriverPagesNavigation.goToAccount(context),
          pageButtonTextStyles: const TextStyle(color: Colors.black)),
    ); //Material App
  }
}
