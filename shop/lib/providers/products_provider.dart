import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/models/http_exception.dart';
import 'package:shop/providers/product.dart';

class ProductsProvider with ChangeNotifier {
  String _url;
  final String _authToken;
  final String _userId;
  List<Product> _items = [];

  ProductsProvider(this._authToken, this._userId, this._items) {
    _url =
        "https://flutter-shop-ef19d-default-rtdb.firebaseio.com/products.json?auth=$_authToken";
  }

  // var _showFavoritesOnly = false;

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((element) => element.isFavorite).toList();
    // } else {
    return [..._items];
    // }
  }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> addProduct(Product product) async {
    try {
      final response = await http.post(_url,
          body: json.encode({
            "title": product.title,
            "description": product.description,
            "imageUrl": product.imageUrl,
            "price": product.price,
            "creatorId": _userId,
          }));

      final newProduct = Product(
        title: product.title,
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
        id: json.decode(response.body)["name"],
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      final productUrl =
          "https://flutter-shop-ef19d-default-rtdb.firebaseio.com/products/$id.json?auth=$_authToken";
      await http.patch(productUrl,
          body: json.encode({
            "title": newProduct.title,
            "description": newProduct.description,
            "imageUrl": newProduct.imageUrl,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print("Product not found: $id");
    }
  }

  // example of optimistic updating pattern
  Future<void> deleteProduct(String id) async {
    final productUrl =
        "https://flutter-shop-ef19d-default-rtdb.firebaseio.com/products/$id.json?auth=$_authToken";
    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    final existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    try {
      final response = await http.delete(productUrl);
      if (response.statusCode >= 400) {
        throw HttpException("Could not delete product.");
      }
    } catch (e) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw e;
    }
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    try {
      final filterString =
          filterByUser ? '&orderBy="creatorId"&equalTo="$_userId"' : "";
      final response = await http.get(_url + filterString);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      final favoriteUrl =
          "https://flutter-shop-ef19d-default-rtdb.firebaseio.com/userFavorites/$_userId.json?auth=$_authToken";
      final favoriteResponse = await http.get(favoriteUrl);
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData["title"],
          description: prodData["description"],
          price: prodData["price"],
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
          imageUrl: prodData["imageUrl"],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }
//
// void showFavoritesOnly() {
//   _showFavoritesOnly = true;
//   notifyListeners();
// }
//
// void showAll() {
//   _showFavoritesOnly = false;
//   notifyListeners();
// }
}
