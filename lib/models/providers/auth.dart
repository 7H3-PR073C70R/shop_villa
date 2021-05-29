import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import '../http_exception.dart';

class AuthProvider with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<String> _authenticate(
      String email, String password, String urlSegment) async {
    final url = Uri.https(
        'identitytoolkit.googleapis.com',
        '/v1/accounts:$urlSegment',
        {'key': 'AIzaSyAFsFXiKlAF8-CzEISZ3IWlsmJt4Ipc1EE'});
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'password': password,
        'email': email,
        'expiryDate': _expiryDate.toIso8601String()
      });
      prefs.setString('userData', userData);
      return responseData['idToken'];
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(
      {String username,
      String phone,
      String country,
      String email,
      String password,
      File image}) async {
    // sign up address "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=[API_KEY]"
    String url;
    // print('Saving to file-------------------------');
    // print('$_userId-------------------------------------');
    try {
      if (image != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_profile_image')
            .child('$_userId${DateTime.now()}.jpg');

        await ref.putFile(image);
        url = await ref.getDownloadURL();
      }
    } catch (error) {
      print('an error ocurred');
    }
    await _authenticate(email, password, 'signUp');
    //print('Adding to db-------------------------------');
    await FirebaseFirestore.instance.collection('users').doc(_userId).set({
      'email': email,
      'phone': phone,
      'username': username,
      'country': country,
      'profilePicture': url != null ? url : ''
    });
    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode({
      'token': _token,
      'userId': _userId,
      'password': password,
      'email': email,
      'expiryDate': _expiryDate.toIso8601String()
    });
    prefs.setString('userData', userData);
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
    // sign in address "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=[API_KEY]"
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  void logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;

    _authTimer = Timer(Duration(seconds: timeToExpiry), _autoAut);
  }

  void _autoAut() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;

    _authenticate(extractedUserData['email'], extractedUserData['password'],
        'signInWithPassword');

    notifyListeners();
  }

  Future<void> resetPassword(String email) async{
    final url = Uri.https(
        'identitytoolkit.googleapis.com',
        '/v1/accounts:sendOobCode',
        {'key': 'AIzaSyAFsFXiKlAF8-CzEISZ3IWlsmJt4Ipc1EE', 
        "requestType":"PASSWORD_RESET", "email":"$email"});

      try {
      final response = await http.post(url,
         );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
    } catch (error) {
      throw error;
    }
  }
}
