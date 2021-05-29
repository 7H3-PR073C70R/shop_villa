import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import '../http_exception.dart';
import 'product.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _items = [];
  //var _showFavoritesOnly = false;
  final String authToken;
  final String userId;
  ProductsProvider(this.authToken, this.userId, this._items);

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((product) => product.isFavorite).toList();
    // }
    return [..._items];
  }

  Future<String> getCountry() async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return snapshot['country'].toString();
  }

  Future<void> fetchAndSetProduc([bool filterByUser = false]) async {
    var url = !filterByUser
        ? Uri.https('store-81999-default-rtdb.firebaseio.com', '/products.json',
            {'auth': '$authToken'})
        : Uri.https(
            'store-81999-default-rtdb.firebaseio.com', '/products.json', {
            'auth': '$authToken',
            'orderBy': '"creatorId"',
            'equalTo': '"$userId"',
          });
    //  url = Uri.https('store-81999-default-rtdb.firebaseio.com',
    //       '/products.json',{'auth':'$authToken'});
    try {
      final respone = await http.get(url);
      final extractedDatas = json.decode(respone.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      //print('${filterByUser?extractedDatas:''}');
      if (extractedDatas == null) {
        return;
      }
      url = Uri.https('store-81999-default-rtdb.firebaseio.com',
          '/userFavourite/$userId.json', {'auth': '$authToken'});

      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);

      extractedDatas.forEach((key, value) {
        loadedProducts.add(
          Product(
            id: key,
            title: value['title'],
            description: value['description'],
            price: value['price'],
            images: value['images'],
            category: value['category'],
            address: value['address'],
            creatorId: value['creatorId'],
            country: value['country'],
            isFavorite:
                favoriteData == null ? false : favoriteData[key] ?? false,
          ),
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  List<Product> get favoriteItems {
    return _items.where((product) => product.isFavorite == true).toList();
  }

  Future<void> filterProduct(String country, String category) async {
    if (country == 'Select Country' && category != 'Select Category') {
      //fetchAndSetProduc();
      _items = _items.where((element) => element.category == category).toList();
    } else if (country != 'Select Country' && category == 'Select Category') {
      //fetchAndSetProduc();
      _items = _items.where((element) => element.country == country).toList();
    } else if (country != 'Select Country' && category != 'Select Category') {
      //fetchAndSetProduc();
      _items = _items
          .where((element) =>
              element.country == country && element.category == category)
          .toList();
    }
    // else {
    //   fetchAndSetProduc();
    // }

    notifyListeners();
  }

  List<Product> searchedItems(String query) {
    return _items
        .where((product) =>
            product.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.https('store-81999-default-rtdb.firebaseio.com',
        '/products.json', {'auth': '$authToken'});
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'images': product.images,
            'category': product.category,
            'creatorId': userId,
            'address': product.address,
            'country': await getCountry()
          }));
      final newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          category: product.category,
          creatorId: product.creatorId,
          address: product.address,
          country: await getCountry(),
          images: product.images);
      _items.insert(0, newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.https('store-81999-default-rtdb.firebaseio.com',
          '/products/$id.json', {'auth': '$authToken'});
      try {
        await http.patch(url,
            body: json.encode({
              'title': newProduct.title,
              'description': newProduct.description,
              'images': newProduct.images,
              'category': newProduct.category,
              'address': newProduct.address,
              'creatorId': newProduct.creatorId,
              'price': newProduct.price,
            }));
      } catch (error) {
        throw error;
      }
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      return;
    }
  }

  Future<void> removeImage(String id, int index) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.https('store-81999-default-rtdb.firebaseio.com',
          '/products/$id.json', {'auth': '$authToken'});

      _items[prodIndex].images.removeAt(index);
      List newProdImages = _items[prodIndex].images;
      try {
        await http.patch(url,
            body: json.encode({
              'title': _items[prodIndex].title,
              'description': _items[prodIndex].description,
              'images': newProdImages,
              'category': _items[prodIndex].category,
              'address': _items[prodIndex].address,
              'creatorId': _items[prodIndex].creatorId,
              'price': _items[prodIndex].price,
            }));
      } catch (error) {
        throw error;
      }
      notifyListeners();
    } else {
      return;
    }
  }

  void deleteProduct(String id) async {
    final url = Uri.https('store-81999-default-rtdb.firebaseio.com',
        '/products/$id.json', {'auth': '$authToken'});
    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product');
    }
    existingProduct = null;
  }
}
