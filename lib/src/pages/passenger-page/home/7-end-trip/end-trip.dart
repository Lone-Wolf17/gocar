import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:gocar/src/provider/blocs/blocs.dart';
import 'package:gocar/src/provider/provider.dart';

import '../../../pages.dart';

class TripFinalizedWidget extends StatelessWidget {
  GlobalKey<ScaffoldState> scaffoldKey;

  TripFinalizedWidget(this.scaffoldKey);

  PassengerHomeBloc _homeBloc = BlocProvider.getBloc<PassengerHomeBloc>();
  BasePassengerBloc _baseBloc = BlocProvider.getBloc<BasePassengerBloc>();

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 2000), () async {
      ShowSnackBar.build(scaffoldKey, 'Successful trip!', context);

      _homeBloc.stepProcessEvent.add(StepPassengerHome.Start);
      await _baseBloc.orchestration();
    });

    return Container(height: 1, width: 1);
  }
}
