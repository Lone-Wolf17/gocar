import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../../provider.dart';

class PassengerAuthBloc extends BlocBase {
  GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final PassengerService _customerService = PassengerService();
  final TripService _tripService = TripService();
  final _userInfoController = BehaviorSubject<Passenger>();

  Observable<Passenger> get userInfoFlux => _userInfoController.stream;

  Sink<Passenger> get userInfoEvent => _userInfoController.sink;

  Passenger get userValue => _userInfoController.value;

  final BehaviorSubject<bool> _startController = new BehaviorSubject<bool>();

  Observable<bool> get startFlux => _startController.stream;

  Sink<bool> get startEvent => _startController.sink;
  PassengerService _passengerService;

  PassengerAuthBloc() {
    _passengerService = PassengerService();
    _validaPage();
  }

  _validaPage() async {
    Passenger passenger = await _passengerService.getCustomerStorage();
    userInfoEvent.add(passenger);
    startEvent.add(passenger == null);

    if (passenger != null)
      await _tripService.cancelAllOpenPassengerTrips(passenger.id);
  }

  Future<void> refreshAuth() async {
    Passenger passenger = await _passengerService.getCustomerStorage();
    userInfoEvent.add(passenger);
  }

  Future<void> addPassengerAuth(Passenger passenger) async {
    _passengerService.setStorage(passenger);
    await _passengerService.save(passenger);
    await refreshAuth();
  }

  Future<void> signWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final FirebaseUser user =
          (await _auth.signInWithCredential(credential)).user;

      final passenger = Passenger(
          age: 0,
          email: user.email,
          image: MyImage(url: user.photoUrl, indicatesOnLine: true),
          name: user.displayName,
          id: user.uid);

      await _customerService.verifyExistsByEmailAndSave(passenger);
      userInfoEvent.add(passenger);
      await _customerService.setStorage(passenger);
    } on PlatformException catch (ex) {
      throw ex;
    } catch (ex) {
      throw ex;
    }
  }

  Future<bool> signWithEmailPassword({
    @required String email,
    @required String password,
  }) async {
    try {
      final FirebaseUser user = (await _auth.signInWithEmailAndPassword(
          email: email, password: password))
          .user;

      if (user == null) return false;

      final passenger = Passenger(
          age: 0,
          email: user.email,
          image: MyImage(url: 'assets/images/user/avatar_user.png',
              indicatesOnLine: false),
          name: user.displayName,
          id: user.uid);


      userInfoEvent.add(passenger);
      await _customerService.setStorage(passenger);

      return true;
    } on PlatformException catch (ex) {
      throw ex;
    } catch (ex) {
      throw ex;
    }
  }

  Future<void> recoveryPassword({
    @required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on PlatformException catch (ex) {
      throw ex;
    } catch (ex) {
      throw ex;
    }
  }

  Future<void> registerWithEmailPassword({
    @required String email,
    @required String password,
    @required String name,
    @required int age,
  }) async {
    try {
      FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
          email: email, password: password))
          .user;

      final passageiro = Passenger(
          age: age,
          email: user.email,
          image: MyImage(
              url: 'assets/images/user/avatar_user.png',
              indicatesOnLine: false),
          name: name,
          id: user.uid);

      await _customerService.verifyExistsByEmailAndSave(passageiro);

      userInfoEvent.add(passageiro);
      _customerService.setStorage(passageiro);
    } on PlatformException catch (ex) {
      throw ex;
    } catch (ex) {
      throw ex;
    }
  }

  Stream<FirebaseUser> get onAuthStateChanged => _auth.onAuthStateChanged;

  Future<void> signOut() async {
    await _passengerService.remove();
    return Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<bool> isSignedIn() async {
    final currentUser = await _auth.currentUser();
    return currentUser != null;
  }

  @override
  void dispose() {
    _userInfoController?.close();
    _startController?.close();
    super.dispose();
  }
}
