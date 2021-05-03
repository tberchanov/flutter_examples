import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    isFavorite = !isFavorite;
    notifyListeners();

    final productUrl =
        "https://flutter-shop-ef19d-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$token";
    try {
      final response =
          await http.put(productUrl, body: json.encode(isFavorite));
      if (response.statusCode >= 400) {
        throw HttpException("Could not toggle favorite status.");
      }
    } catch (e) {
      isFavorite = !isFavorite;
      notifyListeners();
      throw e;
    }
  }
}
