import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/feather.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:gocar/src/infra/infra.dart';
import 'package:gocar/src/provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:line_icons/line_icons.dart';

class SelectOriginDestinationWidget extends StatefulWidget {
  @override
  _SelectOriginDestinationWidgetState createState() =>
      _SelectOriginDestinationWidgetState();
}

class _SelectOriginDestinationWidgetState
    extends State<SelectOriginDestinationWidget> {
  TextEditingController originController = new TextEditingController();
  TextEditingController destinationController = new TextEditingController();
  final FocusNode originFocus = FocusNode();
  final FocusNode destinationFocus = FocusNode();
  BasePassengerBloc _baseBloc;
  AutoCompleteBloc _autoCompleteBloc;
  GoogleService _googleService;
  PassengerHomeBloc _homeBloc;
  PassengerAuthBloc _authBloc;

  @override
  void dispose() {
    originController?.dispose();
    destinationController?.dispose();
    originFocus?.dispose();
    destinationFocus?.dispose();
    _autoCompleteBloc?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _authBloc = BlocProvider.getBloc<PassengerAuthBloc>();
    _homeBloc = BlocProvider.getBloc<PassengerHomeBloc>();
    _baseBloc = BlocProvider.getBloc<BasePassengerBloc>();
    _autoCompleteBloc = AutoCompleteBloc();
    _googleService = GoogleService();
    _authBloc.refreshAuth();
    _load();
    super.initState();
  }

  /*when starting, this screen obtains the values ​​of the destination and current source of the screen and adds the input */
  _load() async {
    MapProvider provide = await _baseBloc.mapProviderFlux.first;
    originController.text = provide.originAddress;
    _autoCompleteBloc.localEventList.add(List<Local>());
    destinationController.text = '';
  }

  /*checks if the source and destination is properly added and if it has started the process*/
  _validateNextStep() async {
    MapProvider provider = await _baseBloc.mapProviderFlux.first;

    if (provider.originAddress.isNotEmpty &&
        provider.destinationAddress.isNotEmpty &&
        originController.value.text != '' &&
        destinationController.value.text != '') {
      /*get the distance*/
      _googleService
          .getDistance(provider.originLatLng, provider.destinationLatLng)
          .then((result) async {
        Trip trip = Trip(
            status: TripStatus.Open,
            destinationAddress: destinationController.value.text,
            destinationMainAddress: destinationController.value.text,
            destinationLatitude: provider.destinationLatLng.latitude,
            destinationLongitude: provider.destinationLatLng.longitude,
            originAddress: originController.value.text,
            originMainAddress: originController.value.text,
            originLatitude: provider.originLatLng.latitude,
            originLongitude: provider.originLatLng.longitude,
            distance: result.distance,
            time: result.time,
            valueTop: result.value + (result.value * 0.20),
            valuePop: result.value);

        _baseBloc.tripEvent.add(trip);
        _homeBloc.carTypeEvent.add(CarType.Pop);
        _homeBloc.stepProcessEvent.add(StepPassengerHome.ConfirmValue);
        await _baseBloc.orchestration();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          bottom: new PreferredSize(
            preferredSize: const Size.fromHeight(125.0),
            child: Container(
              color: Colors.white,
              child: new Padding(
                padding: new EdgeInsets.only(
                  bottom: 10.0,
                  left: 10.0,
                  right: 10.0,
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      child: new IconButton(
                        icon: Icon(
                          LineIcons.arrow_left,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          _homeBloc.stepProcessEvent
                              .add(StepPassengerHome.Start);
                          _baseBloc.orchestration();
                        },
                      ),
                      width: double.infinity,
                      alignment: Alignment.topLeft,
                      height: 40,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 0.0, bottom: 0.0, left: 5.0, right: 0.0),
                      child: TextField(
                        focusNode: originFocus,
                        controller: originController,
                        onChanged: (value) {
                          if (value != null && value.isNotEmpty)
                            _autoCompleteBloc.searchEvent
                                .add(Filter(value, LocalReference.Origin));
                        },
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black,
                            fontFamily: FontStyleApp.fontFamily()),
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                WidgetsBinding.instance.addPostFrameCallback(
                                    (_) => originController.clear());
                                _autoCompleteBloc.localEventList
                                    .add(List<Local>());
                              }),
                          border: InputBorder.none,
                          labelText: "Place of Departure ?",
                          hintStyle: TextStyle(
                              fontFamily: FontStyleApp.fontFamily(),
                              fontSize: 18.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 0.0, bottom: 0.0, left: 5.0, right: 0.0),
                      child: TextField(
                        focusNode: destinationFocus,
                        controller: destinationController,
                        onChanged: (value) {
                          if (value != null && value.isNotEmpty)
                            _autoCompleteBloc.searchEvent
                                .add(Filter(value, LocalReference.Destination));
                        },
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black,
                            fontFamily: FontStyleApp.fontFamily()),
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                _autoCompleteBloc.localEventList
                                    .add(List<Local>());
                                WidgetsBinding.instance.addPostFrameCallback(
                                        (_) => destinationController.clear());
                                return false;
                              }),
                          border: InputBorder.none,
                          labelText: "Where ?",
                          hintStyle: TextStyle(
                              fontFamily: FontStyleApp.fontFamily(),
                              fontSize: 18.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder(
                  stream: _authBloc.userInfoFlux,
                  builder: (BuildContext context,
                      AsyncSnapshot<Passenger> snapshot) {
                    if (!snapshot.hasData)
                      return Container(height: 1, width: 1,);

                    Passenger passenger = snapshot.data;

                    if ((passenger.home != null &&
                        passenger.home.name != null) ||
                        (passenger.work != null &&
                            passenger.work.name != null)) {
                      return Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        height: MediaQuery
                            .of(context)
                            .size
                            .height * 0.10,
                        child: Row(
                          children: <Widget>[
                            _buildLocal(LocaleType.Home),
                            _buildLocal(LocaleType.Work),
                          ],
                        ),
                      );
                    } else {
                      return Container(height: 1, width: 1);
                    }
                  }),
              Container(
                height: 255,
                constraints: BoxConstraints(minWidth: 230.0, minHeight: 25.0),
                child: StreamBuilder(
                    stream: _autoCompleteBloc.localListFlux,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Local>> snapshot) {
                      if (!snapshot.hasData || snapshot.data.length == 0) {
                        return Container(height: 1, width: 1);
                      }

                      return ListView(
                        scrollDirection: Axis.vertical,
                        padding: EdgeInsets.all(8.0),
                        children: snapshot.data
                            .map((data) => GestureDetector(
                                  onTap: () {
                                    LatLng latLng =
                                    LatLng(data.latitude, data.longitude);

                                    if (data.reference ==
                                        LocalReference.Origin) {
                                      originController.text = data.name;
                                      _baseBloc.refreshProvider(latLng,
                                          data.name, LocalReference.Origin);
                                    } else {
                                      _baseBloc.refreshProvider(latLng,
                                          data.name,
                                          LocalReference.Destination);
                                      destinationController.text = data.name;
                                    }
                                    _autoCompleteBloc.localEventList
                                        .add(List<Local>());
                                    _validateNextStep();
                                  },
                                  child: ListTile(
                                    leading: Icon(Icons.location_on),
                                    title: Text(
                                      data.name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(data.address),
                                  ),
                        ))
                            .toList(),
                      );
                    }),
              )
            ],
          ),
        ));
  }

  _buildLocal(LocaleType localeTye) =>
      StreamBuilder(
          stream: _authBloc.userInfoFlux,
          builder: (BuildContext context, AsyncSnapshot<Passenger> snapshot) {
            if (!snapshot.hasData)
              return Expanded(
                  child: Container(
                    height: 1,
                    width: 1,
                  ));

            Passenger passenger = snapshot.data;

            if (LocaleType.Home == localeTye &&
                (passenger.home == null || passenger.home.name == null))
              return Container(height: 1, width: 1);

            if (LocaleType.Work == localeTye &&
                (passenger.work == null || passenger.work.name == null))
              return Container(height: 1, width: 1);

            return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (localeTye == LocaleType.Home) {
                      LatLng latLng =
                      LatLng(passenger.home.latitude, passenger.home.longitude);

                      if (originFocus.hasFocus) {
                        _baseBloc.refreshProvider(
                            latLng, passenger.home.name, LocalReference.Origin);
                        originController.text = passenger.home.name;
                      } else {
                        _baseBloc.refreshProvider(
                            latLng, passenger.home.name,
                            LocalReference.Destination);
                        destinationController.text = passenger.home.name;
                      }

                      _autoCompleteBloc.localEventList.add(List<Local>());
                      _validateNextStep();
            } else {
                      LatLng latLng = LatLng(
                          passenger.work.latitude, passenger.work.longitude);

                      if (originFocus.hasFocus) {
                        _baseBloc.refreshProvider(
                            latLng, passenger.work.name, LocalReference.Origin);
                        originController.text = passenger.work.name;
                      } else {
                        _baseBloc.refreshProvider(
                            latLng, passenger.work.name,
                            LocalReference.Destination);
                        destinationController.text = passenger.work.name;
                      }
                      _autoCompleteBloc.localEventList.add(List<Local>());
                      _validateNextStep();
            }
          },
          child: Container(
            margin: LocaleType.Home == localeTye
                ? EdgeInsets.only(left: 5)
                : EdgeInsets.only(right: 5),
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(width: 0.1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Icon(
                        Feather.getIconData(
                            localeTye == LocaleType.Home
                                ? 'home'
                                : 'briefcase'),
                        color: Colors.black54)),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: LocaleType.Home == localeTye
                          ? (passenger.home != null &&
                          passenger.home.name != null
                          ? EdgeInsets.only(top: 5, left: 10)
                          : EdgeInsets.only(top: 15, left: 10))
                          : (passenger.work != null &&
                          passenger.work.name != null
                          ? EdgeInsets.only(top: 5, left: 10)
                          : EdgeInsets.only(top: 15, left: 10)),
                      child: Text(
                        localeTye == LocaleType.Home ? 'Home' : 'Work',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    (LocaleType.Home == localeTye &&
                        passenger.home != null &&
                        passenger.home.name != null)
                        ? Padding(
                      padding: const EdgeInsets.only(top: 5, left: 10),
                      child: Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.36,
                        child: Text(
                          passenger.home.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    )
                        : Container(
                      height: 1,
                      width: 1,
                    ),
                    (LocaleType.Work == localeTye &&
                        passenger.work != null &&
                        passenger.home.name != null)
                        ? Padding(
                      padding: const EdgeInsets.only(top: 5, left: 10),
                      child: Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.36,
                        child: Text(
                          passenger.work.name,
                          maxLines: 1,
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    )
                        : Container(
                            height: 1,
                            width: 1,
                          ),
                  ],
                ),
              ],
            ),
          ),
        ));
      });
}
