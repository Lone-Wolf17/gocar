import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:gocar/src/entity/entities.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../../provider.dart';

class DriverAuthBloc extends BlocBase {
  GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DriverService _customerService = DriverService();

  final _userInfoController = BehaviorSubject<Driver>();

  Observable<Driver> get userInfoFlux => _userInfoController.stream;

  Sink<Driver> get userInfoEvent => _userInfoController.sink;

  Driver get userValue => _userInfoController.value;

  final BehaviorSubject<bool> _startController = new BehaviorSubject<bool>();

  Observable<bool> get startFlux => _startController.stream;

  Sink<bool> get startEvent => _startController.sink;
  DriverService _driverService;

  DriverAuthBloc() {
    _driverService = DriverService();
    /*used to check if it is the first time that the user is logging in, if yes the introduction screen is presented, if it is not going to the used screen to check if it is the first time the user is logging in, if yes, the introduction screen is presented, if no login screen*/
    _checkInitialPage();
  }

  _checkInitialPage() async {
    Driver driver = await _driverService.getCustomerStorage();

    userInfoEvent.add(driver);
    startEvent.add(driver == null);
  }

  Future<void> refreshAuth() async {
    Driver driver = await _driverService.getCustomerStorage();
    userInfoEvent.add(driver);
  }

  Future<void> addDriverAuth(Driver driver) async {
    _driverService.setStorage(driver);
    await _driverService.save(driver);
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

      final driver = Driver(
          email: user.email,
          image: MyImage(url: user.photoUrl, indicatesOnLine: true),
          name: user.displayName,
          id: user.uid);

      await _customerService.verifyExistsByEmailAndSave(driver);
      userInfoEvent.add(driver);
      await _customerService.setStorage(driver);
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

      final driver = Driver(
          email: user.email,
          image: MyImage(
              url: 'assets/images/user/avatar_user.png',
              indicatesOnLine: false),
          name: user.displayName,
          id: user.uid);

      userInfoEvent.add(driver);
      await _customerService.setStorage(driver);

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
  }) async {
    try {
      FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
          email: email, password: password))
          .user;

      final driver = Driver(
          email: user.email,
          image: MyImage(
              url: 'assets/images/user/avatar_user.png',
              indicatesOnLine: false),
          name: name,
          id: user.uid);

      await _customerService.verifyExistsByEmailAndSave(driver);

      userInfoEvent.add(driver);
      _customerService.setStorage(driver);
    } on PlatformException catch (ex) {
      throw ex;
    } catch (ex) {
      throw ex;
    }
  }

  Stream<FirebaseUser> get onAuthStateChanged => _auth.onAuthStateChanged;

  Future<void> signOut() async {
    await _driverService.remove();
    userInfoEvent.add(null);
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
