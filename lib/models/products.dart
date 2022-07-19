import 'package:get/get.dart';

class Product {
  late String name;
  late double price;

  Product();
  Product.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        price = json['price'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
      };
}
