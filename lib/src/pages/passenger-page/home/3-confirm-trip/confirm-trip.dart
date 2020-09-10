import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:gocar/src/infra/infra.dart';
import 'package:gocar/src/provider/provider.dart';

class ConfrimPassengerTrip extends StatelessWidget {
  PassengerHomeBloc _homeBloc = BlocProvider.getBloc<PassengerHomeBloc>();
  BasePassengerBloc _baseBloc = BlocProvider.getBloc<BasePassengerBloc>();

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height * 0.35;
    var width = MediaQuery.of(context).size.width;
    return Positioned(
        height: height,
        width: width,
        bottom: 0,
        child: StreamBuilder(
            stream: _baseBloc.tripFlow,
            builder: (BuildContext context, AsyncSnapshot<Trip> snapshot) {
              if (!snapshot.hasData) {
                return Container(height: 1, width: 1);
              }

              Trip trip = snapshot.data;

              return StreamBuilder(
                  stream: _homeBloc.carTypeFlux,
                  builder:
                      (BuildContext context, AsyncSnapshot snapshotViagem) {
                    if (!snapshotViagem.hasData) {
                      return Container(height: 1, width: 1);
                    }

                    CarType carType = snapshotViagem.data ?? CarType.Pop;

                    return Container(
                      color: Colors.white,
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              _buildStep(
                                  carType.index == 0
                                      ? 'assets/images/car/normal.png'
                                      : 'assets/images/car/normal_native.png',
                                  trip,
                                  'POP',
                                  carType.index == 0,
                                  CarType.Pop),
                              _buildStep(
                                  carType.index == 0
                                      ? 'assets/images/car/taxi_native.png'
                                      : 'assets/images/car/taxi.png',
                                  trip,
                                  'TOP',
                                  carType.index == 1,
                                  CarType.Top),
                            ],
                          ),
                          Container(
                              width: width * 0.9,
                              margin: EdgeInsets.only(top: 10.0),
                              decoration: new BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
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
                                      "Confirm",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0),
                                    ),
                                  ),
                                  onPressed: () async {
                                    trip.carType = carType;
                                    _homeBloc.stepProcessEvent.add(
                                        StepPassengerHome.LookingForADriver);
                                    await _baseBloc.orchestration();
                                  }))
                        ],
                      ),
                    );
                  });
            })
      /* */
    );
  }

  Widget _buildStep(String url, Trip trip, String title, bool status,
      CarType carType) =>
      InkWell(
        onTap: () {
          _homeBloc.carTypeEvent.add(carType);
        },
        child: Container(
          margin: EdgeInsets.only(top: 25),
          child: Column(
            children: <Widget>[
              CircleAvatar(
                radius: 30.0,
                backgroundColor: Color(0xFFEBF5FB).withOpacity(0.5),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Image.asset(url),
                      ],
                    )
                  ],
                ),
              ),
              Container(
                  alignment: Alignment.center,
                  child: Text(
                    title,
                    style: TextStyle(color: Colors.white),
                  ),
                  height: 20,
                  width: 40,
                  decoration: new BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(0.0, 0.3),
                          blurRadius: 1.0,
                        ),
                      ],
                      gradient: LinearGradient(
                          colors: status
                              ? [Colors.orange, Colors.orange]
                              : [Colors.white70, Colors.white70],
                          tileMode: TileMode.repeated))),
              Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                    "R\$${(CarType.Pop == carType ? trip.valuePop : trip
                        .valueTop).toStringAsFixed(2)}  ",
                    /*"\$\8.05  "*/
                    style: TextStyle(
                        fontFamily: 'roboto',
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                        color: status
                            ? Colors.black
                            : Colors.black.withOpacity(0.2))),
              ),
              Padding(
                padding: EdgeInsets.only(top: 0),
                child: Text(trip.time,
                    /*"\$\8.05  "*/
                    style: TextStyle(
                        fontSize: 14.0,
                        fontFamily: 'roboto',
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                        color: status
                            ? Colors.black
                            : Colors.black.withOpacity(0.2))),
              ),
            ],
          ),
        ),
      );
}
