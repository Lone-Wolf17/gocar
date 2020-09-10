import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:gocar/src/infra/infra.dart';
import 'package:gocar/src/provider/provider.dart';
import 'package:line_icons/line_icons.dart';

class AddLocationPage extends StatefulWidget {
  const AddLocationPage(this.localeType);

  final LocaleType localeType;

  @override
  _AddLocationPageState createState() => _AddLocationPageState();
}

class _AddLocationPageState extends State<AddLocationPage> {
  TextEditingController originController = new TextEditingController();
  PassengerAuthBloc _authBloc;
  AutoCompleteBloc _autoCompleteBloc;
  Passenger passenger;

  @override
  void dispose() {
    originController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _authBloc = BlocProvider.getBloc<PassengerAuthBloc>();
    _autoCompleteBloc = AutoCompleteBloc();
    _autoCompleteBloc.localEventList.add(List<Local>());
    _pageLoad();
    super.initState();
  }

  _pageLoad() async {
    passenger = await _authBloc.userInfoFlux.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          bottom: new PreferredSize(
            preferredSize: const Size.fromHeight(60.0),
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
                          Navigator.of(context).pop();
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
                          labelText: "Enter address here!",
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
        body: StreamBuilder(
            stream: _autoCompleteBloc.localListFlux,
            builder:
                (BuildContext context, AsyncSnapshot<List<Local>> snapshot) {
              if (!snapshot.hasData || snapshot.data.length == 0) {
                return Container(height: 1, width: 1);
              }
              return ListView(
                padding: EdgeInsets.all(8.0),
                children: snapshot.data
                    .map((data) =>
                    GestureDetector(
                      onTap: () {
                        var local = Local(
                            latitude: data.latitude,
                            longitude: data.longitude,
                            address: data.address,
                            name: data.name);

                        if (widget.localeType == LocaleType.Home) {
                          passenger.home = local;
                        } else {
                          passenger.work = local;
                        }

                        _authBloc.addPassengerAuth(passenger).then((r) {
                          Navigator.of(context).pop();
                        });
                          },
                          child: ListTile(
                            leading: Icon(Icons.location_on),
                            title: Text(
                              data.name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(data.address),
                          ),
                        ))
                    .toList(),
              );
            }));
  }
}

