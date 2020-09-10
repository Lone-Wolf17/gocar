import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:rxdart/rxdart.dart';

import '../../provider.dart';

class AutoCompleteBloc extends BlocBase {
  GoogleService _googleService;

  /*listing related to auto-complete*/
  final BehaviorSubject<List<Local>> _localListController =
      new BehaviorSubject<List<Local>>();

  Observable<List<Local>> get localListFlux => _localListController.stream;

  Sink<List<Local>> get localEventList => _localListController.sink;

/*end listing*/

/*search control variables*/
  final BehaviorSubject<Filter> _searchController =
      new BehaviorSubject<Filter>();

  Observable<Filter> get searchFlux => _searchController.stream;

  Sink<Filter> get searchEvent => _searchController.sink;

/*end search control*/

  AutoCompleteBloc() {
    /*sevice instantiation*/
    _googleService = new GoogleService();
    /*end service*/
    /*any change in the search variable calls the method to start filter*/
    searchFlux.listen(searchByKeyWord());
  }

  /*called when the observed variable changes state*/
  searchByKeyWord() {
    _searchController
        .distinct() //avoid repeated values
        .debounceTime(Duration(microseconds: 500)) // wait a while
        .asyncMap(filterBy) // converts the value
        .switchMap((value) => Observable.just(value))
        .listen((r) => localEventList.add(r));
  }

  /*filter that searches for locations based on the word*/
  Future<List<Local>> filterBy(Filter filter) async {
    var list = (await _googleService.searchPlace(filter));

    if (filter.keyWord == '') return list;

    return list;
  }
/*end auto-complete*/
}
