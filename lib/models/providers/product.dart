import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final List images;
  final String category;
  final String address;
  final String country;
  bool isFavorite;

  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.images,
      @required this.category,
      @required this.address,
      @required this.country,
      this.isFavorite = false});

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url = Uri.https('store-81999-default-rtdb.firebaseio.com',
        '/userFavourite/$userId/$id.json', {'auth': '$token'});
    try {
      final response = await http.put(url,
          body: json.encode(isFavorite
              ? true
              : false)); //The logic is kind of weird but i hasd to do it like this so it gonna work

      if (response.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    } catch (error) {
      _setFavValue(oldStatus);
    }
  }
}
